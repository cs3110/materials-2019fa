(* Refs *)

3110;;
let x = 3110;;
x;;

ref 3110;;
(* Think of a ref like a box in memory whose contents may change
   OCaml creates a fresh new location in which to stores those contents
   with every ref that is created. *)
let y = ref 3110;;
(* val y : int ref = {contents = 3110}) 
   [y] is a value whose type is [int ref] and whose current contents are [3110].
   [y] is bound to the location of that box, though we can't find out
   the location itself, just its contents. *)
y;;
!y;;

(* type error *)
(* x + y;; *)
x + !y;;

y := 2110;;
!y;;
(* [y] is still bound to same location as before; that's immutable.
   But contents have changed. *)


(* Mutable Fields *)

type point = {x:int; y:int; mutable c:string};;

let p = {x=0; y=0; c="red"};;

p.c <- "white";;

p;;

(* Error: *)
(* p.x <- 3;; *)

