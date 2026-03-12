let rec fact x =
  if x = 0 then 1
  else x * (fact [@tailcall]) (x-1)   (*直接编译看有没有报错*)

let () =
  Printf.printf "5 的阶乘 (非尾递归): %d\n" (fact 5)