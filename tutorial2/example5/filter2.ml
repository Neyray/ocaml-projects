(*尾递归版本*)
let filter p lst=
  let rec aux acc lst=
    match lst with
    | [] -> List.rev acc
    | x :: xs -> if p x then aux (x :: acc) xs
    else aux acc xs
  in
  aux [] lst