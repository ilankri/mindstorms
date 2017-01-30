(** Homogeneous triples.  *)

type 'a t
(** Abstract polymorphic type of homogeneous triples.  *)

val make : 'a -> 'a -> 'a -> 'a t
(** [make x y z] constructs the triple [(x, y, z)].  *)

val fst : 'a t -> 'a
(** @return the first component of triple.  *)

val snd : 'a t -> 'a
(** @return the second component of triple.  *)

val trd : 'a t -> 'a
(** @return the third component of triple.  *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f (x, y, z)] is [(f x, f y, f z)].  *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** [map2 f (x, y, z) (x', y', z')] is [(f x x', f y y', f z z')].  *)

val to_tuple : 'a t -> 'a * 'a * 'a
(** @return the triple as a standard tuple.  *)
