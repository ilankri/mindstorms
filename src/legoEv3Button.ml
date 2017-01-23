type t =
  | Enter
  | Backspace
  | Up
  | Down
  | Left
  | Right

let to_string = function
  | Enter -> "enter"
  | Backspace -> "backspace"
  | Up -> "up"
  | Down -> "down"
  | Left -> "left"
  | Right -> "right"

(* See linux/input.h for key codes.  *)
let button_of_keycode = function
  | 28 -> Enter
  | 14 -> Backspace
  | 103 -> Up
  | 108 -> Down
  | 105 -> Left
  | 106 -> Right
  | _ -> assert false

let pressed_button () =
  (* [ignore_next_bytes ch count] reads [count] bytes from input channel
     [ch] and discards them.  *)
  let rec ignore_next_bytes ch count =
    if count <= 0 then () else
      begin
        ignore (input_byte ch);
        ignore_next_bytes ch (count - 1)
      end
  in

  (* Extract the key code from the key event file.  See
     http://www.ev3dev.org/docs/tutorials/using-ev3-buttons/#directly-reading-the-event-device
     for format of event file.  *)
  let extract_keycode () =
    let event_file = "/dev/input/by-path/platform-gpio-keys.0-event" in
    let ch = open_in event_file in
    let keycode =
      ignore_next_bytes ch 10;
      input_byte ch
    in
    close_in ch;
    keycode
  in

  (* We extract the key code twice: one for button pressing and one for
     button releasing.  *)
  ignore (extract_keycode ());
  button_of_keycode (extract_keycode ())
