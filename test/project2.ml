(*2.最长连续递增段*)
let rec longest_rising_run lst=
  let rec aux acc count max_length lst=
  match lst with
  | [] -> max count max_length   (*在末尾也要进行比较！*)
  | x::t -> 
    match acc with
    | [] -> aux (x::acc) (count+1) max_length t
    | h::v -> if x>h then aux (x::acc) (count+1) (max count max_length) t
    else aux (x::acc) 1 (max count max_length) t  
  in aux [] 0 0 lst
