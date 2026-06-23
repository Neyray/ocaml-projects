(*39.从列表中选k个元素并随机排列*)
let rec combinations k lst=
  if k=0 then [[]]
  else if k<0 then []
  else if k>List.length lst then []
  else begin
    match lst with
    | [] -> []
    | x::t ->
      let with_x=combinations (k-1) t in
      let with_x_applied=List.map (fun l -> x::l)with_x in
      let without_x=combinations k t in
    with_x_applied@without_x 
  end 

let print_result lst =
  (* 打印内部的单层列表，如 [1; 2] *)
  let rec print_sub sub_lst =
    print_string "[";
    let rec aux = function
      | [] -> ()
      | [x] -> Printf.printf "%d" x
      | x :: t -> Printf.printf "%d;" x; aux t
    in
    aux sub_lst;
    print_string "]"
  in
  
  (* 打印外层的大列表，并用逗号隔开子列表 *)
  print_string "[";
  let rec print_main = function
    | [] -> ()
    | [sub] -> print_sub sub
    | sub :: t -> print_sub sub; print_string ", "; print_main t
  in
  print_main lst;
  print_endline "]" (* 自动换行 *)

let () =
  let result = combinations 2 [1; 2; 3] in
  print_result result