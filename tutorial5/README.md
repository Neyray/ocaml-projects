# Tutorial 5：解释器的工作原理

> 本 README 聚焦于 **解释器的内部工作流程** 与 **`.mll` / `.mly` 文件的语法**。
> dune 构建系统相关内容请参考 `tutorial4/README.md`，本文不再重复。

---

## 1. 解释器三阶段流水线

一个最小的解释器就是把 **源代码字符串** 一路变换为 **求值结果**。整个过程由三个阶段串起来：

```
源代码字符串                    Token 流                       AST                  值
"let x = 1 in x + 2"  ──►   [LET; ID "x"; EQ; INT 1;  ──►  Let("x", Int 1,    ──►  Int 3
                              IN; ID "x"; PLUS; INT 2]      Binop(Add,Var "x",
                                                                  Int 2))
                ▲ Lexer (lexer.mll)   ▲ Parser (parser.mly)        ▲ Evaluator (main.ml)
                  词法分析                语法分析                     求值
```

| 阶段 | 输入 | 输出 | 由谁完成 |
|---|---|---|---|
| **Lexing**（词法分析） | 字符串 | Token 流 | `lexer.mll` |
| **Parsing**（语法分析） | Token 流 | AST | `parser.mly` |
| **Evaluation**（求值） | AST | 值 | `main.ml` 里的 `step` / `eval` |

三个文件之间的依赖关系：

```
   ast.ml          ←── 只定义类型，不依赖任何人
     ▲
     │ open Ast
     │
   parser.mly      ←── 解析时构造 AST 节点，所以必须 open Ast
     ▲
     │ open Parser  (因为 lexer 要返回 parser 里声明的 token)
     │
   lexer.mll       ←── 把字符变成 Parser 里的 token
     ▲
     │
   main.ml         ←── 调 Lexer.read + Parser.main 拿到 AST，再求值
```

**关键点**：lexer 之所以要 `open Parser`，是因为 token 类型（`PLUS`、`INT`、`IF` 等）由 Menhir 在编译 `parser.mly` 时生成在 `Parser` 模块里。Lexer 自己不定义 token，它只是 token 的"生产者"。

---

## 2. `ast.ml`：先有类型，才有一切

AST（抽象语法树）是整个解释器的"公共语言"。Parser 把字符串解析出来后塞进 AST，Evaluator 拿到 AST 后做模式匹配求值。所以**第一件事永远是先把 AST 类型写好**。

SimPL 的 AST 类型：

```ocaml
type binop =
  | Add | Sub | Mul | Leq

type expr =
  | Int of int                          (* 整数字面量 *)
  | Bool of bool                        (* 布尔字面量 *)
  | Var of string                       (* 变量引用 *)
  | Binop of binop * expr * expr        (* 二元运算 *)
  | If of expr * expr * expr            (* if e1 then e2 else e3 *)
  | Let of string * expr * expr         (* let x = e1 in e2 *)
```

**思维模型**：AST 类型就是把 BNF 文法**一条一条翻译成 OCaml 的 sum type**。BNF 里每个 `|` 分支对应一个构造器。

| BNF | AST 构造器 |
|---|---|
| `e ::= i` | `Int of int` |
| `e ::= b` | `Bool of bool` |
| `e ::= x` | `Var of string` |
| `e ::= e1 bop e2` | `Binop of binop * expr * expr` |
| `e ::= if e1 then e2 else e3` | `If of expr * expr * expr` |
| `e ::= let x = e1 in e2` | `Let of string * expr * expr` |

---

## 3. `lexer.mll`：ocamllex 语法

`.mll` 文件由 **ocamllex** 编译为 `.ml`。它是一个 DSL，本质是"正则表达式 → OCaml 代码"的映射表。

### 3.1 文件骨架

```
{ header (OCaml 代码) }            (* 1. 头部：可选的 OCaml 代码，通常 open Parser *)

let name = regex                   (* 2. 命名正则：方便复用 *)

rule entry_name = parse            (* 3. 规则入口：词法分析的"主函数" *)
  | regex1 { action1 }
  | regex2 { action2 }
  ...
  | eof    { EOF }
  | _      { failwith "..." }      (* 兜底规则 *)

{ trailer (OCaml 代码) }            (* 4. 尾部：可选 *)
```

### 3.2 我们 lexer.mll 的对应关系

| 规则 | 含义 |
|---|---|
| `{ open Parser }` | 头部：让 PLUS、INT 等 token 构造器可见 |
| `let letter = ['a'-'z' 'A'-'Z']` | 命名正则，后面用 `letter+` 表示一段字母 |
| `rule read = parse` | 入口 `read`，main.ml 里调 `Lexer.read` |
| `[' ' '\t' '\n'] { read lexbuf }` | 遇到空白字符，丢掉并递归继续读下一个 token |
| `['0'-'9']+ as num { INT (int_of_string num) }` | 数字 → `INT` 携带值 |
| `"<=" { LEQ }` | 多字符运算符直接整体匹配 |
| `"if" { IF }` | 关键字 |
| `letter+ as id { ID id }` | 标识符 |
| `eof { EOF }` | 文件结束 |
| `_ { failwith "Invalid character" }` | 兜底：其它字符报错 |

### 3.3 三条容易踩坑的规则

1. **最长匹配 + 首条优先**：ocamllex 自动选择 **匹配最长字符串** 的规则；若多条规则匹配相同长度，则取**最先声明**的那条。所以 `"if"` 一定要写在 `letter+` 之前，否则 `"if"` 会被识别成 `ID "if"`。

2. **空白要主动丢弃**：词法分析器不会自动跳过空格，必须显式写一条规则，匹配到就**递归调用自己** `{ read lexbuf }` 继续读下一个 token。

3. **`as` 绑定捕获的文本**：`['0'-'9']+ as num` 把匹配到的字符串绑定到 `num`，再在 action 里 `int_of_string num` 转成整数塞进 `INT` 构造器。

---

## 4. `parser.mly`：Menhir 语法

`.mly` 文件由 **Menhir**（或更老的 ocamlyacc）编译为 `.ml`。它描述一个上下文无关文法 (CFG)，外加每条规则对应的"语义动作"（即构造 AST 节点）。

### 4.1 文件骨架

```
%{
  (* 1. 头部 OCaml 代码，通常 open Ast *)
%}

%token <int> INT                   (* 2. 声明 token 类型 *)
%token PLUS MINUS IF THEN ...

%left  PLUS MINUS                  (* 3. 运算符结合性与优先级 *)
%left  TIMES
%nonassoc IN ELSE

%start <Ast.expr> main             (* 4. 入口非终结符与类型 *)

%%                                 (* 5. 文法规则与语义动作 *)

main:
    expr EOF { $1 }
;

expr:
    | INT                               { Int $1 }
    | expr PLUS expr                    { Binop (Add, $1, $3) }
    | IF expr THEN expr ELSE expr       { If ($2, $4, $6) }
    ...
;
```

### 4.2 我们 parser.mly 的关键点

- **`%token <int> INT`**：表示 `INT` 这个 token 携带一个 `int` 类型的值（lexer 里写的 `INT (int_of_string num)` 就是把这个值塞进去）。不带值的 token 直接 `%token PLUS MINUS`。
- **`$1`、`$2`、`$3`** 指代规则右侧第 1、2、3 个文法符号的值。例如 `expr PLUS expr { Binop (Add, $1, $3) }`，`$1` 是左 `expr` 的值，`$3` 是右 `expr` 的值（`$2` 是 `PLUS`，对应一个 unit 值）。
- **`%left PLUS MINUS`**：声明 `+ -` 为**左结合**。`a - b - c` 会被解析为 `(a - b) - c`。
- **优先级由声明顺序决定**：写在**后面**的优先级**更高**。所以 `%left PLUS MINUS` 在 `%left TIMES` 之前，意味着 `*` 比 `+` 优先级高，`1 + 2 * 3` 会解析成 `1 + (2 * 3)`。
- **`%nonassoc IN ELSE`**：解决 `if`/`let` 引发的 shift-reduce 冲突，告诉 Menhir 这些 token 不参与结合。

### 4.3 文法的"二元运算歧义"

```
expr:
    | expr PLUS expr  { Binop (Add, $1, $3) }
    | expr TIMES expr { Binop (Mul, $1, $3) }
```

这种写法是**有歧义**的——Menhir 不知道 `1 + 2 * 3` 到底是 `(1+2)*3` 还是 `1+(2*3)`。我们靠 **优先级声明 (`%left`)** 来消除歧义，而不是改写文法。这种风格叫 **operator-precedence parsing**，比传统的"分层文法"（`expr → term + expr`、`term → factor * term`）简洁很多。

---

## 5. `main.ml` 的核心函数

`main.ml` 里没有什么魔法，它只是把 lexer + parser + evaluator 串起来。下面按"调用顺序"讲。

### 5.1 `parse`：字符串 → AST

```ocaml
let parse s : expr =
  let lexbuf = Lexing.from_string s in   (* 把字符串包装成 lexbuf *)
  Parser.main Lexer.read lexbuf          (* parser 反复向 lexer 索取 token *)
```

`Parser.main` 接受一个**回调函数**（即 `Lexer.read`），每次需要下一个 token 时就调用它。这是**惰性流式**的——token 不是一次性全部生成的，而是按需取。

### 5.2 `is_value`：判断"算到底了没有"

```ocaml
let is_value : expr -> bool = function
  | Int _ | Bool _ -> true
  | _ -> false
```

**值** (value) 是已经无法继续化简的表达式。在 SimPL 里只有整数和布尔是值；`Var`、`Binop`、`If`、`Let` 都还可以继续化简。

### 5.3 `step`：执行一步小步 (small-step)

`step` 实现的是 **小步语义** 的核心规则：

| 规则 | 说明 |
|---|---|
| `v1 bop v2 --> v` | 两边都是值时，调 `step_binop` 做真正的计算 |
| `v1 bop e2 --> v1 bop e2'`  | 左边已经是值，递归 step 右边 |
| `e1 bop e2 --> e1' bop e2`  | 否则先 step 左边 |

```ocaml
let rec step : expr -> expr = function
  | Int _ | Bool _ -> failwith "Does not step on a value"
  | Var _ -> failwith "Unbound variable"            (* 变量无法 step：要么早被代换掉，要么是未绑定的 *)
  | Binop (op, e1, e2) when is_value e1 && is_value e2 -> step_binop op e1 e2
  | Binop (op, e1, e2) when is_value e1            -> Binop (op, e1, step e2)
  | Binop (op, e1, e2)                              -> Binop (op, step e1, e2)
  | If _   -> failwith "TODO Task 2"
  | Let _  -> failwith "TODO Task 3"
```

**注意三个 `Binop` 分支的顺序**：必须先匹配"两边都是值"，再匹配"左边是值"，最后是兜底。OCaml 的模式匹配是按声明顺序匹配的，写反了语义就错了。

### 5.4 `step_binop`：原语操作 (primitive operation)

```ocaml
and step_binop binop v1 v2 = match binop, v1, v2 with
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"
```

`step_binop` 与 `step` 是**互递归** (`let rec ... and ...`) 的：`step` 把"还要继续 step"的情况交给自己，把"两边都是值，可以真正算"的情况交给 `step_binop`。

> 为什么不把 `step_binop` 内联进 `step`？因为这是 **语法 (syntax) 与 语义 (semantics) 的分离**：`step` 处理"该往哪里走"的语法结构，`step_binop` 处理"+ 是加法"这种与具体值相关的语义。分开后将来扩展新运算符只动一处。

### 5.5 `eval` 与 `eval_big`：两种求值策略

```ocaml
(* 小步：反复 step 直到变成值 *)
let rec eval (e : expr) : expr =
  if is_value e then e
  else e |> step |> eval

(* 大步：直接递归求值，不暴露中间步骤 *)
let rec eval_big (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (op, e1, e2) -> eval_bop op e1 e2
  | If _ | Let _ -> failwith "TODO"

and eval_bop op e1 e2 = match op, eval_big e1, eval_big e2 with
  | Add, Int a, Int b -> Int (a + b)
  ...
```

**两种语义对比**：

|  | small-step (`eval`) | big-step (`eval_big`) |
|---|---|---|
| 思路 | 一次只前进一步：`e → e1 → e2 → … → v` | 直接"算到底"：`e ⇒ v` |
| 实现 | 外层循环 + `step` 函数 | 一个递归函数 |
| 适合 | 建模复杂控制流（异常、并发、中断） | 写真实解释器 |
| 中间过程 | 可见，方便 debug | 不可见 |

二者对**同一个程序得到的最终值是一样的**——这就是为什么大步语义可以定义成"小步语义的反身传递闭包"：`e ⇒ v` 当且仅当 `e -->* v`。

### 5.6 `interp` / `interp_big`：完整流水线

```ocaml
let interp     s = s |> parse |> eval     |> string_of_expr
let interp_big s = s |> parse |> eval_big |> string_of_expr
```

`|>` 是 OCaml 的管道运算符：`x |> f` 等价于 `f x`。整行读起来就是"字符串 → AST → 值 → 字符串"。

### 5.7 `string_of_expr`：把 AST 打印回字符串

求值过程返回的也是一个 `expr`（最终是 `Int n` 或 `Bool b`）。要让人看得懂，再用 `string_of_expr` 递归地把它打成可读形式：`Binop (Add, Int 1, Int 2)`、`Let (x, Int 3110, Binop (Add, Var x, Var x))` 等等。

---

## 6. 把它们连起来：一次完整执行

以 `let x = 3110 in x + x` 为例：

```
┌─ Lexer.read 逐 token 产出 ──────────────────────────────────────┐
│   LET, ID "x", EQUALS, INT 3110, IN, ID "x", PLUS, ID "x", EOF │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼  Parser.main 按文法归约，调用语义动作构造 AST
┌─ AST ──────────────────────────────────────────────────────┐
│   Let ("x", Int 3110, Binop (Add, Var "x", Var "x"))       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼  eval 反复 step（需要 Task 3 实现 Let / 代换）
┌─ 值 ────────┐
│   Int 6220  │
└─────────────┘
                              │
                              ▼  string_of_expr
                          "Int 6220"
```

---

## 7. 任务进度提示

| Task | 内容 | 涉及文件 | 所在目录 |
|---|---|---|---|
| Task 1 | SimPL 解析（AST + lexer + parser + `string_of_expr`） | `ast.ml`、`lexer.mll`、`parser.mly`、`main.ml` | `project1/` |
| Task 2 | `if` 语句的求值 | `main.ml`（`step`、`eval_big` 的 `If` 分支） | `project2/` |
| Task 3 | `let` 语句的基本求值（先放 `subst` 占位） | `main.ml`（`step`、`eval_big` 的 `Let` 分支） | `project3/` |
| Task 4 | 真正实现 `subst`（替换） | `main.ml` | `project3/` |
| Task 5 | Lambda Calculus 解释器 + capture-avoiding subst | 全套文件 | `project3/` |

---

## 8. 怎么测试 Task 1–5

每个 project 目录都是一个独立的 dune 工程，结构相同：

```
projectN/
├── bin/main.ml                    # 入口（含 string_of_expr / parse / eval / interp 等）
├── lib/                           # ast.ml, lexer.mll, parser.mly
└── test/
    ├── simpl_test1.in             # 测试输入 1（Task 1/3/4 用）
    ├── simpl_test2.in             # 测试输入 2（Task 2/4 用）
    └── lambda_test1.in ~ 5.in     # Lambda 测试（Task 5 用）
```

### 8.0 通用流程

```bash
cd projectN          # N = 1, 2, 3
dune build           # 编译
dune exec interpreter_project       # 运行
```

`bin/main.ml` 末尾有一段"驱动代码"，控制读哪个测试文件、调用 `interp` / `interp_big` 还是只打印 AST。**测试不同 Task 时只需调整这两处**：

```ocaml
let () =
  let filename = "test/simpl_test1.in" in       (* ① 切换测试文件 *)
  (* let filename = "test/simpl_test2.in" in *)
  ...
  (* ② 用注释块控制是否调用 interp / interp_big *)
  (* let res = interp file_content in
     Printf.printf "Result of interpreting %s:\n%s\n\n" filename res;
     let res = interp_big file_content in
     Printf.printf "Result of interpreting %s with big-step model:\n%s\n\n" filename res; *)

  let ast = parse file_content in
  Printf.printf "AST: %s\n" (string_of_expr ast)
```

> 切换测试文件 = 移动那行注释；启用求值 = 去掉 `interp` / `interp_big` 那段注释。

---

### 8.1 Task 1 — 仅解析（`project1/`）

**测试输入**：
- `test/simpl_test1.in` → `let x = 3110 in x + x`
- `test/simpl_test2.in` → `if x <= 3 then true else false`

**main.ml 设置**：保持默认，只 `parse` + `string_of_expr`（`interp` / `interp_big` 那段注释**不要去掉**，因为求值还没实现）。

**运行**：

```bash
cd project1
dune build
dune exec interpreter_project
```

**期望输出**（`simpl_test1.in`）：

```
AST: Let (x, Int 3110, Binop (Add, Var x, Var x))
```

切到 `simpl_test2.in` 再跑一次，期望：

```
AST: If (Binop (Leq, Var x, Int 3), Bool true, Bool false)
```

---

### 8.2 Task 2 — `if` 求值（`project2/`）

**测试输入**：
- `test/simpl_test2.in` → `if 2 <= 3 then false else true`（Task 2 重点）

**main.ml 设置**：
1. 把 `filename` 切到 `simpl_test2.in`
2. **去掉 `interp` / `interp_big` 那段注释**，让小步与大步求值都打印出来

**运行**：

```bash
cd project2
dune build
dune exec interpreter_project
```

**期望输出**：

```
Result of interpreting test/simpl_test2.in:
Bool false

Result of interpreting test/simpl_test2.in with big-step model:
Bool false

AST: If (Binop (Leq, Int 2, Int 3), Bool false, Bool true)
```

> 注意：此版本还没实现 `Let` 的求值，所以**不要**在 Task 2 阶段对 `simpl_test1.in`（含 `let`）启用 `interp`，会 `failwith "TODO: Task 3"`。

---

### 8.3 Task 3 — `let` 基本求值，`subst` 仍是占位（`project3/`，进行中）

**测试输入**：`test/simpl_test1.in` → `let x = 3110 in x + x`

**main.ml 设置**：切到 `simpl_test1.in`，启用 `interp`。

**期望输出**：因为 `subst` 还是 `failwith "TODO: implement substitution"`，程序应该崩在那一行：

```
Fatal error: exception Failure("TODO: implement substitution")
```

这说明 `step` / `eval_big` 的 `Let` 分支**已经走到了 `subst` 调用**——正是 Task 3 想验证的事。

---

### 8.4 Task 4 — 实现 `subst` 后的完整 SimPL（`project3/`）

**测试输入**：
- `test/simpl_test1.in` → `let x = 3110 in x + x`
- `test/simpl_test2.in` → `let y = 6 in let x = 5 * 6 in if x <= 30 - y then x - 1 else y + 1`

> Task 4 阶段建议**把 `simpl_test2.in` 改写成上面这个嵌套 let 版本**（覆盖 `let` + `if` + 算术），原本那个纯 `if` 的可以挪去做单测。

**main.ml 设置**：切到对应文件，启用 `interp` 和 `interp_big`。

**期望输出**（`simpl_test1.in`）：

```
Result of interpreting test/simpl_test1.in:
Int 6220

Result of interpreting test/simpl_test1.in with big-step model:
Int 6220

AST: Let (x, Int 3110, Binop (Add, Var x, Var x))
```

**期望输出**（嵌套 let 版 `simpl_test2.in`）：

```
Result of interpreting test/simpl_test2.in:
Int 7

Result of interpreting test/simpl_test2.in with big-step model:
Int 7

AST: Let (y, Int 6, Let (x, Binop (Mul, Int 5, Int 6),
     If (Binop (Leq, Var x, Binop (Sub, Int 30, Var y)),
         Binop (Sub, Var x, Int 1),
         Binop (Add, Var y, Int 1))))
```

---

### 8.5 Task 5 — Lambda Calculus 解释器（`project3/`）

Task 5 需要在 SimPL 的基础上**扩展 AST**（新增 `Fun` 与 `App`）、**扩展 lexer / parser**（新增 `FUN`、`ARROW` 等 token 与函数应用规则），并实现**capture-avoiding substitution**（带 `gensym` 生成新名字）。建议只做大步语义即可。

**测试输入**（写到 `test/lambda_test1.in` ~ `lambda_test5.in`）：

| 文件 | 内容 | 期望结果 |
|---|---|---|
| `lambda_test1.in` | `(fun x -> x) (fun y -> y)` | `Fun (y, Var y)`（即 `fun y -> y`） |
| `lambda_test2.in` | `(fun x -> fun x -> x) (fun a -> fun b -> a) (fun a -> fun b -> b)` | `fun a -> fun b -> b` |
| `lambda_test3.in` | `((fun x -> (fun z -> x)) z) (fun x -> x)` | 抛 `Unbound variable`（自由变量 `z`） |
| `lambda_test4.in` | `(fun y -> y + 1) 5` | `Int 6` |
| `lambda_test5.in` | `(fun x -> let y = 6 in let x = 5 * 6 in if x <= 30 - y then x - 1 else y + 2) 10` | `Int 8` |

**main.ml 设置**：建议把驱动改成"依次跑所有 lambda 测试文件"。例如：

```ocaml
let () =
  let files = [
    "test/lambda_test1.in"; "test/lambda_test2.in"; "test/lambda_test3.in";
    "test/lambda_test4.in"; "test/lambda_test5.in";
  ] in
  List.iter (fun f ->
    let ic = open_in f in
    let s = really_input_string ic (in_channel_length ic) in
    close_in ic;
    Printf.printf "=== %s ===\nInput: %s\n" f (String.trim s);
    (try Printf.printf "Result: %s\n\n" (interp_big s)
     with Failure msg -> Printf.printf "Exception: %s\n\n" msg)
  ) files
```

**运行**：

```bash
cd project3
dune build
dune exec interpreter_project
```

---

### 8.6 测试遇到问题时的排查清单

| 现象 | 可能原因 |
|---|---|
| `Pattern matching failed` | `match ... with` 嵌套没加括号，把后面的分支吞了 → 用 `(match ... with ...)` 或 `begin match ... end` |
| `Operator and operand type mismatch` | `step_binop` / `eval_bop` 收到了非 `Int` 操作数（比如 `Bool` 出现在算术里） |
| `Unbound variable` | 走到了 `Var _` 分支——要么 Task 3/4 的 `subst` / `let` 还没接好，要么源码里真的有自由变量 |
| `TODO: implement substitution` | 进度正常，Task 4 还没做 |
| `dune: command not found` | 没进 opam 环境，先 `eval $(opam env)` |
| 改了 `parser.mly` / `lexer.mll` 没生效 | 删 `_build/` 后再 `dune build` |
