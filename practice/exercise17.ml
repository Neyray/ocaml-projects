(*17.在指定位置拆分列表*)
let rec split_at n lst=
  if n<=0 then ([],lst)
  else begin
    (*acc里面保存的是放在左边的部分*)
    let rec aux acc n lst=
    match n,lst with
    | 1,x::t -> ((List.rev (x::acc)),t)
    | _,x::t -> aux (x::acc) (n-1) t
    | _,[] -> ((List.rev acc),[])
  in aux [] n lst
end 

let () =
  let (l1, r1) = split_at 3 [1; 2; 3; 4; 5] in


  (* 辅助打印元组列表的函数 *)
  let print_list lst = List.iter (Printf.printf "%d ") lst in
  
  print_string "res1: ( "; print_list l1; print_string ", "; print_list r1; print_endline ")";
