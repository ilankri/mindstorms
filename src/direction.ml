type t = Left | Right

let opposite = function
  | Left -> Right
  | Right -> Left

let random =
  Random.self_init ();
  fun () ->
    let rdm = Random.int 2 in
    if rdm = 1 then Left else Right

let to_string = function
  | Left -> "left"
  | Right -> "right"
