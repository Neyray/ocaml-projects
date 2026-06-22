(*25.拆分二元组列表*)
let rec unzip lst=
  let rec aux (acc1,acc2) lst=
  match lst with 
  | [] -> (List.rev acc1,List.rev acc2)
  | (x,y)::t -> aux (x::acc1,y::acc2) t
in aux ([],[]) lst 

let rec print_unzip_result (l1,l2)=
(*分别对l1,l2进行输出*)
  let rec print_ints lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()
  | [x] -> Printf.printf "%d" x
  | x::t -> Printf.printf "%d;" x;
  aux t 
in aux lst;
  print_string "]" in

  let print_strs lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()
  | [x] -> Printf.printf "%S" x
  | x::t -> Printf.printf "%S;" x;aux t
in aux lst;
  print_string "]" in 

  print_string "(";
  print_ints l1;
  print_string ",";
  print_strs l2;
  print_string ")"(*末尾不能加；！！！*)

let () =
  let result=unzip [(1,"a"); (2,"b"); (3,"c")] in
  print_unzip_result result 