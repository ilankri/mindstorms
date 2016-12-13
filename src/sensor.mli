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

exception IncorrectMode of string
(** exception raised when trying to read a value for an incorrect mode. *)

type 'a ufun = unit -> 'a
(** Type of function taking unit and returning any values. It's useless to
    write different kind of values for a sensor. *)

type int_tuple2  = int * int
(** Representation of tuple with 2 elements *)

type int_tuple3  = int * int * int
(** Representation of tuple with 3 elements *)

type int_tuple4  = int * int * int * int
(** Representation of tuple with 4 elements *)

type int_tuple5  = int * int * int * int * int
(** Representation of tuple with 5 elements *)

type int_tuple6  = int * int * int * int * int * int
(** Representation of tuple with 6 elements *)

type int_tuple7  = int * int * int * int * int * int * int
(** Representation of tuple with 7 elements *)

type int_tuple8  = int * int * int * int * int * int * int * int
(** Representation of tuple with 8 elements *)

type int_tuple9  = int * int * int * int * int * int * int * int * int
(** Representation of tuple with 9 elements *)

type int_tuple10 = int * int * int * int * int * int * int * int * int * int
(** Representation of tuple with 10 elements *)


module type COMMANDS = sig
  type commands
  (** Type of commands. It has no meanings for sensor yet. *)

  val string_of_commands : commands -> string
  (** [string_of_commands c] returns the string value of the commands [c].
      Fails for sensor that doesn't implements a command system. *)
end
(** Commands module type used by sensors. Should fail for sensor that doesn't
    have a command system. *)

module type MODES = sig
  type modes
  (** Type of modes for a sensor. *)

  val string_of_modes : modes -> string
  (** [string_of_modes m] return the string value of the mode [m]. *)

  val modes_of_string : string -> modes
  (** [modes_of_string s] return the mode corresponding to the string.
      raise Assert_failure if it's not a correct string. *)

  val default_mode    : modes
  (** [default_mode] is the default mode of the sensor at connection. *)
end

module type AbstractSensor = sig

  include Device.DEVICE
  include COMMANDS
  include MODES

  val set_mode : modes -> unit
  (** [set_mode m] change the mode of the current sensor. *)

  val get_mode : unit -> modes
  (** [get_mode ()] returns the current mode of the sensor. *)

  val toggle_auto_change_mode : unit -> unit
  (** [toggle_auto_change_mode ()] set or unset the comportment when trying to
      read value with incorrect mode. If the auto_set_mode is set to true, then
      the sensor change silently its mode to read the correct value. Otherwise,
      it raise the exception [IncorrectMode str].*)

  val set_auto_change_mode : bool -> unit
  (** [set_auto_change_mode b] set the auto change mode to [b].
      see toggle_auto_change_mode *)

  val value0 : int ufun
  (** [value0 ()] read the file 'value0'. *)

  val value1 : int ufun
  (** [value1 ()] read the file 'value1'. *)

  val value2 : int ufun
  (** [value2 ()] read the file 'value2'. *)

  val value3 : int ufun
  (** [value3 ()] read the file 'value3'. *)

  val value4 : int ufun
  (** [value4 ()] read the file 'value4'. *)

  val value5 : int ufun
  (** [value5 ()] read the file 'value5'. *)

  val value6 : int ufun
  (** [value6 ()] read the file 'value6'. *)

  val value7 : int ufun
  (** [value7 ()] read the file 'value7'. *)

  val value8 : int ufun
  (** [value8 ()] read the file 'value8'. *)

  val value9 : int ufun
  (** [value9 ()] read the file 'value9'. *)


  val read1  : int ufun
  (** [read1 ()] read 1 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read2  : int_tuple2 ufun
  (** [read2 ()] read 2 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)


  val read3  : int_tuple3 ufun
  (** [read3 ()] read 3 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)


  val read4  : int_tuple4 ufun
  (** [read4 ()] read 4 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read5  : int_tuple5 ufun
  (** [read5 ()] read 5 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read6  : int_tuple6 ufun
  (** [read6 ()] read 6 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read7  : int_tuple7 ufun
  (** [read7 ()] read 7 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read8  : int_tuple8 ufun
  (** [read8 ()] read 8 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read9  : int_tuple9 ufun
  (** [read9 ()] read 9 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val read10 : int_tuple10 ufun
  (** [read10 ()] read 10 value. BEWARE: DOESN'T CHECK THE MODE (COULD LEAD TO
      UNDEFINED BEHAVIORS). *)

  val checked_read : (unit -> 'a) -> modes -> unit -> 'a
  (** [checked_read read_fun m ()] use the [read_fun] to get expected
      values, by checking if the mode [m] is the one actually set to the sensor.
      For example: {[ let reader = checked_read read4 MyMode ]} creates a
      function which will returns 4 values, and check if the current mode
      is {[ MyMode ]}. *)
end
(** Representation of an abstract sensor. *)

module Make_abstract_sensor
    (C : COMMANDS) (M : MODES) (DI : Device.DEVICE_INFO)
    (P : Path_finder.PATH_FINDER) :
  AbstractSensor
  with type modes = M.modes
   and type commands = C.commands
(** Create an abstract sensor according to its commands, its modes, its
    informations and where to find it. *)
