(* These are examples of the kind of code we will demo in this lecture.
   The professor might make up code off the top of his head,
   that doesn't exactly match what's here. *)

(* The use of double semi-colon below is _not_ idiomatic OCaml.  This file
   is really intended as a script typed into utop, not as an OCaml source
   file to be compiled.  I.e., you should not get used to putting double
   semi-colons into your source files. *)

(* values *)
3110;;
2110;;
true;;

(* expressions that are not values *)
3110 > 2110;;
"big" ^ "red";;
2.0 *. 3.14;;

(* if expressions *)
if "batman" > "superman" then "yay" else "boo";;
if true then "obviously" else "wtf";;
if 0 < 1 then 2.0 else 3.0;;
(* the next three have type errors *)
(* if 0 < 1 then 2 else 3.0;; *)
(* if 1 then 2 else 3;; *)
(* if 0 < 1 then 2.0;; *)  (* for now, don't use [if] without [else] *)

(* type annotations *)
(* if 0 < 1 then (2 : float) else 3.0;; *)
if (0 < 1 : bool) then (2 : int) else (3 : int);;

(* let definitions *)
let x = 42;;
x;;
let y : int = 3110;;
y;;
x + y;;
(* the next line is not valid OCaml syntax,
   because definitions are not expressions *)
(* (let z = 0) + 1;; *)

(* let expressions *)
let a = 0 in a;;
(* the next line has an "unbound value" error *)
(* a;; *)
let b = 1 in 2 * b;;
let c = 3 in (let d = 4 in c + d);;
(* the next line is confusing and produces a warning;
   we shouldn't write such code, but we'll talk about it
   in recitation *)
let e = 5 in (let e = 6 in e);;
