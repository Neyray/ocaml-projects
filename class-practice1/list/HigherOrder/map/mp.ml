(*map可以用来对列表进行整体操作，生成新的列表*)
let rec map f lst=
    match lst with
    | [] -> []
    | h :: t -> f h :: map f t

