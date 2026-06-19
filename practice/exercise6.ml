(*6.判断是否是回文序列*)
let rec is_palindrome lst1 =
 let lst2 =List.rev lst1 in
 let rec aux lst1 lst2 =
  match lst1,lst2 with
  | [],[] -> true
  | a::t1,b::t2 -> 
    if a=b then aux t1 t2
    else false
  | _ -> false (*一定不要忘了兜底分支*)
  in aux lst1 lst2

let () =
  let result1 = is_palindrome [1; 2; 3; 2; 1] in
  let result2 = is_palindrome ["a"; "b"; "c"] in
  
  Printf.printf "result1: %b\n" result1; (* 输出 true *)
  Printf.printf "result2: %b\n" result2  (* 输出 false *)