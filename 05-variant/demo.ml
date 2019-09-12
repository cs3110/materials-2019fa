(* simplest variant: constant constructors *)

type primary_color = Red | Blue | Green

let c = Red

(* more complicated variant with non-constant constructors *)

type point = float * float

type shape = 
  | Circle of {center : point; radius : float}
  | Rectangle of {lower_left : point; upper_right : point}
  (* | Point of point *) (* we'll add this later: when we do note warning *)

let s = Circle {center=(0.,0.); radius=1.}

let mid a b =
  (b -. a) /. 2.

let center = function
  | Circle {center} -> center
  | Rectangle {lower_left=(x_ll, y_ll); upper_right=(x_ur, y_ur)} -> 
    (mid x_ll x_ur, mid y_ll y_ur)
(* | Point p -> p *) (* we'll add this later *)

(* the code for [center] above is equivalent to this more verbose version
   that doesn't take advantage of various pieces of syntactic sugar
   and pattern syntax *)
let center_verbose s =
  match s with
  | Circle {center=c} -> c
  | Rectangle {lower_left=ll; upper_right=ur} -> 
    let x_ll, y_ll = ll in
    let x_ur, y_ur = ur in
    (mid x_ll x_ur, mid y_ll y_ur)

(* recursive variants *)

type intlist = 
  | Nil
  | Cons of int * intlist

let rec length = function
  | Nil -> 0
  | Cons (_,t) -> 1 + length t

type stringlist = 
  | Nil
  | Cons of string * stringlist

let rec length = function
  | Nil -> 0
  | Cons (_,t) -> 1 + length t

(* poor engineering to copy code! *)

(* parameterized variants *)

type 'a mylist =
  | Nil
  | Cons of 'a * 'a mylist

let rec length = function
  | Nil -> 0
  | Cons (_,t) -> 1 + length t

(* lists are just parameterized recursive variants *)

type 'a mylist =
  | []
  | (::) of 'a * 'a mylist

let rec length = function
  | [] -> 0
  | _ :: t -> 1 + length t;;

(* options *)

Stdlib.max;;

let rec list_max = function
  | [] -> None
  | h :: t ->
    match list_max t with
    | None -> Some h
    | Some m -> Some (max h m)