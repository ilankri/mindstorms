type t = Left | Right

let opposite = function
  | Left -> Right
  | Right -> Left

let random () =
  let rdm = Random.int 2 in
  if rdm = 1 then Left else Right
