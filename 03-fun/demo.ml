(* The use of double semi-colon below is _not_ idiomatic OCaml.  This file
   is really intended as a script typed into utop, not as an OCaml source
   file to be compiled.  I.e., you should not get used to putting double
   semi-colons into your source files. *)

(* anonymous functions, and application *)
fun x -> x + 1;;
(fun x -> x + 1) 3110;;

fun x y -> (x +. y) /. 2.;;
(fun x y -> (x +. y) /. 2.) 0. 1.;;

(* function defintions *)
let inc = fun x -> x + 1;;
let inc x = x + 1;;
let avg x y = (x +. y) /. 2.;;

(* recursive functions *)
let rec fact n =
  if n = 0 then 1
  else n * fact (n-1);;

let rec loop x = 
  loop x;;

(* partial application *)
let add x y = x + y;;
add 2 3;;
add 2;;
let add2 = add 2;;
add2 7;;

