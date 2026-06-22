(*27.拍平嵌套列表*)
(*需要定义类型*)
type 'a node=One of 'a | Many of 'a node list 

let flatten_nested lst=
  let rec aux acc remaining=
  match remaining with
  | [] -> List.rev acc
  | x::t ->
    match x with
    | One v -> aux (v::acc) t
    | Many l -> aux acc (l@t)  (*先处理嵌套的l列表*)
  in aux [] lst 

let () =
  let result = flatten_nested [One 1; Many [One 2; One 3]; One 4] in
  List.iter (Printf.printf "%d ") result
  (* 输出: 1 2 3 4 *)