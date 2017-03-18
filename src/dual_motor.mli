type rotation = Left | Right

val connect : unit -> unit

val disconnect : unit -> unit

val set_speed : int -> unit

val move_forward : unit -> unit

val stop : unit -> unit

val rotate : rotation -> unit

val random_rotation : unit -> rotation
			   
val opposite : rotation -> rotation
			     
