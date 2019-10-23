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

  (** AF: [Leaf] represents the empty set.  [Node (l, v, r)] represents
        the set containing [v], as well as all the elements of the sets
        represented by [l] and [r].
      RI: for every [Node (l, v, r)], all the values in [l] are strictly
        less than [v], and all the values in [r] are strictly greater
        than [v]. *)
  type 'a t = Leaf | Node of 'a t * 'a * 'a t

  let empty = 
    Leaf

  let rec mem x = function
    | Leaf -> false
    | Node (l, v, r) ->
      if x < v then mem x l
      else if x > v then mem x r
      else true

  let rec insert x = function
    | Leaf -> Node (Leaf, x, Leaf)
    | Node (l, v, r) as n ->
      if x < v then Node (insert x l, v, r)
      else if x > v then Node (l, v, insert x r)
      else n

end

module RbSet = struct

  type color = Red | Blk

  (** AF: [Leaf] represents the empty set.  [Node (c, l, v, r)] represents
        the set containing [v], as well as all the elements of the sets
        represented by [l] and [r].
      RI: The BST invariant holds, and the local and global RB tree 
        invariants hold. *)
  type 'a t = Leaf | Node of (color * 'a t * 'a * 'a t)

  let empty = Leaf

  let rec mem x = function
    | Leaf -> false
    | Node (_, l, v, r) ->
      if x < v then mem x l
      else if x > v then mem x r
      else true

  (** [balance (c, l, v, r)] implements the four possible rotations
      that could be necessary to balance a node and restore the
      RI clause about Red nodes. *)
  let balance = function
    | (Blk, Node (Red, Node (Red, a, x, b), y, c), z, d)
    | (Blk, Node (Red, a, x, Node (Red, b, y, c)), z, d)
    | (Blk, a, x, Node (Red, Node (Red, b, y, c), z, d))
    | (Blk, a, x, Node (Red, b, y, Node (Red, c, z, d)))
      -> Node (Red, Node (Blk, a, x, b), y, Node (Blk, c, z, d))
    | t -> Node t

  let rec insert_aux x = function
    | Leaf -> Node (Red, Leaf, x, Leaf) (* color new node red *)
    | Node (c, l, v, r) as n ->
      if x < v then balance (c, insert_aux x l, v, r)
      else if x > v then balance (c, l, v, insert_aux x r)
      else n

  let insert x s = 
    match insert_aux x s with
    | Leaf -> failwith "impossible" (* [insert_aux] cannot return [Leaf] *)
    | Node (_, l, v, r) -> Node (Blk, l, v, r) (* color root black *)
end
