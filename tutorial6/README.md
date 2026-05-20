# Tutorial 6：从 AST 生成 RISC-V 汇编

## 1. 这次 Tutorial 在做什么

前面的 Tutorial 已经完成了从源代码到 AST 再到求值（Interpreter）的整条链路：

```
源代码字符串 → Lexer → Parser → AST → Interpreter 求值
```

Tutorial 6 把链路的最后一段从「解释执行」换成「生成汇编」：

```
源代码字符串 → Lexer → Parser → AST → RISC-V 汇编
```

也就是写一个**简单的代码生成器（code generator）**，把 SimPL 的 AST 翻译成 RISC-V 汇编代码。

`main.ml` 里 `parse` 函数复用了之前 Tutorial 写好的 Lexer/Parser：

```ocaml
let parse s : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.main Lexer.read lexbuf in
  ast
```

本次 Tutorial 真正要实现的核心函数是：

```ocaml
let rec compiler_expr env cur_offset expr : string
```

它把 AST 表达式翻译成一段 RISC-V 汇编字符串。

---

## 2. 全局约定

整个代码生成器只需要记住一条约定：

> **每个表达式编译完之后，结果一定放在寄存器 `a0` 中。**

只要每个递归分支都遵守这条规则，外层表达式就可以放心地从 `a0` 拿走子表达式的值。

本次用到的寄存器：

| 寄存器  | 作用                  |
| ---- | ------------------- |
| `a0` | 表达式求值结果 / 函数返回值     |
| `a1` | 闭包调用时传入的环境指针        |
| `t0` / `t1` | 临时寄存器        |
| `sp` | 栈顶指针，动态变化           |
| `fp` | 栈帧基址，固定参考点，用于访问局部变量 |
| `ra` | 返回地址                |
| `x0` | 永远是 0               |

`compiler_expr` 的两个参数：

- `env : (string * int) list`：编译期的符号表，记录变量名到 `fp` 偏移的映射。例如 `[("x", 8); ("y", 16)]` 表示 `x` 在 `-8(fp)`，`y` 在 `-16(fp)`。
- `cur_offset : int`：当前已经分配出去的局部变量字节数。每多一个 `let` 绑定就 `+8`。

辅助工具：

```ocaml
let label_count = ref 0
let fresh_label prefix =
  incr label_count;
  Printf.sprintf "%s_%d" prefix !label_count
```

`fresh_label` 用来生成全局唯一的跳转标签（避免多个 `if` 嵌套时标签冲突）。

---

## 3. 程序的整体框架

`compiler_program` 负责把 `compiler_expr` 生成的代码包到一个完整的 RISC-V 可执行片段里：

```ocaml
let compiler_program (e : expr) : string =
  let body_code = compiler_expr [] 0 e in
  let prologue =
    ".text\n\
    .global main\n\
    main:\n\
    \taddi sp, sp, -64\n\
    \tmv fp, sp\n"
  in
  let epilogue =
    "\tmv sp, fp\n\
    \taddi sp, sp, 64\n\
    \tret\n"
  in
  let func_code = String.concat "\n" !functions in
  prologue ^ body_code ^ epilogue ^ "\n" ^ func_code
```

- **prologue**：在栈上预留 64 字节，并把 `fp` 指向当前栈顶。后续所有局部变量都通过 `fp` 加负偏移访问。
- **body_code**：表达式本体的汇编。
- **epilogue**：恢复 `sp`，`ret` 返回。
- **func_code**：闭包翻译产生的函数体（如果有），统一拼接到主体之后。

---

## 4. 实现 1：常量和变量

```ocaml
| Int n ->
  Printf.sprintf "\tli a0, %d\n" n
| Bool b ->
  if b then "\tli a0, 1\n" else "\tli a0, 0\n"
| Var x ->
  (try
    let offset = List.assoc x env in
    Printf.sprintf "\tld a0, -%d(fp)\n" offset
  with Not_found ->
    failwith ("Unbound variable: " ^ x))
```

- 整数：`li a0, n` 把立即数加载到 `a0`。
- 布尔：用 `1`/`0` 表示 `true`/`false`。
- 变量：通过 `env` 找到它在栈帧中的偏移，然后用 `ld a0, -offset(fp)` 把值加载回 `a0`。

---

## 5. 实现 2：二元运算 `Binop`

二元运算的难点在于：**算完左操作数后，结果在 `a0`，可一旦开始算右操作数，`a0` 会被覆盖。** 所以必须把左值先压栈保存。

标准编译模板：

```text
1. 编译 e1，结果 → a0
2. 把 a0 压栈
3. 编译 e2，结果 → a0
4. 把栈顶的左值弹出到 t0
5. 用 t0（左）和 a0（右）做运算，结果写回 a0
```

```ocaml
| Binop (op, e1, e2) ->
  let code1 = compiler_expr env cur_offset e1 in
  let push_left = "\taddi sp, sp, -8\n\tsd a0, 0(sp)\n" in
  let code2 = compiler_expr env cur_offset e2 in
  let pop_left = "\tld t0, 0(sp)\n\taddi sp, sp, 8\n" in
  let op_code = match op with
    | Add -> "\tadd a0, t0, a0\n"
    | Sub -> "\tsub a0, t0, a0\n"
    | Mul -> "\tmul a0, t0, a0\n"
    | Div -> "\tdiv a0, t0, a0\n"
    | Leq -> "Not implemented"
  in
  code1 ^ push_left ^ code2 ^ pop_left ^ op_code
```

注意：

- `Sub` / `Div` 不能写反，**左值在 `t0`，右值在 `a0`**，所以 `sub a0, t0, a0` 表示「左 − 右」。
- `Leq`（`<=`）若实现，可以利用 RISC-V 的 `slt`：

  ```asm
  slt a0, a0, t0     # a0 < t0 ? 等价于 t0 > a0 ⇒ 不满足 t0 ≤ a0
  xori a0, a0, 1     # 翻转一位 → t0 ≤ a0
  ```

以 `3 + 5 * 9` 为例（对应 `test/simpl_test1.in` → `test/test1.s`）：

```asm
li a0, 3
addi sp, sp, -8
sd a0, 0(sp)        # 保存 3
li a0, 5
addi sp, sp, -8
sd a0, 0(sp)        # 保存 5
li a0, 9
ld t0, 0(sp)        # t0 = 5
addi sp, sp, 8
mul a0, t0, a0      # a0 = 5 * 9 = 45
ld t0, 0(sp)        # t0 = 3
addi sp, sp, 8
add a0, t0, a0      # a0 = 3 + 45 = 48
```

---

## 6. 实现 3：`let` 绑定

`let x = e1 in e2` 的语义是：算出 `e1` 的值并把它绑定到 `x`，然后在新的环境下计算 `e2`。

编译模板：

```text
1. 编译 e1，结果 → a0
2. 把 a0 存到 fp 的某个偏移处（new_offset = cur_offset + 8）
3. env 里加入 (x, new_offset)
4. 用新 env 和新 offset 编译 e2
5. 离开作用域：sp 回退 8 字节
```

```ocaml
| Let (x, e1, e2) ->
  let code1 = compiler_expr env cur_offset e1 in
  let new_offset = cur_offset + 8 in
  let alloc = Printf.sprintf "\taddi sp, sp, -8\n\tsd a0, -%d(fp)\n" new_offset in
  let env' = (x, new_offset) :: env in
  let code2 = compiler_expr env' new_offset e2 in
  let free = "\taddi sp, sp, 8\n" in
  code1 ^ alloc ^ code2 ^ free
```

关键点：

- 局部变量按「**先来后到**」依次放在 `-8(fp), -16(fp), -24(fp) …`。
- `env` 是 `cons` 出来的，自然形成了**词法作用域**（最新绑定在最前面，`List.assoc` 优先命中它）。
- 退出作用域只需要把 `sp` 抬回去 8 字节，因为 `fp` 没动，所以更外层变量的偏移仍然有效。

`test/simpl_test2.in`：

```
let x = 10 in
  (x * 2) + (let y = 3 in x + y)
```

编译后 `x` 在 `-8(fp)`，进入内层 `let y = 3` 时 `y` 在 `-16(fp)`；离开内层 `let` 之后 `y` 的栈空间被回收，但 `x` 仍然有效。

---

## 7. 实现 4：`if` 表达式

汇编里没有结构化的 `if`，只能用条件跳转 + 标签来实现：

```text
1. 计算条件 cond，结果 → a0
2. 如果 a0 == 0，跳到 else 分支
3. 否则顺序执行 then 分支
4. then 执行完，无条件跳到 end
5. else: 执行 else 分支
6. end: 后续代码
```

```ocaml
| If (cond, e_then, e_else) ->
  let label_else = fresh_label "Lelse" in
  let label_end = fresh_label "Lend" in
  let code_cond = compiler_expr env cur_offset cond in
  let code_then = compiler_expr env cur_offset e_then in
  let code_else = compiler_expr env cur_offset e_else in
  code_cond ^
  Printf.sprintf "\tbeq a0, x0, %s\n" label_else ^
  code_then ^
  Printf.sprintf "\tj %s\n" label_end ^
  Printf.sprintf "%s:\n" label_else ^
  code_else ^
  Printf.sprintf "%s:\n" label_end
```

必须用 `fresh_label` 而不是写死的 `Lelse:` / `Lend:`，否则多个 `if` 嵌套时跳转会乱套。`test/simpl_test3.in` 的输出展示了标签后缀 `_1, _2` 是怎么来的：

```
if true then 42 else 13
```

对应：

```asm
li a0, 1
beq a0, x0, Lelse_1
li a0, 42
j Lend_2
Lelse_1:
li a0, 13
Lend_2:
```

---

## 8. 实现 5（选做）：`Func` 和 `App`（闭包）

`Func (x, body)` 不能只翻译成一段函数代码，因为函数体里可能用到**自由变量**（free variable）——既不是参数、也不是函数内部定义的变量。

例如 `test/simpl_test4.in`：

```
let a = 10 in
let f = fun x -> x + a in
f 3
```

`fun x -> x + a` 里的 `a` 来自外层作用域，不能在函数被调用的那一刻凭空生出来。解决办法是构造**闭包**：

```
closure = [函数代码地址, 自由变量1的值, 自由变量2的值, ...]
```

`Func` 的实现分三步：

1. **静态分析自由变量**（`free_vars body [x]`），把绑定变量 `x` 排除掉。
2. **生成函数体代码**（`compile_expr_func`），函数内部对变量的查找规则变成：
   - 参数 → `-offset(fp)`
   - 自由变量 → `offset(a1)`（`a1` 是调用者传入的环境指针）
3. **生成构造闭包的代码**：在堆上分配 `8 * (1 + 自由变量个数)` 字节，第 0 字（offset 0）写入函数代码地址，后面依次写入自由变量当前的值。最终把闭包指针放进 `a0`。

```ocaml
| Func (x, body) ->
  let fvs = free_vars body [x] in
  let num_free = List.length fvs in
  let func_id = fresh_label "func" in
  let local_env = [(x, 8)] in
  let closure_env = List.mapi (fun i v -> (v, 8 * i)) fvs in
  let func_body_code = compile_expr_func local_env closure_env 0 body in
  let func_prologue =
    Printf.sprintf "%s:\n\taddi sp, sp, -16\n\tsd ra, 8(sp)\n\tsd fp, 0(sp)\n\tmv fp, sp\n" func_id
  in
  let func_epilogue =
    "\tld ra, 8(sp)\n\tld fp, 0(sp)\n\taddi sp, sp, 16\n\tret\n"
  in
  let func_code = func_prologue ^ func_body_code ^ func_epilogue in
  functions := !functions @ [func_code];

  let closure_size = 8 * (1 + num_free) in
  let alloc_code = Printf.sprintf "\tli a0, %d\n\tjal ra, malloc\n" closure_size in
  let move_closure = "\tmv t0, a0\n" in
  let store_code_ptr = Printf.sprintf "\tla t1, %s\n\tsd t1, 0(t0)\n" func_id in
  let store_free_vars =
    List.mapi (fun i v ->
      let outer_offset =
        try List.assoc v env with Not_found -> failwith ("Unbound free var: " ^ v)
      in
      Printf.sprintf "\tld t1, -%d(fp)\n\tsd t1, %d(t0)\n" outer_offset (8 * (i + 1))
    ) fvs |> String.concat ""
  in
  let ret_code = "\tmv a0, t0\n" in
  alloc_code ^ move_closure ^ store_code_ptr ^ store_free_vars ^ ret_code
```

`App (e1, e2)`（函数调用）的协议是：

- `e1` 算出来是一个**闭包指针**，临时保存到 `t0`。
- `e2` 算出来是参数，按照本实现的约定，结果留在 `a0`，函数体里通过 `-8(fp)` 取参数（详见下文 `compile_expr_func`）。
- `a1` ← `t0 + 8`，指向闭包里自由变量数组的起始位置，作为环境指针传给被调用函数。
- 从闭包第 0 字读出代码地址到 `t1`，然后 `jalr ra, 0(t1)` 跳转执行。

```ocaml
| App (e1, e2) ->
  let code_f = compiler_expr env cur_offset e1 in
  let save_closure = "\tmv t0, a0\n" in
  let code_arg = compiler_expr env cur_offset e2 in
  let load_env = "\taddi a1, t0, 8\n" in
  let load_code_ptr = "\tld t1, 0(t0)\n" in
  let call = "\tjalr ra, 0(t1)\n" in
  code_f ^ save_closure ^ code_arg ^ load_env ^ load_code_ptr ^ call
```

`compile_expr_func` 是函数体专用的编译器，它和 `compiler_expr` 的唯一区别是变量查找逻辑：

- 先在 `local_env`（参数）里找，命中则 `ld a0, -offset(fp)`；
- 否则在 `closure_env`（自由变量）里找，命中则 `ld a0, offset(a1)`；
- 都找不到就报错。

> ⚠️ **参考输出 `test/test4.s` 里有一个明显的笔误**：
>
> ```asm
> ld t0, 0, 0(sp)
> ```
>
> 这不是合法 RISC-V 写法。这条指令是 `compile_expr_func` 里 `Binop` 分支的 `pop_left`，应当写成：
>
> ```asm
> ld t0, 0(sp)
> ```
>
> 同样地，`compile_expr_func` 里的 `Leq` 还是 `"Not implemented"`，闭包内的 `If`、嵌套 `Func/App` 也都没实现，属于选做的「以后再说」部分。

---

## 9. 测试

`test/` 目录下提供了四组对照样例：

| 输入                 | 输出                  | 覆盖点                              |
| ------------------ | ------------------- | -------------------------------- |
| `simpl_test1.in`   | `test1.s`           | 整数 + 嵌套 `Binop`（混合 `*` 和 `+`）    |
| `simpl_test2.in`   | `test2.s`           | 多层 `let` + 变量在不同栈帧偏移上的查找         |
| `simpl_test3.in`   | `test3.s`           | `if true then ... else ...` 控制流 |
| `simpl_test4.in`   | `test4.s`           | 闭包（`fun x -> x + a` 捕获 `a`）     |

`main.ml` 里默认读取的是 `test/simpl_test4.in`：

```ocaml
let filename = "test/simpl_test4.in" in
```

如需测试其他样例，把这一行换成对应的输入文件即可。运行方式（命令行参数是输出文件路径）：

```bash
dune exec ./main.exe output.s
```

输出文件就是生成的 RISC-V 汇编，可以直接对照 `test/testN.s` 检查。

---

## 10. 验收 / 关键问答

- **为什么所有表达式的结果都放在 `a0`？**
  统一约定，方便递归。子表达式编译完一定在 `a0`，外层就可以无脑取用。

- **二元运算为什么要压栈？**
  算完左值 `a0` 后，编译右子表达式时会覆盖 `a0`，必须先把左值挪到安全的地方（栈）保存，等右值算完再弹回 `t0`。

- **`env` 是什么？**
  编译期的符号表 `(变量名, 相对 fp 的偏移)`。遇到 `Var x` 时拿来生成 `ld a0, -offset(fp)`。

- **`fp` 和 `sp` 的区别？**
  `fp` 是当前栈帧的固定基准点，变量按 `-offset(fp)` 访问；`sp` 是动态栈顶，压栈弹栈都会改变。临时值（如 `Binop` 中暂存的左值）用 `sp` 压栈即可。

- **`if` 为什么要 `fresh_label`？**
  汇编只有跳转没有结构化分支。多个 `if` 嵌套时，每个都需要唯一的 `Lelse` / `Lend`，否则跳转目标会重复。

- **闭包为什么不只保存代码地址？**
  函数体可能引用外层作用域的变量（自由变量）。这些变量在函数被调用时已经不在调用者栈帧里，所以必须在闭包构造时**复制一份值**到堆对象里，调用时通过 `a1` 传给函数体。

---

## 11. 文件清单

```
tutorial6/
├── README.md          ← 本文件
├── main.ml            ← 代码生成器实现
└── test/
    ├── simpl_test1.in ~ simpl_test4.in   ← 输入：SimPL 源码
    └── test1.s ~ test4.s                 ← 参考输出：RISC-V 汇编
```

`main.ml` 依赖外部库 `Simpl_riscv`（提供 `Ast` / `Lexer` / `Parser`），需要在配套的 dune 工程里通过 `dune build` 构建。
