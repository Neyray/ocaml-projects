(*66.递归下降：判断括号串是否合法*)
let rec parseS input =
  match input with
  (* TODO: 先 parseS，再匹配 ')'，再 parseS *)
  | '(' :: rest ->begin
    match parseS rest with
    | Some rest1 -> begin
      match rest1 with
      | ')' :: rest2 -> parseS rest2
      | _ -> None
    end 
    | None -> None
  end 
  (* TODO: epsilon 分支 *)
  | _ -> Some input 

let parse input =
  match parseS input with
  | Some [] -> "Success"
  | _ -> "Failed"