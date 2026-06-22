(*30.游程编码，把连续重复元素编码为 (出现次数, 元素)。*)
let rec encode lst =
  let rec aux acc count lst=
  match lst with
  | [] -> List.rev acc
  | [x] -> List.rev ((count,x)::acc)
  | a::(b::t as l) -> if a=b then aux acc (count+1) l
  else aux ((count,a)::acc) 1 l
in aux [] 1 lst 


(*“看 acc 车头”写法*)
let encode1 lst =
  let rec aux acc remainder =
    match remainder with
    | [] -> List.rev acc
    | x :: t ->
        match acc with
        | (count, v) :: other_groups when v = x ->
            (* 如果当前元素 x 和结果集车头的元素 v 一样，直接把车头的计数器 +1 *)
            aux ((count + 1, v) :: other_groups) t
        | _ ->
            (* 如果不一样或者是第一次，新开一个计数为 1 的元组压入 acc *)
            aux ((1, x) :: acc) t
  in
aux [] lst

let rec print_result lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()
  | [(x,y)] -> Printf.printf "(%d,%d)"x y
  | (x,y)::t -> Printf.printf "(%d,%d);"x y;
  aux t
in aux lst;
  print_string "]"

let () =
  let result=encode [1;1;2;2;2;3;1] in
  print_result result 