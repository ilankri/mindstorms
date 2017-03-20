let main =
  try begin
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
    let is_stop_color c = Color.id c = 2 in
    let trace_file = open_out "trace" in
    let on_line known_colors =
      let color =
        match Color.recognize (Color_sensor.read_color ()) known_colors with
        | Probable.Maybe c | Probable.Sure c -> c
      in
      output_string trace_file (string_of_int (Color.id color));
      output_char trace_file '\n';
      if is_stop_color color then begin
        flush trace_file;
        close_out trace_file;
        raise Exit
      end else not (is_bg_color color)
    in
    let known_colors = load_known_colors "known_colors" in
    let follow_line () =
      let rec loop last_turn was_on_line =
        let last_turn, was_on_line =
          try
            if on_line known_colors then
              (last_turn, true)
            else
            if was_on_line then
              let dir = Direction.opposite last_turn in
              Dual_motor.turn dir;
              (dir, false)
            else (last_turn, false)
          with
          | Exit -> exit 0
        in
        loop last_turn was_on_line
      in
      ignore (loop Direction.Left true)
    in
    let init_dir = Direction.Left in
    Color_sensor.connect ();
    Dual_motor.connect ();
    Dual_motor.move_forward ();
    Dual_motor.turn init_dir;
    follow_line ();
    Color_sensor.disconnect ();
    Dual_motor.disconnect ();
    exit 0
  end
  with
  | exn ->
    let ch = open_out "log" in
    output_string ch (Printexc.to_string exn);
    Printexc.print_backtrace ch;
    close_out ch;
