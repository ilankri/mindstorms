type rgb = {
  red : int;
  green : int;
  blue : int;
}

type color =
  | Black
  | White
  | Red
  | Green
  | Blue
  (* | Cyan *)
  (* | Magenta *)
  | Yellow

val hue_of_rgb : rgb -> int

val color_of_hue : int -> color

val hue_reflist : int list

val string_of_color : color -> string

val lerp_red : int -> int

val lerp_green : int -> int

val lerp_blue : int -> int
