(* Exception raised when the robot detects the end of line mark.  *)
exception Stop

(* Read colors from the given and return the colors as a list.  *)
let load_known_colors filename =
  let rec aux ch acc =
    try aux ch (input_line ch :: acc) with
    | End_of_file -> acc
  in
  let ch = open_in filename in
  let known_colors = List.map Color.cloud_of_string (aux ch []) in
  close_in ch;
  known_colors

(* Check if the robot is on a line.  To do that, we just check if the
   color is different from the background color.  *)
let on_line known_colors ch =
  (* We suppose that the background color has id 1.  *)
  let is_bg_color = function
    | Probable.Maybe c | Probable.Sure c -> Color.id c = 1
  in

  (* We suppose that the stop color has id 2.  *)
  let is_stop_color = function
    | Probable.Sure c -> Color.id c = 2
    | Probable.Maybe _ -> false
  in

  let recognize_color known_colors ch =
    match Color.recognize (Color_sensor.read_color ()) known_colors with
    | Probable.Maybe c | Probable.Sure c as color ->
      Printf.fprintf ch "Recognize color %d.\n" (Color.id c);
      color
  in

  let color = recognize_color known_colors ch in
  if is_stop_color color then raise Stop else not (is_bg_color color)

let gc_alarm ch = fun () -> output_string ch "Garbage collection done.\n"

(* Entry point.  *)
let main =
  let ch = open_out "follow_line.log" in
  let exit' status =
    Color_sensor.disconnect ();
    Dual_motor.disconnect ();
    close_out ch;
    exit status
  in
  let turn dir =
    Dual_motor.turn dir;
    Printf.fprintf ch "Turn %s.\n" (Direction.to_string dir)
  in
  let on_line known_colors =
    try on_line known_colors ch with
    | Stop ->
      Dual_motor.stop ();
      exit' 0
  in
  let rec find_edge known_colors =
    if on_line known_colors then find_edge known_colors else
      output_string ch "Edge found.\n";
  in
  let rec follow_line known_colors init_dir was_on_line : unit =
    let on_line = on_line known_colors in
    if on_line && not was_on_line then turn init_dir else
    if not on_line && was_on_line then turn (Direction.opposite init_dir);
    follow_line known_colors init_dir on_line
  in

  (* First we load the known colors.  *)
  let known_colors = load_known_colors "known_colors" in

  (* Choose randomly an initial direction.  *)
  let init_dir = Direction.random () in

  (* Turn on recording of exceptions backtraces for debugging
     purpose.  *)
  Printexc.record_backtrace true;

  (* Print a message every time the GC has done its job.  *)
  ignore (Gc.create_alarm (gc_alarm ch));

  try
    Color_sensor.connect ();
    Dual_motor.connect ();
    Dual_motor.start ();
    output_string ch "Search edge.\n";
    turn init_dir;
    find_edge known_colors;
    follow_line known_colors init_dir true;
    exit' 0
  with
  | exn ->
    let ch = open_out "backtrace.log" in
    output_string ch (Printexc.to_string exn ^ "\n");
    Printexc.print_backtrace ch;
    close_out ch;
    exit' 1
