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

(** The IO module contains every usefull functions to read and write any data
    coming from a file.
    For now, it doesn't keep in memory any channel. *)


(** {2 Reader} *)

val mk_reader : (string -> 'a) -> (string -> 'a)
(** [mk_reader wrapper] create a reader where the given string is wrapped into
    the needed type.
    For example, int reader is created as [mk_reader int_of_string] *)

val read_string : string -> string
(** [read_string path] read the first line of the file at [path]. *)

val read_int : string -> int
(** [read_int path] read the first integer of the file at [path]. *)


(** {2 Writer} *)

val mk_writer : ('a -> string) -> (string -> 'a -> unit)
(** [mk_writer unwrapper] create a writer that make the transformation of the
    data into a string, and write it to the first line.
    For example, int writer is created as [mk_writer string_of_int] *)

val write_string : string -> string -> unit
(** [write_string path data] write [data] to the file at [path] *)

val write_int : string -> int -> unit
(** [write_int path data] write [data] as an integer to the file at [path] *)

(*
Local Variables:
compile-command: "make -C .."
End:
*)
