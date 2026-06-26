(*3.函子+filter*)
module type PREDICATE = sig
  val accept : int -> bool
end

module type FILTER = sig
  val filter : int list -> int list
  val count : int list -> int
end

module Make (P : PREDICATE) : FILTER = struct
  (*Make 是一个函子，接收一个满足 PREDICATE 签名的模块 P，返回一个满足 FILTER 签名的模块*)
  (*不能写死 even/positive，必须调用 P.accept*)
  let filter lst = List.filter P.accept lst   (*直接使用P.accept调用模块内的变量！！！*)
  let count lst = List.length (filter lst)
end