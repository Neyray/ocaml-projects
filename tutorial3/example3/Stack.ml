module type Stack=sig
  type 'a t

  (*当栈为空时抛出Empty异常*)
  exception Empty
  (*创建一个空栈*)
  val empty : 'a t
  (*判断栈是否为空*)
  val is_empty : 'a t -> bool
  (*将元素推入栈*)
  val push : 'a -> 'a t -> 'a t
  (*返回栈顶元素*)
  val peek : 'a t -> 'a
  (*弹出栈顶元素*)
  val pop : 'a t -> 'a t
  (*返回栈的大小*)
  val size : 'a t -> int
  (*将栈转换为列表*)
  val to_list : 'a t -> 'a list
end

module ListStack : Stack = struct
 type 'a t = 'a list
 exception Empty
 let empty = []
 let is_empty = function [] -> true | _ -> false
 let push = List.cons
 let peek = function [] -> raise Empty | x :: _ -> x
 let pop = function [] -> raise Empty | _ :: s -> s
 let size = List.length
 let to_list = Fun.id
end