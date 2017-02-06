(*****************************************************************************)
(* The MIT License (MIT)                                                     *)
(*                                                                           *)
(* Copyright (c) 2015 OCamlEV3                                               *)
(*  Loïc Runarvot <loic.runarvot[at]gmail.com>                               *)
(*  Nicolas Tortrat-Gentilhomme <nicolas.tortrat[at]gmail.com>               *)
(*  Nicolas Raymond <noci.64[at]orange.fr>                                   *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   *)
(* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                *)
(* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    *)
(* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      *)
(* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT *)
(* OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  *)
(* THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                *)
(*****************************************************************************)

open Device
open Path_finder
open Port

let invalid_value device_name kind value =
  raise (Invalid_value
           (Printf.sprintf "%s:%s:%s" device_name kind value))

module type COMMANDS = sig
  type commands
  val string_of_command : commands -> string
end

module type MOTOR_INFOS = sig
  val output_port : output_port
  val motor_name  : string
end

module type AbstractMotor = sig
  include DEVICE
  include COMMANDS

  type polarity = Normal | Inversed

  type state = Running | Ramping

  val send_command : commands -> unit
  val driver_name : unit -> string
  val port_name : unit -> string
  val polarity : unit -> polarity
  val set_polarity : polarity -> unit
  val state : unit -> state
end

module Make_abstract_motor
    (C : COMMANDS) (DI : DEVICE_INFO) (P : PATH_FINDER) =
struct

  include Make_device(DI)(P)

  include C

  type polarity = Normal | Inversed

  let read_polarity = action_read (IO.mk_reader (function
      | "normal" -> Normal
      | "inversed" -> Inversed
      | _ -> assert false
    ))
  let write_command  = action_write (IO.mk_writer string_of_command)
  let write_polarity =
    action_write (IO.mk_writer (fun polarity ->
        match polarity with
        | Normal   -> "normal"
        | Inversed -> "inversed"
      ))

  let send_command cmd =
    write_command cmd "command"

  let driver_name () =
    action_read_string "driver_name"

  let polarity () =
    read_polarity "polarity"

  let set_polarity p =
    write_polarity p "polarity"

  let state () =
    match action_read_string "state" with
    | "running" -> Running
    | "ramping" -> Ramping
    | _ -> assert false

  let port_name () =
    action_read_string "port_name"

end

(* SERVO MOTOR *)

module type SERVO_MOTOR_TYPE = sig

  type servo_commands =
    | Run
    | Float

  include AbstractMotor
    with type commands := servo_commands

  val max_pulse_sp : unit -> int
  val set_max_pulse_sp : int -> unit
  val mid_pulse_sp : unit -> int
  val set_mid_pulse_sp : int -> unit
  val min_pulse_sp : unit -> int
  val set_min_pulse_sp : int -> unit
  val position_sp : unit -> int
  val set_position_sp : int -> unit
  val rate_sp : unit -> int
  val set_rate_sp : int -> unit

end

module ServoMotor (DI : DEVICE_INFO) (M : MOTOR_INFOS) = struct

  type servo_commands =
    | Run
    | Float

  module ServoMotorCommands = struct

    type commands = servo_commands

    let string_of_command = function
      | Run -> "run"
      | Float -> "float"

  end

  module ServoMotorPathFinder = Path_finder.Make(struct
      let prefix = "/sys/class/servo-motor/"
      let conditions = [
        ("name", M.motor_name);
        ("port", string_of_output_port M.output_port);
      ]
    end)

  include Make_abstract_motor
      (ServoMotorCommands)(DI)(ServoMotorPathFinder)


  let max_pulse_sp () =
    action_read_int "max_pulse_sp"

  let set_max_pulse_sp i =
    if i < 2300 || i > 2700 then
      invalid_value DI.name "set_max_pulse_sp" (string_of_int i);
    action_write_int i "max_pulse_sp"

  let mid_pulse_sp () =
    action_read_int "mid_pulse_sp"

  let set_mid_pulse_sp i =
    if i < 1300 || i > 1700 then
      invalid_value DI.name "set_mid_pulse_sp" (string_of_int i);
    action_write_int i "mid_pulse_sp"

  let min_pulse_sp () =
    action_read_int "min_pulse_sp"

  let set_min_pulse_sp i =
    if i < 300 || i > 700 then
      invalid_value DI.name "set_min_pulse_sp" (string_of_int i);
    action_write_int i "min_pulse_sp"

  let position_sp () =
    action_read_int "position_sp"

  let set_position_sp i =
    if i < (-100) || i > 100 then
      invalid_value DI.name "set_position_sp" (string_of_int i);
    action_write_int i "position_sp"

  let rate_sp () =
    action_read_int "rate_sp"

  let set_rate_sp i =
    action_write_int i "rate_sp"

end


(* TM & DC COMMON *)

module type DC_AND_TM_COMMON = sig
  type stop_action = Coast | Brake

  val duty_cycle : unit -> int
  val duty_cycle_sp : unit -> int
  val set_duty_cycle_sp : int -> unit
  val stop : stop_action -> unit
  val ramp_down_sp : unit -> int
  val set_ramp_down_sp : ?valid:(int -> bool) -> int -> unit
  val ramp_up_sp : unit -> int
  val set_ramp_up_sp : ?valid:(int -> bool) -> int -> unit
  val time_sp : unit -> int
  val set_time_sp : int -> unit
end

module DcAndTmCommons (D : DEVICE) (DI : DEVICE_INFO) = struct
  let duty_cycle () =
    D.action_read_int "duty_cycle"

  let duty_cycle_sp () =
    D.action_read_int "duty_cycle_sp"

  let set_duty_cycle_sp i =
    if i < (-100) || i > 100 then
      invalid_value DI.name "set_duty_cycle_sp" (string_of_int i);
    D.action_write_int i "duty_cycle_sp"

  let stop s =
    let action = match s with
      | Coast -> "coast"
      | Brake -> "brake"
    in
    D.action_write_string action "stop"

  let ramp_down_sp () =
    D.action_read_int "ramp_down_sp"

  let set_ramp_down_sp ?(valid = fun _ -> true) i =
    if not (valid i) then
      invalid_value DI.name "set_ramp_down_sp" (string_of_int i);
    D.action_write_int i "ramp_down_sp"

  let ramp_up_sp () =
    D.action_read_int "ramp_up_sp"

  let set_ramp_up_sp ?(valid = fun _ -> true) i =
    if not (valid i) then
      invalid_value DI.name "set_ramp_up_sp" (string_of_int i);
    D.action_write_int i "ramp_up_sp"

  let time_sp () =
    D.action_read_int "time_sp"

  let set_time_sp i =
    D.action_write_int i "time_sp"

end

(* TACHO MOTOR *)

module type TM_MOTOR_TYPE = sig

  type tm_commands =
    | RunForever
    | RunToAbsPos
    | RunToRelPos
    | RunTimed
    | RunDirect
    | Stop
    | Reset

  type tm_state =
    | Running
    | Ramping
    | Holding
    | Stalled

  include AbstractMotor
    with type commands := tm_commands

  include DC_AND_TM_COMMON

  val state : unit -> tm_state
  val set_ramp_down_sp : int -> unit
  val set_ramp_up_sp : int -> unit
  val count_per_rot : unit -> int
  val encoder_polarity : unit -> polarity
  val set_encoder_polarity : polarity -> unit
  val hold_pid_d : unit -> int
  val set_hold_pid_d : int -> unit
  val hold_pid_i : unit -> int
  val set_hold_pid_i : int -> unit
  val hold_pid_p : unit -> int
  val set_hold_pid_p : int -> unit
  val position : unit -> int
  val set_position : int -> unit
  val position_sp : unit -> int
  val set_position_sp : int -> unit
  val speed : unit -> int
  val set_speed : int -> unit
  val speed_sp : unit -> int
  val set_speed_sp : int -> unit
  val speed_regulation_enabled : unit -> bool
  val set_speed_regulation : bool -> unit
  val speed_pid_d : unit -> int
  val set_speed_pid_d : int -> unit
  val speed_pid_i : unit -> int
  val set_speed_pid_i : int -> unit
  val speed_pid_p : unit -> int
  val set_speed_pid_p : int -> unit
end


module TachoMotor (DI : DEVICE_INFO) (M : MOTOR_INFOS) = struct

  type tm_commands =
    | RunForever
    | RunToAbsPos
    | RunToRelPos
    | RunTimed
    | RunDirect
    | Stop
    | Reset

  module TMMotorCommands = struct

    type commands = tm_commands

    let string_of_command = function
      | RunForever  -> "run-forever"
      | RunToAbsPos -> "run-to-abs-pos"
      | RunToRelPos -> "run-to-rel-pos"
      | RunTimed    -> "run-timed"
      | RunDirect   -> "run-direct"
      | Stop        -> "stop"
      | Reset       -> "reset"

  end

  module TMMotorPathFinder = Path_finder.Make(struct
      let prefix = "/sys/class/tacho-motor/"
      let conditions = [
        ("name", M.motor_name);
        ("port", string_of_output_port M.output_port);
      ]
    end)

  module AbstractMotor =
    Make_abstract_motor
      (TMMotorCommands)(DI)(TMMotorPathFinder)

  include AbstractMotor
  include DcAndTmCommons(AbstractMotor)(DI)

  let write_bool =
    action_write (IO.mk_writer (fun x -> if x then "on" else "off"))

  let read_bool =
    action_read (IO.mk_reader (function
        | "on"  -> true
        | "off" -> false
        | _ -> assert false
      ))

  let state () =
    match action_read_string "state" with
    | "running" -> Running
    | "ramping" -> Ramping
    | "holding" -> Holding
    | "stalled" -> Stalled
    | _ -> assert false

  let set_ramp_up_sp = set_ramp_up_sp ~valid:(( <= ) 0)
  let set_ramp_down_sp = set_ramp_down_sp ~valid:(( <= ) 0)

  let count_per_rot () =
    action_read_int "count_per_rot"

  let encoder_polarity () =
    read_polarity "encoder_polarity"

  let set_encoder_polarity polarity =
    write_polarity polarity "encoder_polarity"

  let hold_pid_d () =
    action_read_int "hold_pid/Kd"

  let set_hold_pid_d i =
    action_write_int i "hold_pid/Kd"

  let hold_pid_i () =
    action_read_int "hold_pid/Ki"

  let set_hold_pid_i i =
    action_write_int i "hold_pid/Ki"

  let hold_pid_p () =
    action_read_int "hold_pid/Kp"

  let set_hold_pid_p i =
    action_write_int i "hold_pid/Kp"

  let position () =
    action_read_int "position"

  let set_position i =
    action_write_int i "position"

  let position_sp () =
    action_read_int "position_sp"

  let set_position_sp i =
    action_write_int i "position_sp"

  let speed () =
    action_read_int "speed"

  let set_speed i =
    action_write_int i "speed"

  let speed_sp () =
    action_read_int "speed_sp"

  let set_speed_sp i =
    action_write_int i "speed_sp"

  let speed_regulation_enabled () =
    read_bool "speed_regulation"

  let set_speed_regulation b =
    write_bool b "speed_regulation"

  let speed_pid_d () =
    action_read_int "speed_pid/Kd"

  let set_speed_pid_d i =
    action_write_int i "speed_pid/Kd"

  let speed_pid_i () =
    action_read_int "speed_pid/Ki"

  let set_speed_pid_i i =
    action_write_int i "speed_pid/Ki"

  let speed_pid_p () =
    action_read_int "speed_pid/Kp"

  let set_speed_pid_p i =
    action_write_int i "speed_pid/Kp"

end


(* DC MOTOR *)


module type DC_MOTOR_TYPE = sig

  type dc_commands =
    | RunForever
    | RunTimed
    | Stop

  include AbstractMotor
    with type commands := dc_commands

  include DC_AND_TM_COMMON

  val set_ramp_down_sp : int -> unit
  val set_ramp_up_sp : int -> unit

end

module DCMotor (DI : DEVICE_INFO) (M : MOTOR_INFOS) = struct

  type dc_commands =
    | RunForever
    | RunTimed
    | Stop

  type dc_state =
    | Running
    | Ramping

  module DCMotorCommands = struct
    type commands = dc_commands
    let string_of_command = function
      | RunForever -> "run-forever"
      | RunTimed   -> "run-timed"
      | Stop       -> "stop"
  end


  module DCState = struct
    type state = dc_state
    let state_of_string = function
      | "running" -> Running
      | "ramping" -> Ramping
      | _ -> assert false
  end

  module DCMotorPathFinder = Path_finder.Make(struct
      let prefix = "/sys/class/dc-motor/"
      let conditions = [
        ("name", M.motor_name);
        ("port", string_of_output_port M.output_port
        );
      ]
    end)

  module AbstractMotor =
    Make_abstract_motor
      (DCMotorCommands)(DI)(DCMotorPathFinder)

  include AbstractMotor
  include DcAndTmCommons(AbstractMotor)(DI)

  let set_ramp_up_sp =
    set_ramp_up_sp ~valid:(fun x -> x >= 0 && x <= 10000)

  let set_ramp_down_sp =
    set_ramp_down_sp ~valid:(fun x -> x >= 0 && x <= 10000)

end
