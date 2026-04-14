module type ModType = sig
  val f:int -> int
  val g:int -> int
end

module Mod:ModType =struct
  let f x=x+1
  let g x=x*2
  let h x=x-1
end

let result=Mod.f 3+Mod.g 4
(* let result = Mod.h 5 will fail*)
(*在这个例子中，调用模块中的 f 和 g 是成功的，但是如果想要调用 h 就无法通过静态检
查*)

let()=
  Printf.printf "Result:%d\n" result