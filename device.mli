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

open Path_finder

(** A set of modules to create a device. *)

(** {2 Exceptions} *)

exception Connection_failed of string
(** Raised only when connection has failed. *)

exception Device_not_connected of string
(** Raised by all functions which needs the device connected. *)

exception Name_already_exists of string
(** Raised when two connected device have the same name, but two different paths *)

exception Invalid_value of string
(** Raised when a value is not valid for the device. *)

(** {2 Device construction} *)

module type DEVICE_INFO = sig

  val name : string
  (** The device's name.
      Two connected device can have the name, but they have to point to the
      same path to be valid, and have the [multiple_connection] set
      to on. *)

  val multiple_connection : bool
  (** Check if an another connection exists with the same name; if the boolean
      is set to false, then it raise an error. *)
  
end
(** Gives informations about the device. *)


module type DEVICE = sig

  val connect : unit -> unit
  (** [connect ()] connects the device and register it to the connected devices
      if no error occurs. 
      @raise Connection_failed when the path is not available
      @raise Name_already_exists when multiple connection is not allowed, or
      when two devices with the same name have not the same path. *)

  val disconnect : unit -> unit
  (** [disconnect ()] disconnect the device andremove it from the registered
      devices. 
      If the device is already disconnected, does nothing. *)
  
  val is_connected : unit -> bool
  (** [is_connected ()] check if the device is connected. *)

  val fail_when_disconnected : unit -> unit
  (** [fail_when_disconnected ()] check if the device is connected, and if
      not, raise Device_not_connected. *)
  
  val get_path : unit -> string
  (** [get_path ()] return the path associated to the device. *)
  
  val action_read : (string -> 'a) -> string -> 'a
  (** [action_read unwrapper subfile] will read to the device path at the
      file [subfile], returning the result using the wrapper. 
      @raise Device_not_connected when the device is disconnceted. *)

  val action_write : (string -> 'a -> unit) -> 'a -> string -> unit
  (** [action_write wrapper subfile] wrap the given data to a string and writes
      it to the device path, at the file [subfile].
      @raise Device_not_connected when the device is disconnceted. *)

  val action_read_int : string -> int
  (** [action_read_int filename] is a shortcut
      to [action_read IO.read_int filename] *)

  val action_write_int : int -> string -> unit
  (** [action_write_int i filename] is a shortcut to
      [action_write IO.write_int filename] *)

  val action_read_string : string -> string
  (** [action_read_string filename] is a shortcut
      to [action_read IO.read_string filename] *)

  val action_write_string : string -> string -> unit 
  (** [action_write_string i filename] is a shortcut to
      [action_write IO.write_string filename] *)
end
(** The signature of a Device. *)

module Make_device (DI : DEVICE_INFO) (P : PATH_FINDER) : DEVICE
(** Device Maker. *)

(*
Local Variables:
compile-command: "make -C .."
End:
*)
