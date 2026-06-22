(*31.改进版游程编码*)
type 'a rle =
  | One of 'a
  | Many of int * 'a

let modified_encode lst =
  (* 1. 先写一个标准的游程编码，生成 (int * 'a) list *)
  let rec encode_aux acc remainder =
    match remainder with
    | [] -> List.rev acc
    | x :: t ->
        match acc with
        | (count, v) :: other_groups when v = x ->
            encode_aux ((count + 1, v) :: other_groups) t
        | _ ->
            encode_aux ((1, x) :: acc) t
  in
  let standard_encoded = encode_aux [] lst in

  (* 2. 将标准编码列表转换为题目要求的 rle 形式 *)
  let rec convert_aux acc encoded_list =
    match encoded_list with
    | [] -> List.rev acc
    | (count, x) :: t ->
        if count = 1 then
          convert_aux (One x :: acc) t
        else
          convert_aux (Many (count, x) :: acc) t
  in
  convert_aux [] standard_encoded