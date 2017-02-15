type t = float Triple.t

(* Extract red component.  *)
let red c = Triple.fst c

(* Extract green component.  *)
let green c = Triple.snd c

(* Extract blue component.  *)
let blue c = Triple.trd c

let make (r, g, b) = Triple.(map float_of_int (make r g b))

let to_string c =
  let c = Triple.map int_of_float c in
  Printf.sprintf "color(%d, %d, %d)" (red c) (green c) (blue c)

(* Scalar product in three-dimensional space.  *)
let scalar_prod c c' =
  red c *. red c' +. green c *. green c' +. blue c *. blue c'

(* Norm in three-dimensional space.  *)
let norm c = sqrt (scalar_prod c c)

(* Per-component addition.  *)
let add c c' = Triple.map2 (+.) c c'

(* Per-component subtraction.   *)
let diff c c' = Triple.map2 (-.) c c'

(* Per-component multiplication.  *)
let mult c c' = Triple.map2 ( *. ) c c'

(* Per-component scalar multiplication.  *)
let shift k c = Triple.map (( *. ) k) c

(* Return the distance between the two given colors seen like points in
   the three-dimensional space.  *)
let dist c c' = norm (diff c c')


type color_cloud = {
  id : int;                     (* Identifier.  *)
  center : t;                   (* Center point.  *)
  sigma : t                     (* Standard deviation point.  *)
}

(* Convenient function to generate fresh identifiers for point
   clouds.  *)
let next_id =
  let c = ref 0 in
  fun () ->
    c := succ !c;
    !c

(* Return the average point of the given color list.  *)
let average cols =
  let black = make (0, 0, 0) in
  let sum = List.fold_left add black cols in
  shift (1. /. float_of_int (List.length cols)) sum

(* Return the standard deviation of the given color list *)
let standard_deviation avg cols =
  let black = make (0, 0, 0) in
  let squared_diff y x =
    let diff_x_y = diff x y in
    mult diff_x_y diff_x_y
  in
  let sum_squared_diff_list = List.map (squared_diff avg) cols in
  let sum = List.fold_left add black sum_squared_diff_list in
  Triple.map sqrt (shift (1. /. float_of_int (List.length cols)) sum)


let make_cloud cols =
  let avg = average cols in
  {id = next_id (); center = avg; sigma = standard_deviation avg cols}

let string_of_cloud c =
  Printf.sprintf "color_cloud(id = %d, center = %s, sigma = %s)"
    c.id (to_string c.center) (to_string c.sigma)

let id c = c.id

let center c = c.center

(* Template function for comparison functions.  *)
let cmp cmp_func col col' =
  let aux select_component =
    cmp_func (select_component col) (select_component col')
  in
  aux red && aux green && aux blue

(* Test if [col <= col'], i.e. :

   [red col <= red col'] and [green col <= green col'] and [blue col <=
   blue col'].  *)
let leq col col' = cmp (<=) col col'

(* Test if [col >= col'].  *)
let geq col col' = cmp (>=) col col'

let member col col_cloud =
  (* We suppose that colors composing a color cloud follows a Gaussian
     distribution.  Thus, a random color of the cloud is between
     center - 3*sigma and center + 3*sigma with probability 99.7%.  *)
  let delta = shift 3. col_cloud.sigma in
  geq col (diff col_cloud.center delta) &&
  leq col (add col_cloud.center delta)
