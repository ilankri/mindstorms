module Color_sensor =
  LegoEv3ColorSensor.LegoEv3ColorSensor
    (struct let name = "sensor" let multiple_connection = true end)
    (struct let input_port = Port.Input1 end)

let read_color () = Color.make (Color_sensor.raw_color_components ())

let learn () =
  let col_cloud =
    Color.make_cloud LegoEv3Button.(repeat_until read_color Right)
  in
  Printf.printf "Color %d learned\n%!" (Color.id col_cloud);
  col_cloud

(* [recognize col known_cols] returns the color cloud containing [col]
   among the cloud list [known_cols].  *)
let recognize col known_cols =
  let nearest_cloud (old_cloud, old_dist) new_cloud =
    let new_dist = Color.(dist col (center new_cloud)) in
    if new_dist < old_dist then (new_cloud, new_dist) else (old_cloud, old_dist)
  in
  match List.filter (Color.member col) known_cols with
  (* No ambiguity.  *)
  | [] -> None
  | [col_cloud] -> Some col_cloud

  (* Ambiguity.  *)
  | col_cloud :: col_clouds ->
    (* We decide between the candidates by computing the "nearest"
       cloud, i.e. the cloud [c] such that the distance between
       [c.center] and [col] is minimal.  *)
    let dist = Color.(dist col (center col_cloud)) in
    let col_cloud, _ =
      List.fold_left nearest_cloud (col_cloud, dist) col_clouds
    in
    Some col_cloud

let main () =
  let learn_loop () =
    let known_cols =
      Color_sensor.connect();
      Color_sensor.set_mode Color_sensor.RGB_RAW;
      LegoEv3Button.(repeat_until learn Backspace)
    in
    let ch = open_out "known_colors" in
    List.iter
      (fun c -> output_string ch (Color.string_of_cloud c ^ "\n")) known_cols;
    close_out ch;
    known_cols
  in
  let recognize_loop known_cols () =
    match recognize (read_color ()) known_cols with
    | None -> print_endline "Unknown color."
    | Some c -> Printf.printf "Color %d recognized.\n%!" (Color.id c);
  in

  (* First, we learn the colors to the robot.  *)
  let known_cols =
    print_endline "Ready to learn colors.";
    learn_loop ()
  in
  print_endline "Learning stage done.";

  (* Then, the robot is able to recognize input color.  *)
  print_endline "Ready to recognize colors.";
  ignore LegoEv3Button.(repeat_until (recognize_loop known_cols) Backspace);

  Color_sensor.disconnect ();
  exit 0

let _ = main ()
