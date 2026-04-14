Module 不能实例化，Class 不能定义变体(type)
本质原因是 OCaml 的设计里，类型定义属于模块系统，而不属于对象系统。
类（class）是运行时的概念，类型（type）是编译时的概念，两者不混用

type 'a option =
  | None
  | Some of 'a    (* 'a 是类型参数，可以是任何类型 *)
  使用方式：Some v || None