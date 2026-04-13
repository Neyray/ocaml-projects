(*实现 diff : int list -> int list，求—个数列的差分*)
let rec diff lst=
  let rec aux lst acc=
  match lst with
  | [] -> List.rev acc
  (*把整个 xb :: _ 这个子列表绑定到名字 t，这样递归时直接传 t，相当于从 xb 开始继续处理，避免重复访问元素*)
  | xa::(xb::_ as t) -> aux t ((xb-xa)::acc)
  (*需要倒转列表*)
  | [_] -> List.rev acc
  in
  aux lst []

(* 定义一个打印 int list 的辅助函数 *)
let print_int_list l =
  Printf.printf "[ ";
  List.iter (fun x -> Printf.printf "%d " x) l;
  Printf.printf "]\n"

let () =
  let result1 = diff [1; 2; 3; 4; 5] in
  let result2 = diff [1; 2; 4; 1; 1] in
  let result3 = diff [1; 0; 1; 0; 1; 0; 0] in
  
  (* 分别打印三个结果，不能直接用 %d *)
  Printf.printf "结果1: "; print_int_list result1;
  Printf.printf "结果2: "; print_int_list result2;
  Printf.printf "结果3: "; print_int_list result3

