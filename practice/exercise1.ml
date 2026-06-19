(*1.返回列表最后一个元素*)
let rec last lst=
(*重点！！！范围从小到大开始匹配*)
 match lst with
 | [] -> None
 | [x] -> Some x
 | _ :: t -> last t 

let () =
  let result1 = last [1; 2; 3; 4] in   (* 类型为 int option *)
  let result2 = last ["a"; "b"; "c"] in (* 类型为 string option *)
  let result3 = last [] in              (* 类型为 'a option *)

  (match result1 with
  | Some n -> Printf.printf "result1: %d\n" n
  | None -> Printf.printf "result1:empty\n");

  (match result2 with
  | Some str -> Printf.printf "result2:%s\n" str
  | None -> Printf.printf "result2:empty\n");

  (match result3 with 
  | Some _ -> Printf.printf "找到了元素\n"
  | None -> Printf.printf "没找到元素了\n");