(*返回列表最后两个元素*)
let rec last_two lst=
 match lst with
 | [] -> None
 | [x] -> None
 | [a;b] -> Some (a,b)
 | _ :: t -> last_two t

let () =
  let result1 = last_two [1;2;3;4;5] in
  let result2 = last_two ["a";"b";"c"] in
  let result3 = last_two [1] in
  let result4 = last_two [] in

  (match result1 with
  | Some (a,b) -> Printf.printf "%d,%d\n" a b
  | None -> Printf.printf "空\n");

  (match result2 with
  | Some (a,b) -> Printf.printf "%s,%s\n" a b
  | None -> Printf.printf "空\n");

  (match result3 with
  | Some (a,b) -> Printf.printf "非空\n"
  | None -> Printf.printf "空\n");

  (match result4 with
  | Some (a,b) -> Printf.printf "非空\n"
  | None -> Printf.printf "空\n");