(*29.连续重复元素分组*)
let rec pack lst =
  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | x::t ->
    match acc with
    | [] -> aux [[x]] lst
    | curr::other ->
      (*curr也是列表*)
      match curr with
      | [] -> aux [[x]] lst
      | h::v -> if h=x then aux ((x::curr)::other) t (*由于h=x，所以列表的顺序不重要*)
      else aux ([x]::acc) t
    in 
aux [] lst

(* 辅助打印二维列表的函数 *)
let print_nested_list lst =
  print_string "[";
  let rec print_sub = function   (*print_sub表示单独输出列表*)
    | [] -> () | [x] -> Printf.printf "%d" x | x::t -> Printf.printf "%d;" x; print_sub t
  in
  let rec print_main = function
  (*列表中有列表*)
    | [] -> ()
    | [sub] -> print_string "["; print_sub sub; print_string "]"
    | sub :: t -> print_string "["; print_sub sub; print_string "]; "; print_main t
  in
  print_main lst;
  print_endline "]"

(* 测试 *)
let () =
  let result = pack [1; 1; 2; 2; 2; 3; 1; 1] in
  print_nested_list result
  (* 输出: [[1;1]; [2;2;2]; [3]; [1;1]] *)