type rotation = Left | Right

module LM =
  Motor.TachoMotor
    (struct
      let name = "left_motor"
      let multiple_connection = true
    end)
    (struct let output_port = Port.OutputD end)

module RM =
  Motor.TachoMotor
    (struct
      let name = "right_motor"
      let multiple_connection = true
    end)
    (struct let output_port = Port.OutputA end)

type motor_flag = LM | RM | Dual

let apply_to_both cmd =
  cmd LM;
  cmd RM

let rec connect' = function
  | LM ->
    LM.connect ();
    LM.send_command LM.Reset
  | RM ->
    RM.connect ();
    RM.send_command RM.Reset
  | Dual -> apply_to_both connect'

let connect () = connect' Dual

let rec disconnect' = function
  | LM -> LM.disconnect ()
  | RM -> RM.disconnect ()
  | Dual -> apply_to_both disconnect'

let disconnect () = disconnect' Dual

let rec run = function
  | LM -> LM.send_command LM.RunForever
  | RM -> RM.send_command RM.RunForever
  | Dual -> apply_to_both run

let rec set_speed' speed = function
  | LM -> LM.set_speed_sp speed;
  | RM -> RM.set_speed_sp speed;
  | Dual -> apply_to_both (set_speed' speed)

let set_speed speed = set_speed' speed Dual

let move_forward () = run Dual

let get_speed = function
  | LM -> LM.speed_sp ()
  | RM -> RM.speed_sp ()
  | Dual -> assert false

let rec stop' = function
  | LM -> LM.send_command LM.Stop
  | RM -> RM.send_command RM.Stop
  | Dual -> apply_to_both stop'

let stop () = stop' Dual

let rotate dir =
  let motor_flag =
    match dir with
    | Left -> LM
    | Right -> RM
  in
  set_speed' (get_speed motor_flag asr 1) motor_flag;
  run motor_flag

let random_rotation() =
  let rdm = Random.int 2
  in
  if rdm=1 then Left else Right;;

let opposite r =
  match r with
  | Left -> Right
  | _ -> Left;;
