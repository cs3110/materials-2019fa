(* list expressions *)

[1; 2; 3];;
1 :: 2 :: 3 :: [];;
[];;
[ [1; 2]; [3; 4] ];;

(* records *)

type student = {
  name : string;
  (* gpa : float; --no, your gpa does not define you *)
  (* year graduated *)
  year : int;
};;
let rbg = {
  name = "Ruth Bader";
  year = 1954;
};;
rbg.name;;
rbg.year;;

(* tuples *)

(10, 10, "am");;
type time = int * int * string;;
let t = (4, 20, "pm");;
type point = float * float;;
let p = (5, 3);;
fst p;;
snd p;;

(* pattern matching on lists *)

let empty lst =
  match lst with
  | [] -> true
  | h :: t -> false

let empty' lst =
  match lst with
  | [] -> true
  | _ :: _ -> false

let empty'' lst =
  match lst with
  | [] -> true
  | _ -> false

let rec sum lst =
  match lst with
  | [] -> 0
  | h :: t -> h + sum t

let rec sum' = function
  | [] -> 0
  | h :: t -> h + sum t

(* pattern matching detects programmer error *)

let bad_empty lst =
  match lst with
  | [] -> true

(* The code above causes the compiler to produce the following warning: *)
(* 
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
_::_ 
*)

let rec bad_sum lst = 
  match lst with
  | h :: t -> h + sum t
  | [x] -> x
  | [] -> 0

(* The code above causes the compiler to produce the following warning: *)
(* 
Warning 11: this match case is unused.
*)

let rec bad_sum' lst =
  List.hd lst + bad_sum' (List.tl lst)

(* The code above raises an exception when applied to the empty list *)
