(*12.删除所有匹配元素*)
let rec remove_all n lst=
 let rec aux acc n lst=
 match lst with
 | [] -> List.rev acc
 | x::t ->
  if x<>n then aux (x::acc)n t
  else aux acc n t
in aux [] n lst

let () =
  let res1 = remove_all 2 [1; 2; 3; 2; 4] in
  let res2 = remove_all "a" ["b"; "a"; "a"] in
  let res3 = remove_all 5 [1; 2; 3] in

  (* 打印结果验证 *)
  print_string "res1: "; List.iter (Printf.printf "%d ") res1; print_newline ();
  print_string "res2: "; List.iter (Printf.printf "%s ") res2; print_newline ();
  print_string "res3: "; List.iter (Printf.printf "%d ") res3; print_newline ()