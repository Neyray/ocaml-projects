class counter initial =
  object
    val zero = 0
    val mutable x = initial
    (*method 后跟着类中定义的方法*)
    method get = x
    method add = x <- x + 1
    method setzero = x <- zero
  end

(* 创建一个新对象 *)
let count = new counter 3;;
(* 调用 add 方法 *)
count#add;;
let result = count#get