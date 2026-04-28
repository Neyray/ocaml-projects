(*实现递归下降分析，实现parse函数*)
(* 分析 E -> aAB | bB *)
let rec parseE input=
  match input with
  | 'a' :: rest ->
    let rest1=parseA rest in
    parseB rest1
  | 'b' :: rest -> parseB rest
  | _ -> failwith "error in parseE"


(* 分析 A -> aB | b *)
and parseA input=
  match input with
  | 'a' :: rest -> parseB rest
  (*消耗一个b之后直接返回剩下的*)
  | 'b' :: rest -> rest 
  | _ -> failwith "error in parseA"


(* 分析 B -> bA | a *)
and parseB input=
  match input with
  | 'b' :: rest -> parseA rest
  | 'a' :: rest -> rest
  | _ -> failwith "error in parseB"


let check input=
  match parseE input with
  | [] -> print_endline("success")
  | _ -> print_endline("failure")
  | exception _ -> print_endline("error")


let()=
  let test_input=['a';'a';'a';'a'] in
  check test_input