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

(** Implementation of the sensor legoEv3ColorSensor.  Documentation
    {{:http://www.ev3dev.org/docs/sensors/lego-ev3-color-sensor/}
    page} *)
open Device
open Port
open Sensor

module type LEGO_EV3_COLOR_SENSOR = sig
  type lego_ev3_color_sensor_commands = unit
  type lego_ev3_color_sensor_modes =
    | COL_REFLECT (** Constructor for COL_REFLECT mode. *)
    | COL_AMBIENT (** Constructor for COL_AMBIENT mode. *)
    | COL_COLOR (** Constructor for COL_COLOR mode. *)
    | REF_RAW (** Constructor for REF_RAW mode. *)
    | RGB_RAW (** Constructor for RGB_RAW mode. *)
    | COL_CAL (** Constructor for COL_CAL mode. *)
  (** Type for modes of the sensor lego_ev3_color_sensor_modes. *)

  include Sensor.AbstractSensor
    with type commands := lego_ev3_color_sensor_commands
     and type modes    := lego_ev3_color_sensor_modes

  val reflected_light : int ufun
  (** [reflected_light ()] returns the current value of the mode
      reflected_light *)

  val ambient_light : int ufun
  (** [ambient_light ()] returns the current value of the mode ambient_light *)

  val color : int ufun
  (** [color ()] returns the current value of the mode color *)

  val raw_reflected : int_tuple2 ufun
  (** [raw_reflected ()] returns the current value of the mode raw_reflected *)

  val raw_color_components : int_tuple3 ufun
  (** [raw_color_components ()] returns the current value of the mode
      raw_color_components *)

  val color_calibration : int_tuple4 ufun
  (** [color_calibration ()] returns the current value of the mode
      color_calibration *)

end

module LegoEv3ColorSensor (DI : DEVICE_INFO) (P : INPUT_PORT)
  : LEGO_EV3_COLOR_SENSOR
(** Implementation of Lego Ev3 Color Sensor. *)
