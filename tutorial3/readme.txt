1.Module 不能实例化，Class 不能定义变体(type)
本质原因是 OCaml 的设计里，类型定义属于模块系统，而不属于对象系统。
类（class）是运行时的概念，类型（type）是编译时的概念，两者不混用

2.type 'a option =
  | None
  | Some of 'a    (* 'a 是类型参数，可以是任何类型 *)
  使用方式：Some v || None



3.(* type 里用 mutable，修改用 <- *)
type account = {
  mutable balance : int
}
let acc = { balance = 100 }
acc.balance <- 200        (* <- 修改 mutable 字段 *)

(* ref 修改用 := *)
let hp = ref 100
hp := !hp - 10            (* := 修改 ref，!hp 读取 ref *)


4.mutable 只能在 type（record）的字段里声明
val x : int ref 可以在 module type 的签名里声明（因为 ref 本身就是个普通类型）



5.用 type 或 module 封装，只有在需要隐藏实现细节或需要多种实现时才有意义