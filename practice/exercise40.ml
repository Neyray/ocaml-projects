(*40.按子列表长度排序*)
let sort_by_length lst =
  (* add 函数：把子列表 target 插入到已经按长度排好序的二维列表 lst 中 *)
  let rec add acc target lst =
    match lst with
    (*！！！acc仍是二维列表*)
    | [] -> List.rev (target :: acc)
    | h :: v -> 
        if List.length h < List.length target then 
          add (h :: acc) target v    
        else 
          List.rev (target :: acc) @ lst
  in
  
  (* sort_main 函数：标准的插入排序循环 *)
  let rec sort_main acc lst =
    match lst with
    | [] -> acc  
    | x :: t -> 
        let new_acc = add [] x acc in
        sort_main new_acc t 
  in
  sort_main [] lst


let sort_by_length_elegant lst =
  (* 自定义比较函数：比的不是列表本身，而是它们的 List.length *)
  List.sort (fun l1 l2 -> compare (List.length l1) (List.length l2)) lst

let rec print_result lst=
  let rec print_sub lst=
    print_string "[";
    let rec aux lst=
    match lst with 
    | [] -> ()
    | [x] -> Printf.printf "%d"x 
    | x::t -> Printf.printf "%d;"x;aux t in
    aux lst;
    print_string "]" in
  
  print_string "[";
  let rec print_main lst=
  match lst with
  | [] -> ()
  | [sub] -> print_sub sub
  | sub::v -> print_sub sub;print_string ",";print_main v
in print_main lst;
  print_string "]"

let () =
  let result = sort_by_length [[1;2;3]; [4;5]; [6]; [7;8;9;10]] in
  print_result result