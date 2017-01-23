let main () =
  let rec loop () =
    let pressed_button = LegoEv3Button.pressed_button () in
    let msg =
      "You pressed " ^ LegoEv3Button.to_string pressed_button ^ " button."
    in
    print_endline msg;
    if pressed_button = LegoEv3Button.Backspace then begin
      print_endline "Bye.";
      exit 0
    end else loop ()
  in
  loop ()

let _ = main ()
