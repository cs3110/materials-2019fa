(** The type of binary operators. *)
type bop = 
  | Add
  | Mult
  | Leq

type typ =
  | TInt
  | TBool

(** The type of the abstract syntax tree (AST). *)
type expr =
  | Var of string
  | Int of int
  | Bool of bool  
  | Binop of bop * expr * expr
  | Let of string * typ * expr * expr
  | If of expr * expr * expr
