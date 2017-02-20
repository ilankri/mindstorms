(** Color operations.  *)

type t
(** Abstract type for colors.  *)

val make : int * int * int -> t
(** @return the color with given RGB components.  *)

val to_string : t -> string
(** @return a string representation of a color.  *)


(** {4 Color cloud} *)

type color_cloud
(** Abstract type of color cloud (set of color points).  *)

val make_cloud : t list -> color_cloud
(** @return the color cloud described with given color points.  *)

val string_of_cloud : color_cloud -> string
(** @return a string representation of a color cloud.  *)

val cloud_of_string : string -> color_cloud

val id : color_cloud -> int
(** @return the identifier of the given cloud.  *)

val recognize : t -> color_cloud list -> color_cloud Probable.t
(** [recognize col known_cols] returns the color cloud containing [col]
    among the cloud list [known_cols].  *)
