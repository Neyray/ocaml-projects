(*实现 count_123 : int list -> int，返回列表中
连续子序列 1 2 3 出现的次数*)
let rec count_123_tail lst=
  let rec aux lst acc=
     match lst with
     | 1::2::3::t -> aux t (acc+1)
     | [] -> acc
     (*如果第一个数字不匹配，直接忽略*)
     | _::t -> aux t acc
  in
  aux lst 0

(*主函数*)
let()=
  let result1=count_123_tail [1;2] in
  let result2=count_123_tail [1;2;3] in
  let result3=count_123_tail [1;2;4;3] in
  let result4=count_123_tail [1;2;3;1;4;2;3;1;2;3;4] in
  Printf.printf "/ncount_123_tail的四个结果为%d,%d,%d,%d/n" result1 result2 result3 result4
