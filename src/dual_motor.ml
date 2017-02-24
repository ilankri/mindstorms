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

let connect () =
  LM.connect ();
  RM.connect ();
  LM.send_command LM.Reset;
  RM.send_command RM.Reset

let disconnect () =
  LM.disconnect ();
  RM.disconnect ()

let set_speed speed =
  LM.set_duty_cycle_sp speed;
  RM.set_duty_cycle_sp speed

let move_forward () =
  LM.send_command LM.RunDirect;
  RM.send_command RM.RunDirect

let stop () =
  LM.send_command LM.Stop;
  RM.send_command RM.Stop

  
let rotate dir =
  match dir with
    Left ->
    begin
      RM.send_command RM.Stop;
      LM.send_command LM.Stop;
      LM.send_command LM.RunDirect
    end
   |_ -> ()
