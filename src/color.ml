type t = float Triple.t

(* Extract red component.  *)
let red c = Triple.fst c

(* Extract green component.  *)
let green c = Triple.snd c

(* Extract blue component.  *)
let blue c = Triple.trd c

let make (r, g, b) = Triple.(map float_of_int (make r g b))

(* Same as [make] but with float RBG components.  *)
let make_float (r, g, b) = Triple.make r g b

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

(* Per-component scalar multiplication.  *)
let shift k c = Triple.map (( *. ) k) c

(* Return the distance between the two given colors seen like points in
   the three-dimensional space.  *)
let dist c c' = norm (diff c c')


type color_cloud = {
  id : int;                     (* Identifier.  *)
  center : t;                   (* Center point.  *)
  min : t;                      (* Minimal point.  *)
  max : t                       (* Maximal point.  *)
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

let make_cloud col_cloud =
  (* Compute the "minimal" and "maximal" points of [col_cloud].  *)
  let min_max (min_col, max_col) col =
    let aux min_or_max col' =
      make_float (min_or_max (red col) (red col'),
                  min_or_max (green col) (green col'),
                  min_or_max (blue col) (blue col'))
    in
    (aux min min_col, aux max max_col)
  in

  let make x = make_float (x, x, x) in
  let min, max =
    List.fold_left min_max (make infinity, make neg_infinity) col_cloud in
  {
    id = next_id ();
    center = average col_cloud;
    min = min;
    max = max
  }

let string_of_cloud c =
  Printf.sprintf "color_cloud(id = %d, center = %s, min = %s, max = %s)"
    c.id (to_string c.center) (to_string c.min) (to_string c.max)

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
  let epsilon = make (2, 2, 2) in
  geq col (diff col_cloud.min epsilon) && leq col (add col_cloud.max epsilon)
