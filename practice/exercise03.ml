(*3.返回第n个元素*)
let rec at n lst=
 if n<0 then None
 else begin
  match n ,lst with
  | _ , [] -> None (*"表示越界"*)
  | 0 , x :: t -> Some x
  | _ , _ :: t -> at (n-1) t
 end 

let () =
  let res1 = at 0 [10; 20; 30] in
  let res2 = at 2 [10; 20; 30] in
  let res3 = at 3 [10; 20; 30] in
  let res4 = at (-1) [10; 20; 30] in

  (match res1 with Some x -> Printf.printf "res1: %d\n" x | None -> Printf.printf "res1: None\n");
  (match res2 with Some x -> Printf.printf "res2: %d\n" x | None -> Printf.printf "res2: None\n");
  (match res3 with Some x -> Printf.printf "res3: %d\n" x | None -> Printf.printf "res3: None\n");
  (match res4 with Some x -> Printf.printf "res4: %d\n" x | None -> Printf.printf "res4: None\n")