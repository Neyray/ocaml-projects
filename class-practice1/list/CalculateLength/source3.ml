(*进行过尾递归优化的版本2*)
let length lst=
    let rec len sum lst=
      match lst with
      | [] -> sum
      | _ :: t -> len (sum+1) lst
    in len 0 lst
