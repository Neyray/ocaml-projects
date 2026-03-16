(*非尾递归版本*)
(*filter会用谓词函数（predicate）检查列表中所有元素 ，只保留返回值为 true 的元素*)
(*这里的p就是特定的规则，以此来进行筛选*)
let rec filter p lst=
  match lst with
  | [] -> []
  | x :: xs -> if p x then x :: filter p xs
  else filter p xs