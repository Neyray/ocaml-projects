(*计算列表的累乘*)
let rec prod lst =
  match lst with
   | [] -> 1
   | head :: tail -> head * prod tail

  let()=
    let list=[1;2;3;4;5] in
    let result=prod list in
    Printf.printf "Hello, Jerico! The sum is: %d\n" result
