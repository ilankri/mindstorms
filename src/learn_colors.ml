let main =
  let learn_color () =
    let col_cloud =
      Color.make_cloud
        (LegoEv3Button.repeat_until Color_sensor.read_color LegoEv3Button.Right)
    in
    Printf.printf "Color %d learned.\n%!" (Color.id col_cloud);
    col_cloud
  in
  let store_learned_colors known_cols filename =
    let ch = open_out filename in
    List.iter
      (fun c -> output_string ch (Color.string_of_cloud c ^ "\n"))
      known_cols;
    close_out ch
  in
  Color_sensor.connect();
  print_endline "Ready to learn colors.";
  store_learned_colors
    (LegoEv3Button.repeat_until learn_color LegoEv3Button.Backspace)
    "known_colors";
  Color_sensor.disconnect ();
  print_endline "Color learning done.";
  exit 0
