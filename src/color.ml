type t = float Triple.t

(* Extract red component.  *)
let red c = Triple.fst c

(* Extract green component.  *)
let green c = Triple.snd c

(* Extract blue component.  *)
let blue c = Triple.trd c

let make (r, g, b) = Triple.map float_of_int (Triple.make r g b)

let to_string c =
  let c = Triple.map int_of_float c in
  Printf.sprintf "(%d, %d, %d)" (red c) (green c) (blue c)

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
  Printf.sprintf "%d %s %s"
    c.id (to_string c.center) (to_string c.sigma)

let cloud_of_string s =
  let receiver_f id center_r center_g center_b sigma_r sigma_g sigma_b = {
    id = id;
    center = make (center_r, center_g, center_b);
    sigma = make (sigma_r, sigma_g, sigma_b)
  }
  in
  Scanf.sscanf s "%d (%d, %d, %d) (%d, %d, %d)" receiver_f

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

(* [member col col_cloud] returns true if and only if [col]
    belongs to [col_cloud].  *)
let member col col_cloud =
  (* We suppose that colors composing a color cloud follows a Gaussian
     distribution.  Thus, a random color of the cloud is between
     center - 3*sigma and center + 3*sigma with probability 99.7%.  *)
  let delta = shift 3. col_cloud.sigma in
  geq col (diff col_cloud.center delta) &&
  leq col (add col_cloud.center delta)

(* Return the cloud [c] among [col_clouds] such that the distance
   between [c.center] and [col] is minimal.  *)
let nearest_cloud col col_clouds =
  let aux col (old_cloud, old_dist) new_cloud =
    let new_dist = dist col (center new_cloud) in
    if new_dist < old_dist then (new_cloud, new_dist) else (old_cloud, old_dist)
  in
  match col_clouds with
  | [] -> assert false
  | col_cloud :: col_clouds ->
    let dist = dist col (center col_cloud) in
    fst (List.fold_left (aux col) (col_cloud, dist) col_clouds)

let recognize col known_cols =
  match List.filter (member col) known_cols with
  (* There is no color recognized without doubt.  In this case we return
     the "nearest" color among known colors.  *)
  | [] -> Probable.Maybe (nearest_cloud col known_cols)

  (* We decide between the candidates by computing the "nearest"
     cloud.  *)
  | col_clouds -> Probable.Sure (nearest_cloud col col_clouds)
