# ocaml-projects

> OCaml 源代码

OCaml 函数式编程练习与项目代码。

**Tags:** `ocaml` `wsl-ubuntu`  
**Language:** OCaml

---

## 笔记

### `function` vs `fun ... -> match ... with`

在 OCaml 中，`function` 只是 `fun x -> match x with` 的语法糖。核心区别在于参数数量和是否需要显式命名参数。

#### `function`：自带模式匹配的单参数函数

兼具"定义单参数匿名函数"和"对该参数进行模式匹配"两个功能，不需要给参数命名，直接捕获并匹配。

```ocaml
let is_zero = function
  | 0 -> true
  | _ -> false
```

#### `fun ... -> match ... with`：标准匿名函数 + 显式匹配

`fun` 仅用于定义匿名函数和绑定参数名，模式匹配需要在函数体内显式写出。

```ocaml
let is_zero = fun x ->
  match x with
  | 0 -> true
  | _ -> false
```

#### 实际例子

```ocaml
(* 使用 fun e -> match e with，显式命名参数 e *)
let rec evaluate : expr -> int option = fun e ->
  match e with ...

(* 用 function 改写，完全等价且更简洁 *)
let rec evaluate : expr -> int option = function ...
```

#### 什么时候用哪个？

| 场景 | 推荐 |
|------|------|
| 单参数函数，函数体直接模式匹配 | `function` |
| 多参数函数，如 `fun x y -> ...` | `fun` |
| 需要在匹配外引用参数本身 | `fun e -> ...`（保留参数名） |
| 匹配前需要先做其他计算 | `fun x -> let y = ... in match y with` |

---

### Module vs Class

- **Module 不能实例化，Class 不能定义变体（type）**
- 本质原因：类型定义属于模块系统，不属于对象系统
- 类（class）是运行时概念，类型（type）是编译时概念，两者不混用

---

### `option` 类型

```ocaml
type 'a option =
  | None
  | Some of 'a    (* 'a 是类型参数，可以是任何类型 *)
```

使用方式：`Some v` 或 `None`

---

### `mutable` vs `ref`

两者都能实现可变状态，但用法不同：

```ocaml
(* mutable：在 record 的 type 定义里声明，用 <- 修改 *)
type account = {
  mutable balance : int
}
let acc = { balance = 100 }
acc.balance <- 200

(* ref：独立的可变引用，用 := 修改，用 ! 读取 *)
let hp = ref 100
hp := !hp - 10
```

- `mutable` 只能在 `type`（record）的字段里声明
- `val x : int ref` 可以在 module type 的签名里声明（因为 `ref` 本身是普通类型）

---

### 封装原则

用 `type` 或 `module` 封装，**只有在需要隐藏实现细节或需要多种实现时才有意义**。