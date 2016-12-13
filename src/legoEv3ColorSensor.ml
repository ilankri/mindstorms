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
open Port
open Sensor

module type LEGO_EV3_COLOR_SENSOR = sig
  type lego_ev3_color_sensor_commands = unit
  type lego_ev3_color_sensor_modes =
    | COL_REFLECT
    | COL_AMBIENT
    | COL_COLOR
    | REF_RAW
    | RGB_RAW
    | COL_CAL

  include Sensor.AbstractSensor
    with type commands := lego_ev3_color_sensor_commands
     and type modes    := lego_ev3_color_sensor_modes

  val reflected_light : int ufun
  val ambient_light : int ufun
  val color : int ufun
  val raw_reflected : int_tuple2 ufun
  val raw_color_components : int_tuple3 ufun
  val color_calibration : int_tuple4 ufun
end

module LegoEv3ColorSensor (DI : DEVICE_INFO)
    (P : INPUT_PORT) = struct
  type lego_ev3_color_sensor_commands = unit
  type lego_ev3_color_sensor_modes =
    | COL_REFLECT
    | COL_AMBIENT
    | COL_COLOR
    | REF_RAW
    | RGB_RAW
    | COL_CAL

  module LegoEv3ColorSensorCommands = struct
    type commands = lego_ev3_color_sensor_commands
    let string_of_commands = function
      | _ -> failwith "commands are not available for this sensor."

  end

  module LegoEv3ColorSensorModes = struct
    type modes = lego_ev3_color_sensor_modes
    let modes_of_string = function
      | "COL-REFLECT" -> COL_REFLECT
      | "COL-AMBIENT" -> COL_AMBIENT
      | "COL-COLOR" -> COL_COLOR
      | "REF-RAW" -> REF_RAW
      | "RGB-RAW" -> RGB_RAW
      | "COL-CAL" -> COL_CAL
      | _ -> assert false

    let string_of_modes = function
      | COL_REFLECT -> "COL-REFLECT"
      | COL_AMBIENT -> "COL-AMBIENT"
      | COL_COLOR -> "COL-COLOR"
      | REF_RAW -> "REF-RAW"
      | RGB_RAW -> "RGB-RAW"
      | COL_CAL -> "COL-CAL"

    let default_mode = COL_REFLECT
  end

  module LegoEv3ColorSensorPathFinder = Path_finder.Make(struct
      let prefix = "/sys/class/lego-sensor"
      let conditions = [
        ("driver_name", "lego-ev3-color");
        ("address", string_of_input_port P.input_port)
      ]
    end)

  include Make_abstract_sensor(LegoEv3ColorSensorCommands)
      (LegoEv3ColorSensorModes)(DI)(LegoEv3ColorSensorPathFinder)

  let reflected_light = checked_read read1 COL_REFLECT
  let ambient_light = checked_read read1 COL_AMBIENT
  let color = checked_read read1 COL_COLOR
  let raw_reflected = checked_read read2 REF_RAW
  let raw_color_components = checked_read read3 RGB_RAW
  let color_calibration = checked_read read4 COL_CAL
end
