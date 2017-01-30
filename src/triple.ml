type 'a t = 'a * 'a * 'a

let make x y z = (x, y, z)

let fst (x, _, _) = x

let snd (_, y, _) = y

let trd (_, _, z) = z

let map f t  = make (f (fst t)) (f (snd t)) (f (trd t))

let map2 f t t' =
  make (f (fst t) (fst t')) (f (snd t) (snd t')) (f (trd t) (trd t'))

let to_tuple t = t
