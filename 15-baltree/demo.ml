module type Set = sig

  (** ['a t] is the type of sets whose elements have type ['a]. *)
  type 'a t

  (** [empty] is the empty set *)
  val empty : 'a t

  (** [insert x s] is the set containing [x] as well as all the
      elements of [s]. *)
  val insert : 'a -> 'a t -> 'a t

  (** [mem x s] is whether [x] is a member of [s]. *)
  val mem : 'a -> 'a t -> bool

end

module ListSet = struct

  (** AF: [[x1; ...; xn]] represents the set {x1, ..., xn}.
      RI: the list contains no duplicates. *)
  type 'a t = 'a list

  let empty = []

  let mem = List.mem

  let insert x s =
    if mem x s then s else x :: s

end

module BstSet = struct

  type 'a t = Leaf | Node of 'a t * 'a * 'a t

  let empty = 
    Leaf

  let rec mem x s =
    failwith "TODO"

  let rec insert x s = 
    failwith "TODO"

end

module RbSet = struct

  type color = Red | Blk

  type 'a t = Leaf | Node of (color * 'a t * 'a * 'a t)

  let empty = Leaf

  let rec mem x s =
    failwith "TODO"

  let insert x s =
    failwith "TODO"

end
