(** Color operations.  *)

type t
(** Abstract type for colors.  *)

val make : int * int * int -> t
(** @return the color with given RGB components.  *)

val to_string : t -> string
(** @return a string representation of a color.  *)

val dist : t -> t -> float


(** {4 Color cloud} *)

type color_cloud
(** Abstract type of color cloud (set of color points).  *)

val make_cloud : t list -> color_cloud
(** @return the color cloud described with given color points.  *)

val string_of_cloud : color_cloud -> string
(** @return a string representation of a color cloud.  *)

val id : color_cloud -> int
(** @return the identifier of the given cloud.  *)

val center : color_cloud -> t
(** @return the center point of the given cloud.  *)

val member : t -> color_cloud -> bool
(** [member color color_cloud] returns true if and only if [color]
    belongs to [color_cloud].  *)
