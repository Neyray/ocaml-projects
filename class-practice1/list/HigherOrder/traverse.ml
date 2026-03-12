let rec fold_left (f : 'a -> 'b -> 'a) (acc : 'a) (lst : 'b list): 'a =
  match lst with 
  | [] -> acc
  | h::t -> fold_left f (f acc h) t

