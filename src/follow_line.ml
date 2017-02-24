let main =
  let load_known_colors filename =
    let rec aux ch acc =
      try aux ch (input_line ch :: acc) with
      | End_of_file -> acc
    in
    let ch = open_in filename in
    let known_colors = List.map Color.cloud_of_string (aux ch []) in
    close_in ch;
    known_colors in
  let is_bg_color c = Color.id c = 1 in
  let rec check_end_of_line known_colors =
    let color =
      match Color.recognize (Color_sensor.read_color ()) known_colors with
      | Probable.Maybe c | Probable.Sure c -> c
    in
    if is_bg_color color then Dual_motor.stop () else
      check_end_of_line known_colors
  in
  let known_colors = load_known_colors "known_colors" in
  Color_sensor.connect ();
  Dual_motor.connect ();

  Dual_motor.set_speed 40;
  Dual_motor.move_forward ();
  check_end_of_line known_colors;

  Color_sensor.disconnect ();
  Dual_motor.disconnect ();
  exit 0
