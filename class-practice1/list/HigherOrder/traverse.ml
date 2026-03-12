let rec fold_left (f : 'a -> 'b -> 'a) (acc : 'a) (lst : 'b list): 'a =
  match lst with 
  | [] -> acc
  | h::t -> fold_left f (f acc h) t

let () =
  (* 测试对列表求和：0 + 1 + 2 + 3 + 4 *)
  let sum = fold_left (+) 0 [1; 2; 3; 4] in
  Printf.printf "fold_left 求和结果: %d\n" sum