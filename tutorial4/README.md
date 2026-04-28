# Dune 构建工具指南

## dune 是什么，有什么用

dune 解决的是**多文件项目的编译问题**。

### 没有 dune 时，手动编译多文件很痛苦

假设有 `ast.ml`、`token.ml`、`lexer.ml`、`parser.ml`、`main.ml` 五个文件，手动编译需要：

```bash
# 必须按依赖顺序手动列出每一个文件
ocamlfind ocamlopt -package str -linkpkg \
  ast.ml token.ml lexer.ml parser.ml main.ml \
  -o main
```

文件一多，顺序就很难维护。若用了外部库还要加各种 `-package`、`-linkpkg` 参数，非常繁琐。

### dune 帮你自动完成的事

| dune 做的事 | 等价于手动做什么 |
|---|---|
| 读取 `dune` 文件，知道有哪些模块 | 手动列出所有 `.ml` 文件 |
| 分析模块间依赖，决定编译顺序 | 手动排好 `token → lexer → parser` 的顺序 |
| 调用 `ocamlfind`/`ocamlopt` 编译 | 手动敲一长串编译命令 |
| 增量编译（只重编改过的文件） | 手动判断哪些文件变了 |
| 把库和可执行文件链接在一起 | 手动加 `-linkpkg` 等参数 |

---

## 什么时候需要 dune

| 情况 | 用什么 |
|---|---|
| 单个 `.ml` 文件 | 直接 `ocaml xxx.ml`，不需要 dune |
| 多个 `.ml` 文件互相依赖 | 用 dune，否则手动管理编译顺序很痛苦 |
| 用了外部库（如 `str`、`unix`） | 用 dune，否则要手动写很长的编译命令 |

> **例子：** 练习2只有一个文件，直接 `ocaml ex2.ml` 即可，不需要 dune。练习3有五个文件互相依赖，必须用 dune。

---

## 项目目录结构

使用 dune 的多文件项目推荐以下结构：

```
my_project/
├── dune-project        ← 根目录：整个项目的全局配置
├── lib/                ← 库：放所有逻辑模块
│   ├── dune            ← 声明这个目录是一个库
│   ├── ast.ml
│   ├── token.ml
│   ├── lexer.ml
│   └── parser.ml
└── bin/                ← 可执行程序
    ├── dune            ← 声明这个目录编译出一个可执行文件
    └── main.ml
```

---

## 三个 dune 文件分别写什么

### 1. 根目录：`dune-project`

声明项目使用的 dune 版本，整个项目只需要一个，放在根目录。

```
(lang dune 3.0)
```

### 2. `lib/dune`：声明库

告诉 dune 这个目录里有哪些模块，把它们打包成一个库。

```
(library
 (name my_project)                        (* 库的名字，决定命名空间 *)
 (modules ast token lexer parser))        (* 库由哪些模块组成 *)
```

库名 `my_project` 会变成命名空间 `My_project`，库内的模块在外部通过 `My_project.Lexer`、`My_project.Ast` 等方式访问。

库内部的模块可以直接互相访问，用 `open` 即可：

```ocaml
(* lexer.ml 使用 token.ml 里定义的类型 *)
open Token

(* parser.ml 使用 ast.ml 和 token.ml *)
open Ast
open Token
```

### 3. `bin/dune`：声明可执行文件

告诉 dune 这个目录编译出一个可执行文件，并声明它依赖哪些库。

```
(executable
 (name main)                (* 可执行文件的名字，对应 main.ml *)
 (libraries my_project))    (* 依赖的库，和 lib/dune 里的 name 对应 *)
```

`main.ml` 里使用库时，需要先 `open` 命名空间：

```ocaml
(* main.ml *)
open My_project   (* 打开命名空间，之后可以直接写 Lexer.tokenize *)

let () =
  let tokens = Lexer.tokenize input in
  let ast = Parser.parse tokens in
  print_endline (Ast.print_ast ast)
```

或者不 `open`，每次写全名：

```ocaml
let tokens = My_project.Lexer.tokenize input in
```

---

## 构建与运行

在项目**根目录**下执行：

```bash
# 编译整个项目（dune 自动处理依赖顺序）
dune build

# 运行可执行文件
dune exec bin/main.exe

# 编译 + 运行一步到位（dune 会在运行前自动 build）
dune exec bin/main.exe
```

> **注意：** `dune build` 和 `dune exec` 都必须在项目根目录（含 `dune-project` 的那一层）执行，不能在 `lib/` 或 `bin/` 里执行。

---

## 数据流示意（以练习3为例）

```
输入字符串
"if iszero 0 then succ 0 else pred succ 0"
        ↓  lexer.ml: tokenize
[IF; ISZERO; ZERO; THEN; SUCC; ZERO; ELSE; PRED; SUCC; ZERO]
        ↓  parser.ml: parse
TmIf(TmIsZero(TmZero), TmSucc(TmZero), TmPred(TmSucc(TmZero)))
        ↓  ast.ml: print_ast
"(if (iszero 0) then (succ 0) else (pred (succ 0)))"
```

模块依赖关系：

```
main.ml
  └── Parser   (parser.ml)
        ├── Ast    (ast.ml)    ← 定义 term 类型
        └── Token  (token.ml)  ← 定义 token 类型
  └── Lexer    (lexer.ml)
        └── Token  (token.ml)
  └── Ast      (ast.ml)        ← print_ast
```