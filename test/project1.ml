let rec separate_by_parity lst=
  let rec aux (acc1,acc2) lst=
  match lst with
  | [] -> (List.rev acc1,List.rev acc2)
  | x::t -> if x<0 then begin
    if (-x) mod 2=0 then aux (x::acc1,acc2) t
    else aux (acc1,x::acc2) t
  end
else begin
  if x mod 2=0 then aux (x::acc1,acc2) t
  else aux (acc1,x::acc2) t 
end
in aux ([],[]) lst 
