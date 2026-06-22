(*32.还原游程编码*)
let rec decode lst=
  (*定义一个内置函数*)
  let rec add count target lst=
  match count with
  | 0 -> lst
  | _ -> add (count-1) target (target::lst) in   (*往头部塞，效率更高*)
  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | (x,y)::t -> let new_acc=add x y acc in
  (*！！！add函数产生一个新的列表，用这个新列表继续递归*)
  aux new_acc t in
  aux [] lst 

let () =
  let result = decode [(2, 1); (3, 2); (1, 5)] in
  List.iter (Printf.printf "%d ") result