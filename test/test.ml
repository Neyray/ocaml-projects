(* 定义一个递归函数计算阶乘 *)
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

(* 定义一个主函数 *)
let () =
  let number = 5 in
  let result = factorial number in
  (* %d 是整数占位符，\n 是换行 *)
  Printf.printf "你好, jerico! %d 的阶乘结果是: %d\n" number result