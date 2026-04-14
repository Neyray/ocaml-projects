(*OCaml 中的函子（Functor）是参数化的模块，类似于以模块作为参数和返回值
的一个“函数”*)
module type X = sig
  val x : int
end
(*定义一个函子IncX*)
(*接受模块签名为 X 的模块 M 作为参数*)
(*IncX是模块名*)
module IncX(M: X)=struct
  let x=M.x + 1
end

module A : X=struct let x = 0 end
module B = IncX(A)
let xinB=B.x