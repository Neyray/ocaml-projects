(*实现—个操作数组的函数 smallbf，接受两个参数 mem : int list 和 cmd : string，其
中 cmd 只包含两个字符 + 和 > 。对整个列表进行处理*)

let smallbf mem cmd =
  (* left 存放指针左侧的元素（逆序），right 存放指针及右侧元素 *)
  let rec aux left right i=
  (*编译器实际上就是从这里判断cmd的类型的*)
  (*写成string.length就是string，如果写成list.length，那么就会判断为list*)
  if i=String.length cmd then 
    (*合并列表并进行倒置*)
    List.rev left @ right
  else
    match cmd.[i] with
    | '+' ->
        (*主要就是处理right部分，因为left是已经跳过的*)
        (*所以当cmd.[i]为>时，把头结点h加入到left中*)
        (*在cmd.[i]为+时，把头结点加一后继续放在right列表中*)
        (match right with
        | h::t -> aux left ((h + 1) :: t) (i + 1)
        | [] -> aux left right (i+1))
    | '>' ->
        (match right with
        (*如果只有一个元素，那么就直接跳到第一个元素*)
        | [h] -> aux [] (List.rev(h::left)) (i+1)
        | h::t -> aux (h::left) t (i+1)
        | [] -> aux left right (i+1))
    (*如果是非法字符的话，直接忽略*)
    | _ -> aux left right (i+1)
  in
  aux [] mem 0

(* 测试代码 *)
let () =
  let print_list l = 
    Printf.printf "[ "; List.iter (Printf.printf "%d ") l; Printf.printf "]\n" in
  
  print_list (smallbf [0; 0; 0] "++>>+>++");          (* 输出 [4; 0; 1] *)
  print_list (smallbf [3; 0; -1; -2] "+>+++++>>>>");  (* 输出 [4; 5; -1; -2] *)
  print_list (smallbf [42] ">>>>>>++>+>>");           (* 输出 [45] *)