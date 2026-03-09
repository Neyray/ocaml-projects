(*实现函数组合*)
let compose f g x = f(g x)

let ()=
  let double x = x*2 in
  let add_one x=x+1 in

  let h = compose double add_one in
  let result =h 3 in
  Printf.printf "result: %d" result

  