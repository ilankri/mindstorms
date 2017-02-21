let main =
  let recognize_color known_colors () =
    match Color.recognize (Color_sensor.read_color ()) known_colors with
    | Probable.Maybe c -> Printf.printf "Maybe color %d.\n%!" (Color.id c)
    | Probable.Sure c -> Printf.printf "Color %d.\n%!" (Color.id c)
  in
  let load_known_colors filename =
    let rec aux ch acc =
      try aux ch (input_line ch :: acc) with
      | End_of_file -> acc
    in
    let ch = open_in filename in
    let known_colors = List.map Color.cloud_of_string (aux ch []) in
    close_in ch;
    known_colors
  in

  (* First, we load the known colors.  *)
  let known_colors = load_known_colors "known_colors" in

  Color_sensor.connect ();

  (* Then, the robot is able to recognize input color.  *)
  print_endline "Ready to recognize colors.";
  LegoEv3Button.repeat_until
    (recognize_color known_colors)
    LegoEv3Button.Backspace;

  Color_sensor.disconnect ();
  exit 0
