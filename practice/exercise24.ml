(*24.合并两个列表为二元组列表*)
let rec zip_opt lst1 lst2=
  let rec aux acc lst1 lst2=
  match lst1,lst2 with
  | [],[] -> Some (List.rev acc)
  | _,[] -> None
  | [],_ -> None 
  | x1::t1,x2::t2 ->
    aux ((x1,x2)::acc) t1 t2
  in aux [] lst1 lst2

(* 辅助打印元组列表的函数 *)
let print_result = function
  | None -> print_endline "None"
  | Some lst ->
      print_string "Some [";
      let rec aux = function
        | [] -> ()
        | [(x, y)] -> Printf.printf "(%d, %S)" x y
        | (x, y) :: t -> Printf.printf "(%d, %S); " x y; aux t
      in
      aux lst;
      print_endline "]"

      (* 测试用例 *)
let () =
  print_result (zip_opt [1; 2; 3] ["a"; "b"; "c"]); (* 输出: Some [(1, "a"); (2, "b"); (3, "c")] *)
  print_result (zip_opt [1; 2] ["a"; "b"; "c"]);    (* 输出: None *)
  print_result (zip_opt [] [])                      (* 输出: Some [] *)