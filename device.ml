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

exception Connection_failed of string
exception Device_not_connected of string
exception Name_already_exists of string
exception Invalid_value of string

(* Table name -> path; usefull for multiple connection *)
let device_table  : (string, string) Hashtbl.t = Hashtbl.create 13
let device_add    = Hashtbl.add device_table
let device_remove = Hashtbl.remove device_table
let device_mem    = Hashtbl.mem device_table
let device_find   = Hashtbl.find device_table

module type DEVICE = sig
  val connect : unit -> unit
  val disconnect : unit -> unit
  val is_connected : unit -> bool
  val fail_when_disconnected : unit -> unit
  val get_path : unit -> string
  val action_read : (string -> 'a) -> string -> 'a
  val action_write : (string -> 'a -> unit) -> 'a -> string -> unit
  val action_read_int : string -> int
  val action_write_int : int -> string -> unit
  val action_read_string : string -> string
  val action_write_string : string -> string -> unit 
end

module type DEVICE_INFO = sig
  val name : string
  val multiple_connection : bool
end

module Make_device (DI : DEVICE_INFO) (P : PATH_FINDER) = struct

  let connected =
    ref false
  
  let is_connected () =
    !connected
  
  let connect () =
    if not (is_connected ()) then begin

      let path = P.get_path () in

      if not (P.is_available ()) then
        raise (Connection_failed "Invalid path.");
      connected := true;

      if device_mem DI.name && not DI.multiple_connection then
        raise (Name_already_exists DI.name);
      
      if device_mem DI.name then begin
        let existing_path = device_find DI.name in
        if String.compare path existing_path <> 0 then
          raise (Name_already_exists
                   (Format.sprintf "%s : different path '%s' & '%s'"
                      DI.name path existing_path))
      end;
      device_add DI.name path
    end

  let disconnect () =
    if is_connected () then begin
      connected := false;
      device_remove DI.name
    end
      
  let get_path =
    P.get_path

  let fail_when_disconnected () =
    if not (is_connected ()) then
      raise (Device_not_connected DI.name)

  let get_complete_path subfile =
    let complete = Filename.concat (get_path ()) subfile in
    if not (Sys.file_exists complete) then
      failwith (Printf.sprintf "Invalid file %s" complete)
    else
      complete
  
  let action_read reader subfile =
    fail_when_disconnected ();
    reader (get_complete_path subfile)

  let action_write writer data subfile =
    fail_when_disconnected ();
    writer (get_complete_path subfile) data

  let action_read_int = action_read IO.read_int
  let action_write_int = action_write IO.write_int

  let action_read_string = action_read IO.read_string
  let action_write_string = action_write IO.write_string
end

(*
Local Variables:
compile-command: "make -C .."
End:
*)
