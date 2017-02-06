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

(** Contains every module used to handle motors. *)

(** {1 Generalities} *)

module type COMMANDS = sig

  type commands
  (** The type of different commands *)

  val string_of_command : commands -> string
  (** [string_of_command cmd] returns the string value of [cmd] *)

end
(** The module containing commands used by the motor. *)


module type MOTOR_INFOS = sig

  val output_port : Port.output_port
  (** The port where to find the motor. *)

  val motor_name  : string
  (** The motor name which can be find in the file 'name' *)

end
(** The module containing information to find the folder associated to the
    motor *)


module type AbstractMotor = sig

  include Device.DEVICE

  include COMMANDS

  type polarity = Normal | Inversed
  (** The type of polarity *)

  type state = Running | Ramping
  (** The type of state.  *)

  val send_command : commands -> unit
  (** [send_command cmd] send [cmd] to the motor. *)

  val driver_name : unit -> string
  (** [driver_name ()] returns the driver name. *)

  val port_name : unit -> string
  (** [port_name ()] returns the port name. *)

  val polarity : unit -> polarity
  (** [polarity ()] returns the current polarity of the motor. *)

  val set_polarity : polarity -> unit
  (** [polarity p] change the polarity of the motor to [p]. *)

  val state : unit -> state
  (** [state ()] returns the current state of the motor. *)

end
(** Common functions on every implemented motors. *)


module Make_abstract_motor
    (C : COMMANDS) (DI : Device.DEVICE_INFO)
    (P : Path_finder.PATH_FINDER) : AbstractMotor
(** Constructor of an abstract motor, by giving all of the commands used by
    the motor, the device information to save it correctly in the database,
    and the path finder to assure a link between the motor and its folder. *)


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
(** Common functionality between DcMotors and TachoMotors. *)

(** {1 Motor implementation} *)

(** {2 Servo Motor} *)

module type SERVO_MOTOR_TYPE = sig

  type servo_commands =
    | Run                       (** Send the "run" command *)
    | Float                     (** Send the "float" command *)
  (** ServoMotor allowable commands *)

  include AbstractMotor
    with type commands := servo_commands

  val max_pulse_sp : unit -> int
  (** [max_pulse_sp ()] returns the value of the file "max_pulse_sp" *)

  val set_max_pulse_sp : int -> unit
  (** [set_max_pulse_sp i] change the value of the file "max_pulse_sp".
      It must respect the following assertion : [2300 <= i <= 2700] *)

  val mid_pulse_sp : unit -> int
  (** [mid_pulse_sp ()] returns the value of the file "mid_pulse_sp" *)

  val set_mid_pulse_sp : int -> unit
  (** [set_mid_pulse_sp i] change the value of the file "mid_pulse_sp"
      It must respect the following assertion : [1300 <= i <= 1700] *)

  val min_pulse_sp : unit -> int
  (** [min_pulse_sp ()] returns the value of the file "min_pulse_sp" *)

  val set_min_pulse_sp : int -> unit
  (** [set_min_pulse_sp i] change the value of the file "min_pulse_sp"
      It must respect the following assertion : [300 <= i <= 700] *)

  val position_sp : unit -> int
  (** [position_sp ()] returns the value of the file "position_sp" *)

  val set_position_sp : int -> unit
  (** [set_position_sp i] change the value of the file "position_sp" *)

  val rate_sp : unit -> int
  (** [rate_sp ()] returns the value of the file "rate_sp" *)

  val set_rate_sp : int -> unit
  (** [set_rate_sp i] change the value of the file "rate_sp" *)

end
(** Module type of a ServoMotor. *)

module ServoMotor (DI : Device.DEVICE_INFO) (M : MOTOR_INFOS) : SERVO_MOTOR_TYPE
(** Construct a ServoMotor according to the device information, and the motor
    information *)


(** {2 Tacho Motors} *)

module type TM_MOTOR_TYPE = sig

  type tm_commands =
    | RunForever                (** Send the command "run-forever" *)
    | RunToAbsPos               (** Send the command "run-to-abs-pos" *)
    | RunToRelPos               (** Send the command "run-to-rel-pos" *)
    | RunTimed                  (** Send the command "run-timed" *)
    | RunDirect                 (** Send the command "run-direct" *)
    | Stop                      (** Send the command "stop" *)
    | Reset                     (** Send the command "reset" *)
  (** Command allowable for a Tacho Motor *)


  (** Possible states for a Tacho Motor.  See {{:
      http://www.ev3dev.org/docs/drivers/tacho-motor-class/} EV3 doc}
      for the meaning of states.  *)
  type tm_state =
    | Running
    | Ramping
    | Holding
    | Stalled

  include AbstractMotor
    with type commands := tm_commands

  include DC_AND_TM_COMMON

  val state : unit -> tm_state
  (** [state ()] returns the motor's state. It contains more possible values
      than the abstract motor. *)

  val set_ramp_down_sp : int -> unit
  (** [set_ramp_down_sp i] set the value of the file "ramp_down_sp". It must
      respect the following assertion: [i >= 0]. *)

  val set_ramp_up_sp : int -> unit
  (** [set_ramp_up_sp i] set the value of the file "ramp_up_sp". It must
      respect the following assertion: [i >= 0]. *)

  val count_per_rot : unit -> int
  (** [count_per_rot ()] returns the value of the file "count_per_rot" *)

  val encoder_polarity : unit -> polarity
  (** [encoder_polarity ()] returns the current encoder polarity of the
      motor. *)

  val set_encoder_polarity : polarity -> unit
  (** [set_encoder_polarity p] change the polarity of the motor to [p]. *)

  val hold_pid_d : unit -> int
  (** [hold_pid_d ()] returns the value of the file "hold_pid/Kd" *)

  val set_hold_pid_d : int -> unit
  (** [set_hold_pid_d i] set to [i] the value of the file "hold_pid/Kd" *)

  val hold_pid_i : unit -> int
  (** [hold_pid_i ()] returns the value of the file "hold_pid/Ki" *)

  val set_hold_pid_i : int -> unit
  (** [set_hold_pid_i i] set to [i] the value of the file "hold_pid/Ki" *)

  val hold_pid_p : unit -> int
  (** [hold_pid_p ()] returns the value of the file "hold_pid/Kp" *)

  val set_hold_pid_p : int -> unit
  (** [set_hold_pid_p i] set to [i] the value of the file "hold_pid/Kp" *)

  val position : unit -> int
  (** [position ()] returns the value of the file "position" *)

  val set_position : int -> unit
  (** [position i] set to [i] the value of the file "position" *)

  val position_sp : unit -> int
  (** [position_sp ()] returns the value of the file "position_sp" *)

  val set_position_sp : int -> unit
  (** [position_sp i] set to [i] the value of the file "position_sp" *)

  val speed : unit -> int
  (** [speed ()] returns the value of the file "speed" *)

  val set_speed : int -> unit
  (** [speed i] set to [i] the value of the file "speed" *)

  val speed_sp : unit -> int
  (** [speed_sp ()] returns the value of the file "speed_sp" *)

  val set_speed_sp : int -> unit
  (** [speed_sp i] set to [i] the value of the file "speed_sp" *)

  val speed_regulation_enabled : unit -> bool
  (** [speed_regulation_enable ()] returns [true] if the speed regulation is
      enabled *)

  val set_speed_regulation : bool -> unit
  (** [set_speed_regulation b] change the speed regulation mode to [b]. *)

  val speed_pid_d : unit -> int
  (** [speed_pid_d ()] returns the value of the file "speed_pid/Kd" *)

  val set_speed_pid_d : int -> unit
  (** [set_speed_pid_d i] set to [i] the value of the file "speed_pid/Kd" *)

  val speed_pid_i : unit -> int
  (** [speed_pid_i ()] returns the value of the file "speed_pid/Ki" *)

  val set_speed_pid_i : int -> unit
  (** [set_speed_pid_i i] set to [i] the value of the file "speed_pid/Ki" *)

  val speed_pid_p : unit -> int
  (** [speed_pid_p ()] returns the value of the file "speed_pid/Kp" *)

  val set_speed_pid_p : int -> unit
  (** [set_speed_pid_p i] set to [i] the value of the file "speed_pid/Kp" *)

end
(** Module type of a Tacho Motor *)

module TachoMotor (DI : Device.DEVICE_INFO) (M : MOTOR_INFOS) : TM_MOTOR_TYPE
(** Constructor a Tacho Motor according to its device informations and to its
    motor informations *)


(** {2 DC Motors} *)

module type DC_MOTOR_TYPE = sig

  type dc_commands =
    | RunForever                (** Send the command "run-forever" *)
    | RunTimed                  (** Send the command "run-timed" *)
    | Stop                      (** Send the command "stop" *)
  (** The type of allowable commands for a DCMotor *)

  include AbstractMotor
    with type commands := dc_commands

  include DC_AND_TM_COMMON

  val set_ramp_down_sp : int -> unit
  (** [set_ramp_down_sp i] set the value of the file "ramp_down_sp". It must
      respect the following assertion: [0 <= i <= 10000]. *)

  val set_ramp_up_sp : int -> unit
  (** [set_ramp_up_sp i] set the value of the file "ramp_up_sp". It must
      respect the following assertion: [0 <= i <= 10000]. *)

end
(** Module type of a DC Motor. *)

module DCMotor (DI : Device.DEVICE_INFO) (M : MOTOR_INFOS) : DC_MOTOR_TYPE
(** Construct a DC Motor according to its device informations and to its motor
    informations *)
