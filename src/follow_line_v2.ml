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
let on_line known_colors =
  (* We suppose that the background color has id 1.  *)
  let is_bg_color = function
    | Probable.Maybe c | Probable.Sure c -> Color.id c = 1
  in

  (* We suppose that the stop color has id 2.  *)
  let is_stop_color = function
    | Probable.Sure c -> Color.id c = 2
    | Probable.Maybe _ -> false
  in

  let color = Color.recognize (Color_sensor.read_color ()) known_colors in
  if is_stop_color color then raise Stop else not (is_bg_color color)

let exit' status =
  Color_sensor.disconnect ();
  Dual_motor.disconnect ();
  exit status

(* Entry point.  *)
let main =
  try
    (* First we load the known colors.  *)
    let known_colors = load_known_colors "known_colors" in
    let chosen_direction = Direction.random()
    in

    let rec follow_line last_turn was_on_line =
      let last_turn, was_on_line =
        let is_on_line =
          try on_line known_colors with
          | Stop ->
            Dual_motor.turn (Direction.opposite chosen_direction);
            exit' 0
        in

        (* If the robot is on the line, turn in a randomized direction D.  *)
        if is_on_line then
          (last_turn, true)

        (* Otherwise, turn in the oppoite direction of D  *)
        else
          (* If it was on the line we have to correct the path of the
             robot by turning in the opposite direction.  *)
        if was_on_line then
          let dir = Direction.opposite last_turn in
          Dual_motor.turn dir;
          (dir, false)

        (* Otherwise, the robot has not yet got back on the line, so we
           stay in the same state.  *)
        else (last_turn, false)
      in
      follow_line last_turn was_on_line
    in
    let init_dir = Direction.random () in
    Color_sensor.connect ();
    Dual_motor.connect ();
    Dual_motor.start ();
    Dual_motor.turn init_dir;
    ignore (follow_line init_dir true);
    exit' 0
  with
  | exn ->
    let ch = open_out "log" in
    output_string ch (Printexc.to_string exn);
    close_out ch;
    exit' 1
