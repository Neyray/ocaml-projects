(*实现尾递归函数 sum_iter : int list -> int -> int，对数列进行累加求和。函数接受
一个整数列表和一个初始累加值作为参数，返回累加结果*)
let rec sum_iter lst acc=
  match lst with
  | [] -> acc
  | h :: t -> sum_iter t (h+acc)

let()=
  let result1=sum_iter [2;3;4;5] 1 in
  let many_ones=List.init 9999999(Fun.const 1)in
  let result2=sum_iter many_ones 0 in
  Printf.printf "sum_iter的两个结果为%d,%d" result1 result2