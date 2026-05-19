# Project 5 — Tutorial 5 全任务实现报告

本项目是 tutorial 5 的最终阶段，**累积**完成了 Task 1 ~ Task 5 的全部修改。每一处改动在源码里都用 `(*修改N*)` 标号注释，本文档逐一对应这些修改的目的、原理和位置。

> 想看每一阶段的独立项目快照：`project1` = Task 1，`project2` = Task 1+2，依此类推。本 `project5` 是 `project4` 之上加 Task 5 lambda calculus。

---

## 运行方式

```bash
cd project5
dune build
dune exec interpreter_project
```

会依次跑 2 个 SimPL 测试 + 5 个 lambda 测试，并打印 small-step 结果、big-step 结果和 AST。

预期输出（节选）：

| 测试 | 输出 |
|---|---|
| `simpl_test1.in`：`let x = 3110 in x + x` | `Int 6220` |
| `simpl_test2.in`：嵌套 let + if | `Int 7` |
| `lambda_test1.in`：`(fun x -> x) (fun y -> y)` | `Fun (y, Var y)` |
| `lambda_test2.in`：三层应用 | `Fun (a, Fun (b, Var b))` |
| `lambda_test3.in`：含未绑定 `z` | `Failure(Unbound variable)` |
| `lambda_test4.in`：`(fun y -> y + 1) 5` | `Int 6` |
| `lambda_test5.in`：lambda + let + if 混合 | `Int 8` |

---

## 修改总览

| 编号 | 所属 Task | 位置 | 简述 |
|---|---|---|---|
| 修改 1 | Task 2 | `main.ml` `step` | small-step 的 `If` 规则 |
| 修改 2 | Task 2 | `main.ml` `eval_big` | big-step 的 `If` 规则 |
| 修改 3 | Task 2 | `main.ml` `eval_bop2` | big-step `If` 辅助函数 |
| 修改 4 | Task 3 | `main.ml` `subst` | `subst` 占位实现，让上层 `Let` 编译通过 |
| 修改 5 | Task 3 | `main.ml` `step` | small-step 的 `Let` 规则 |
| 修改 6 | Task 3 | `main.ml` `eval_big` | big-step 的 `Let` 规则 |
| 修改 7 | Task 4 | `main.ml` `subst` | 把占位换成真正的 `subst` 实现 |
| 修改 8 | Task 4 | `main.ml` `run_one` | 抽出测试驱动函数，验证 `subst` |
| 修改 9 | Task 5 | `ast.ml` | AST 加入 `Fun` / `App` |
| 修改 10 | Task 5 | `lexer.mll` | 新词法：`fun` / `->` |
| 修改 11 | Task 5 | `parser.mly` | 重构文法层级 `expr / app / simple` |
| 修改 12 | Task 5 | `main.ml` `string_of_expr` | 打印 `Fun` / `App` |
| 修改 13 | Task 5 | `main.ml` `is_value` & `step` | `Fun` 是 value |
| 修改 14 | Task 5 | `main.ml` `gensym` | 生成新鲜变量名 |
| 修改 15 | Task 5 | `main.ml` `fv` | 计算自由变量集合 |
| 修改 16 | Task 5 | `main.ml` `subst` | `subst` 扩展到 `App` / `Fun`，做 capture-avoiding |
| 修改 17 | Task 5 | `main.ml` `step` | small-step 的 `App` 规则（β-归约） |
| 修改 18 | Task 5 | `main.ml` `eval_big` | big-step 的 `Fun` / `App` 规则 |
| 修改 19 | Task 5 | `main.ml` `run_lambda` & `main` | 容错版测试驱动，并跑 5 个 lambda 样例 |

---

## Task 1：SimPL 解析

**目标**：让 parser 能把 SimPL 语法解析成 AST，并用 `string_of_expr` 把 AST 打印回字符串。

无单独的"修改 N"标号——因为 Task 1 是整张骨架，是与基础数学解释器对比的"全身改动"。涉及的文件：

- **`ast.ml`**：把 BNF 的每一条产生式翻译成 sum type 构造器。

  ```
  e ::= x | i | b | e1 bop e2 | if … | let …
  ```

  对应：

  ```ocaml
  type binop = Add | Sub | Mul | Leq
  type expr =
    | Int of int                    (* i *)
    | Bool of bool                  (* b *)
    | Var of string                 (* x *)
    | Binop of binop * expr * expr  (* e1 bop e2 *)
    | If of expr * expr * expr      (* if e1 then e2 else e3 *)
    | Let of string * expr * expr   (* let x = e1 in e2 *)
  ```

- **`lexer.mll`**：相比基础数学版多了关键字（`if`/`then`/`else`/`let`/`in`/`true`/`false`/`fun`）、运算符（`<=`、`=`）和标识符规则（`letter+ as id`）。注意关键字必须写在 `letter+` 之前，靠 ocamllex 的"首条优先"规则把它们截下来。

- **`parser.mly`**：声明新 token（`IF/THEN/ELSE/LET/IN/EQUALS/LEQ/ID`），加优先级（`%nonassoc IN ELSE` 解决 dangling-else 类冲突，`%left` 设运算符结合性），并补全产生式。

- **`main.ml` 的 `string_of_expr`**：递归打印 AST。

**为什么 Task 1 没有"修改 N"标号？** 因为这一阶段是把 `project1` 整体从"数学解释器"迁移到"SimPL 解析器"，几乎全文件都改了。Task 2 以后才开始**增量**修改，于是用编号标记每一处局部插入。

---

## Task 2：`if` 语句的求值（修改 1 / 2 / 3）

**目标**：让解释器能算 `if 2 <= 3 then false else true`，输出 `Bool false`。

### 修改 1（small-step，`step` 函数里）

```ocaml
| If (e1,e2,e3) when is_value e1 ->
    (match e1 with
     | Bool true  -> e2
     | Bool false -> e3
     | _ -> failwith "If condition must be a boolean")
| If (e1,e2,e3) -> If (step e1, e2, e3)
```

两条规则对应 PPT 上的 small-step：
- **条件已经是 value** → 看 `Bool` 取分支；
- **条件还能化简** → 只 step 条件，不动两个分支。

⚠️ **括号陷阱**：`(match e1 with …)` 必须用括号包住，否则下一行的 `| If (e1,e2,e3) -> …` 会被 OCaml 当成内层 match 的分支，引发难看的类型错误。

### 修改 2 + 3（big-step）

```ocaml
| If (e1,e2,e3) -> eval_bop2 e1 e2 e3        (* 修改 2 *)

and eval_bop2 e1 e2 e3 = match eval_big e1 with    (* 修改 3 *)
  | Bool true  -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "If condition must be a boolean"
```

big-step 的精髓：**不暴露中间步骤**。`eval_bop2` 直接对 `e1` 递归大步求值得到一个布尔值，再根据布尔选其中一个分支继续大步求值。

---

## Task 3：`let` 语句的基本求值（修改 4 / 5 / 6）

**目标**：让 small-step 和 big-step 都能跑 `let x = e1 in e2`。本阶段允许 `subst` 是占位实现，所以遇到含变量的 let 会报错——这是预期行为，下个 Task 才补齐。

### 修改 4（占位 `subst`）

```ocaml
let subst _ _ _ = failwith "TODO: implement substitution"
```

放占位的意义：让下面 `Let` 分支能调用 `subst`，先把整体编译跑通；真实逻辑留到 Task 4。

### 修改 5（small-step `Let`）

```ocaml
| Let (x, e1, e2) when is_value e1 -> subst e2 e1 x
| Let (x, e1, e2) -> Let (x, step e1, e2)
```

对应 PPT 规则：
- `let x = v1 in e2 --> e2{v1/x}`：e1 已是 value，做替换；
- `let x = e1 in e2 --> let x = e1' in e2`：e1 还能 step，只 step e1。

### 修改 6（big-step `Let`）

```ocaml
| Let (x, e1, e2) ->
    let v1 = eval_big e1 in
    eval_big (subst e2 v1 x)
```

对应 PPT 规则 `let x = e1 in e2 ==> v2  if e1 ==> v1 and e2{v1/x} ==> v2`。直接照搬：先把 e1 大步求成 v1，再对 e2 做替换，再大步求 e2{v1/x}。

---

## Task 4：实现真正的 `subst`（修改 7 / 8）

### 修改 7（真实 `subst`）

```ocaml
let rec subst (e : expr) (v : expr) (x : string) : expr =
  match e with
  | Int _ | Bool _ -> e                                          (* 常量不变 *)
  | Var y when y = x -> v                                        (* 命中：替换 *)
  | Var _ -> e                                                   (* 别的变量：不动 *)
  | Binop (op, e1, e2) -> Binop (op, subst e1 v x, subst e2 v x) (* 递归 *)
  | If (e1, e2, e3) -> If (subst e1 v x, subst e2 v x, subst e3 v x)
  | Let (y, e1, e2) when y = x -> Let (y, subst e1 v x, e2)      (* y=x 时 e2 已被 shadow *)
  | Let (y, e1, e2) -> Let (y, subst e1 v x, subst e2 v x)
```

**关键陷阱在 `Let` 的两条规则**：
- 如果 `let` 绑定的变量名**就是要替换的 x**（`y = x`），那么 e2 里的 x 都属于"被这个 let 重新绑定"了——已经 shadow，不能再被外层的 v 替换。所以只替换 e1（e1 还在内层 let 的"外面"）。
- 否则 e1 和 e2 都要递归替换。

PPT 给的两个例子刚好对应这两条：
- `let x = 5 in let x = 6 in x` → 内层 x = 6 shadow 外层 → 答案 6；
- `let x = 5 in let y = 1 + x in y * x` → 答案 30。

### 修改 8（`run_one` 测试驱动）

把原本一坨写在 `let () = …` 里的"打开文件 → 解释 → 打印"流程抽成函数：

```ocaml
let run_one filename =
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;
  let res = interp file_content in
  Printf.printf "Result of interpreting %s:\n%s\n\n" filename res;
  let res = interp_big file_content in
  Printf.printf "Result of interpreting %s with big-step model:\n%s\n\n" filename res;
  let ast = parse file_content in
  Printf.printf "AST: %s\n\n" (string_of_expr ast)
```

之后 `let () =` 里就只剩 `run_one "test/simpl_test1.in"; run_one "test/simpl_test2.in"`，干净很多。

---

## Task 5：Lambda Calculus 解释器（修改 9 ~ 19）

**目标**：把 lambda calculus（`fun x -> e` 和 `e1 e2`）整合进解释器，并实现 **capture-avoiding substitution**。

### 修改 9：AST 加两个构造器（`ast.ml`）

```ocaml
| Fun of string * expr     (* fun x -> e *)
| App of expr * expr       (* e1 e2 *)
```

### 修改 10：lexer 加两个 token（`lexer.mll`）

```ocaml
| "->"   { ARROW }
| "fun"  { FUN }
```

`->` 是双字符，必须用字符串写法 `"->"` 而不是 `'-' '>'`。`fun` 当然要写在 `letter+ as id` 之前，否则就被识别成 `ID "fun"` 了。

### 修改 11：parser 重构文法层级（`parser.mly`）

这是 Task 5 里最微妙的一处。**问题**：函数应用 `f x` 是把两个表达式并排放，没有运算符。直接写

```
expr : expr expr   { App ($1, $2) }
```

会和现有的 `expr PLUS expr` 等规则爆冲突，而且没办法用 `%left` 解决（因为没有"应用运算符"这个 token 可用）。

**做法**：把 `expr` 拆成三层：

```
expr  →  app                                       (* 顶层 *)
       | expr PLUS expr | expr MINUS expr | …      (* 二元运算 *)
       | IF … | LET … | FUN ID ARROW expr           (* 复合语句 *)

app   →  simple
       | app simple                                 (* 左递归：左结合 *)

simple →  INT | TRUE | FALSE | ID | LPAREN expr RPAREN
```

- **`app simple`**（左递归）保证应用是**左结合**：`f x y` 解析成 `(f x) y`。
- **`app` 在 `expr` 内层**，所以应用比二元运算**优先级更高**：`f x + 1` 解析成 `(f x) + 1`。
- 不需要给 application 写任何 `%left` / `%right`。

构建时 menhir 会报 "4 shift/reduce conflicts arbitrarily resolved"——这是 `expr → app` 与 `app → app simple` 在边界上的天然冲突（看到下一个 simple-开头 token 时，menhir 选"shift 继续扩展 app"，刚好就是我们想要的左结合行为）。**不影响正确性**。

### 修改 12：`string_of_expr` 打印新构造器

```ocaml
| Fun (x, e)   -> Printf.sprintf "Fun (%s, %s)" x (string_of_expr e)
| App (e1, e2) -> Printf.sprintf "App (%s, %s)" (string_of_expr e1) (string_of_expr e2)
```

### 修改 13：`Fun` 是 value

```ocaml
let is_value = function | Int _ | Bool _ | Fun _ -> true | _ -> false
```

lambda calculus 里**匿名函数本身就是 value**——它不需要"被算"，只需要被应用时才会发生 β-归约。所以 `is_value` 加上 `Fun _`，对应地 `step` 的"不可 step"分支也要把 `Fun _` 算进去。

### 修改 14：`gensym` —— 生成全局唯一的新变量名

```ocaml
let gensym =
  let counter = ref 0 in
  fun () -> incr counter; "$x" ^ string_of_int !counter
```

闭包技巧：`counter` 是这个函数私有的可变状态，外界改不动。每次调用产出 `$x1`、`$x2`、`$x3`……配合自由变量集合，能保证不会撞名。

### 修改 15：`fv` —— 计算自由变量

```ocaml
let rec fv = function
  | Int _ | Bool _ -> []
  | Var x -> [x]
  | Binop (_, e1, e2)        -> union (fv e1) (fv e2)
  | If (e1, e2, e3)          -> union (union (fv e1) (fv e2)) (fv e3)
  | Let (x, e1, e2)          -> union (fv e1) (remove x (fv e2))
  | Fun (x, e)               -> remove x (fv e)
  | App (e1, e2)             -> union (fv e1) (fv e2)
```

用 list 表示集合，`union`/`remove` 用 List 函数实现。**`Fun` / `Let` 都要从子表达式 FV 里去掉绑定变量** —— 那是它们的"形式参数"，不是自由的。

### 修改 16：`subst` 的 lambda 部分（capture-avoiding）

```ocaml
| App (e1, e2) -> App (subst e1 v x, subst e2 v x)

| Fun (y, body) when y = x -> Fun (y, body)
       (* 案例 1：绑定名就是 x → x 已 shadow，啥都不做 *)

| Fun (y, body) when not (List.mem y (fv v)) ->
    Fun (y, subst body v x)
       (* 案例 2：y 不在 v 的自由变量里 → 直接递归替换 *)

| Fun (y, body) ->
    (* 案例 3：y 出现在 v 的自由变量里 → 会发生 capture！先 α-rename *)
    let y' = gensym () in
    let body' = subst body (Var y') y in
    Fun (y', subst body' v x)
```

**为什么需要案例 3？** PPT 上的反例：

```
let x = z in (fun z -> x)
--> (fun z -> x) {z/x}
```

如果直接进入 `Fun (z, body)` 的"绑定名不同"分支做 `subst x with z`，就会把 body 里的 `x` 换成 `z`，结果变成 `(fun z -> z)`——这是 **identity 函数**，但原意是"忽略参数返回外层的 z"。原本"外层的 z"被 lambda 的形参 `z` **捕获**了。

**修复**：先把形参 `z` 换成新鲜的 `$x1`（即 `body' = subst body (Var "$x1") z`），再代入 `z`：

```
(fun z -> x) {z/x}
= (fun $x1 -> x){z/x}            (* α-rename z → $x1 *)
= (fun $x1 -> z)                  (* 安全地代入 z *)
```

完美避开了 capture。

### 修改 17：small-step `App`

```ocaml
| App (Fun (x, body), v2) when is_value v2 -> subst body v2 x   (* β-归约 *)
| App (e1, e2) when is_value e1 -> App (e1, step e2)            (* 先化简右边 *)
| App (e1, e2) -> App (step e1, e2)                              (* 先化简左边 *)
```

call-by-value：先把函数和参数都化成值，再做 β。

### 修改 18：big-step `Fun` / `App`

```ocaml
| Fun _ -> e                                  (* 函数是值，直接返回 *)
| App (e1, e2) ->
    (match eval_big e1 with
     | Fun (x, body) ->
         let v2 = eval_big e2 in
         eval_big (subst body v2 x)
     | _ -> failwith "Cannot apply a non-function value")
```

完全对应 PPT 的 call-by-value 规则：

```
e1 e2 ==> v
  if e1 ==> fun x -> body
  and e2 ==> v2
  and body{v2/x} ==> v
```

### 修改 19：`run_lambda` 容错驱动 + 跑 5 个样例

`run_lambda` 与 `run_one` 的区别：用 `try … with Failure msg -> …` 包了一层。因为 lambda_test3 (`((fun x -> (fun z -> x)) z) (fun x -> x)`) 含未绑定的 `z`，预期会抛 `Unbound variable`；不包就直接进程崩溃，后面的样例都跑不到。

```ocaml
run_lambda "test/lambda_test1.in";  (* (fun x -> x) (fun y -> y)  → Fun(y, Var y) *)
run_lambda "test/lambda_test2.in";  (* 三层应用                    → Fun(a, Fun(b, Var b)) *)
run_lambda "test/lambda_test3.in";  (* 未绑定 z                    → Failure(Unbound variable) *)
run_lambda "test/lambda_test4.in";  (* (fun y -> y + 1) 5         → Int 6 *)
run_lambda "test/lambda_test5.in"   (* 混合 lambda+let+if         → Int 8 *)
```

---

## 一句话总结每个 Task

| Task | 一句话 |
|---|---|
| 1 | 把 BNF 翻译成 AST、lexer、parser，让 SimPL 语法能被解析。 |
| 2 | 在 small-step / big-step 里加 `If` 分支，按 `Bool` 选支。 |
| 3 | 先给 `subst` 放占位，让 `Let` 规则编译通过。 |
| 4 | 把 `subst` 占位换成递归实现，注意 `Let` 同名变量的 shadow。 |
| 5 | 加 `Fun` / `App`，重构文法层级让 application 左结合且高优先级；写 `fv` + `gensym` + capture-avoiding `subst`；big-step `App` 做 call-by-value β-归约。 |

---

## 文件清单与依赖图

```
project5/
├── dune-project          (项目元数据)
├── bin/
│   ├── dune
│   └── main.ml           ← 修改 1~8、12~19
├── lib/
│   ├── dune
│   ├── ast.ml            ← 修改 9
│   ├── lexer.mll         ← 修改 10
│   └── parser.mly        ← 修改 11
└── test/
    ├── simpl_test1.in    let x = 3110 in x + x
    ├── simpl_test2.in    嵌套 let + if
    └── lambda_test{1..5}.in   5 个 lambda 样例
```

模块依赖：

```
ast.ml ──── parser.mly ──── lexer.mll
   │            │                │
   └────────────┴────────────────┘
                │
              main.ml
```
