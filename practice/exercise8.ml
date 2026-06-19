(*8.返回最大值*)
let rec max_opt lst=
 match lst with
 | [] -> None
 | first :: remaining ->
  let rec aux acc lst=
  match lst with
  | [] -> Some acc
  | x::t ->
    if x>acc then aux x t
    else aux acc t
  in aux first remaining

let () =
  let res1 = max_opt [3; 1; 7; 2] in
  let res2 = max_opt [-5; -2; -10] in
  let res3 = max_opt [] in

  (match res1 with Some x -> Printf.printf "res1: %d\n" x | None -> Printf.printf "res1: None\n");
  (match res2 with Some x -> Printf.printf "res2: %d\n" x | None -> Printf.printf "res2: None\n");
  (match res3 with Some x -> Printf.printf "res3: %d\n" x | None -> Printf.printf "res3: None\n")