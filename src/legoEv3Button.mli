(** EV3 buttons.  *)

type t =
  | Enter
  | Backspace
  | Up
  | Down
  | Left
  | Right

val pressed_button : unit -> t
(** @return the pressed button.  Block until a button is pressed and
    released.  *)

val to_string : t -> string
(** @return the string representation of the button (e.g. for debugging
    purpose).  *)
