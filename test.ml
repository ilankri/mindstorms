let prefix = "/sys/class/tacho-motor/"

module MotorA_path_finder =
  Path_finder.Make_absolute(struct
    let path = prefix ^ "motor0/"
  end)

module MotorB_path_finder =
  Path_finder.Make_absolute(struct
    let path = prefix ^ "motor1/"
  end)

module MotorA_dev =
  Device.Make_device (struct
    let name = "motorA" let multiple_connection = true
  end) (MotorA_path_finder)

module MotorB_dev = Device.Make_device (struct
    let name = "motorB"
    let multiple_connection = true
  end) (MotorB_path_finder)

let main () =
  let set_time_sp i =
    let filename = "time_sp" in
    MotorA_dev.action_write_int i filename;
    MotorB_dev.action_write_int i filename in
  let set_duty_cycle_sp i =
    let filename = "duty_cycle_sp" in
    MotorA_dev.action_write_int i filename;
    MotorB_dev.action_write_int i filename in
  let set_command s =
    let filename = "command" in
    MotorA_dev.action_write_string s filename;
    MotorB_dev.action_write_string s filename
  in
  MotorA_dev.connect ();
  MotorB_dev.connect ();
  set_time_sp 5000;
  set_duty_cycle_sp 20;
  set_command "run-timed";
  MotorA_dev.disconnect ();
  MotorB_dev.disconnect ();
  exit 0

let _ = main ()
