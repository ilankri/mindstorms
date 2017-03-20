module LM =
  Motor.TachoMotor
    (struct
      let name = "left_motor"
      let multiple_connection = false
    end)
    (struct let output_port = Port.OutputD end)

module RM =
  Motor.TachoMotor
    (struct
      let name = "right_motor"
      let multiple_connection = false
    end)
    (struct let output_port = Port.OutputA end)

type motor_flag = Left | Right | Both

let apply_to_both cmd =
  cmd Left;
  cmd Right

let rec connect' = function
  | Left ->
    LM.connect ();
    LM.send_command LM.Reset
  | Right ->
    RM.connect ();
    RM.send_command RM.Reset
  | Both -> apply_to_both connect'

let connect () = connect' Both

let rec disconnect' = function
  | Left -> LM.disconnect ()
  | Right -> RM.disconnect ()
  | Both -> apply_to_both disconnect'

let disconnect () = disconnect' Both

let rec start' = function
  | Left -> LM.send_command LM.RunDirect
  | Right -> RM.send_command RM.RunDirect
  | Both -> apply_to_both start'

let rec set_speed' speed = function
  | Left -> LM.set_duty_cycle_sp speed;
  | Right -> RM.set_duty_cycle_sp speed;
  | Both -> apply_to_both (set_speed' speed)

let set_speed speed = set_speed' speed Both

let start () = start' Both

let get_speed = function
  | Left -> LM.speed_sp ()
  | Right -> RM.speed_sp ()
  | Both -> assert false

let rec stop' = function
  | Left -> LM.send_command LM.Stop
  | Right -> RM.send_command RM.Stop
  | Both -> apply_to_both stop'

let stop () = stop' Both

let turn dir =
  let motor_to_speed_up, motor_to_slow_down =
    match dir with
    | Direction.Left -> (Right, Left)
    | Direction.Right -> (Left, Right)
  in
  set_speed' (get_speed motor_to_speed_up + 5) motor_to_speed_up;
  set_speed' (get_speed motor_to_slow_down / 5) motor_to_slow_down;
