(*65.补全parseA,parseB*)
let rec parseE input =
  (*E -> a A B | b B*)
  match input with
  | 'a' :: rest ->
      begin match parseA rest with
      | Some rest1 -> parseB rest1
      | None -> None
      end
  | 'b' :: rest ->
      parseB rest
  | _ -> None

and parseA input =
    (* TODO: 根据 A -> a B | b 补全 *)
  match input with
  | 'a'::rest -> parseB rest 
  (*！！！匹配上了也要返回rest*)
  | 'b'::rest -> Some rest
  | _ -> None 

and parseB input =
  (* TODO: 根据 B -> b A | a 补全 *)
  match input with
  | 'b'::rest -> parseA rest
  | 'a'::rest -> Some rest 
  | _ -> None 

let parse input =
  match parseE input with
  | Some [] -> "Success"
  | _ -> "Failed"