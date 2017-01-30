(** EV3 buttons.  *)


(** Type of EV3 buttons.  *)
type t =
  | Enter
  | Backspace
  | Up
  | Down
  | Left
  | Right

val pressed_button : unit -> t
(** @return the pressed button.  Blocks until a button is pressed and
    released.  *)

val to_string : t -> string
(** @return the string representation of the button (e.g. for debugging
    purpose).  *)

val repeat_until : (unit -> 'a) -> t -> 'a list
(** [repeat_until f button] applies [f] until [button] is pressed and
    released.  @return the successive results of [f] application. *)
