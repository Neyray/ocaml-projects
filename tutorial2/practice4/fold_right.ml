(*实现一个 fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> ‘b*)
(*从列表的末尾元素开始，将当前元素与“该元素右侧所有部分的折叠结果”通
过操作函数结合，最终将列表归约为单一值*)
let rec fold_right f lst acc=
  match lst with
  | [] -> acc
  (*不能写成尾递归的原因是：这是从右到左进行的，h是单个最左边的元素，
  无法把最右边的元素拎出来，只有先递归了右边的得到acc，再与h进行f运算*)
  | h::t -> f h (fold_right f t acc)

let () =
  Printf.printf "递归版结果: %d\n" (fold_right (-) [1; 3; 4] 2)