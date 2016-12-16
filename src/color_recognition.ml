module Color_sensor =
  LegoEv3ColorSensor.LegoEv3ColorSensor
    (struct let name = "sensor" let multiple_connection = true end)
    (struct let input_port = Port.Input1 end)

let what_color () =
  let c =
    Color_sensor.set_mode Color_sensor.COL_REFLECT;
    Color_sensor.reflected_light () in
  if c = 100 then Color.White else
  if c < 8 then Color.Black else
    let r, g, b =
      Color_sensor.set_mode Color_sensor.RGB_RAW;
      Color_sensor.raw_color_components ()
    in
    let r, g, b = Color.(lerp_red r, lerp_green g, lerp_blue b) in
    let hue = Color.(hue_of_rgb {red = r; green = g; blue = b}) in
    let f (old_dist, old_hue) x =
      let new_dist =
        Math.dist hue x in
      if new_dist < old_dist then (new_dist, x) else (old_dist, old_hue)
    in
    let _, res = List.fold_left f (360, -1) Color.hue_reflist in
    Printf.printf "hue = %d\n" hue;
    Color.color_of_hue res

let main () =
  let color =
    Color_sensor.connect();
    what_color ()
  in
  print_endline Color.(string_of_color color);
  Color_sensor.disconnect ();
  (* Unix.sleep 3; *)
  exit 0

let _ = main ()
