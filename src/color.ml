type rgb = {
  red : int;
  green : int;
  blue : int;
}

type color =
  | Black
  | White
  | Red
  | Green
  | Blue
  | Yellow

let color_of_hue = function
  | 0 -> Red
  | 60 -> Yellow
  | 120 -> Green
  | 240 -> Blue
  | _ -> assert false

let hue_of_color = function
  | Black | White -> assert false
  | Red -> 0
  | Green -> 120
  | Blue -> 240
  | Yellow -> 60

let hue_reflist =
  List.map hue_of_color [Red; Green; Blue; Yellow]

let string_of_color = function
  | Black -> "black"
  | White -> "white"
  | Red -> "red"
  | Green -> "green"
  | Blue -> "blue"
  | Yellow -> "yellow"

let hue_of_rgb {red = r; green = g; blue = b} =
  let hue_rad =
    atan2 (sqrt 3. *. float_of_int (g - b)) (float_of_int ((r lsr 1) - g - b))
  in
  let hue_deg = Math.(nearest_int (degree_of_radian hue_rad)) in
  if hue_deg < 0 then  hue_deg + 360 else hue_deg

let lerp_red = Math.lerp (27, 0) (480, 255)

let lerp_green = Math.lerp (27, 0) (400, 255)

let lerp_blue = Math.lerp (17, 0) (250, 255)
