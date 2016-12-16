let pi = 2. *. (acos 0.)

let nearest_int f =
  let f_ceiling = ceil f in
  let f_floor = floor f in
  int_of_float (if f_ceiling -. f < f -. f_floor  then f_ceiling else f_floor)

let dist x y = abs (x - y)

let degree_of_radian r = 180. *. r /. pi

let lerp (x0, y0) (x1, y1) =
  fun x -> nearest_int (
      float_of_int (x * (y0 - y1) + x0 * y1 - x1 * y0)
      /. float_of_int (x0 - x1)
    )
