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

(** Module handling different ports. *)


type input_port  = Input1 | Input2 | Input3 | Input4
(** The type of input port. Used by sensors. *)


type output_port = OutputA | OutputB | OutputC | OutputD
(** The type of output port. Used by motors. *)

module type INPUT_PORT = sig

  val input_port : input_port
  (** The chosen input port. *)

end
(** Allow to use an input port choice as a functor. *)

module type OUTPUT_PORT = sig

  val output_port : output_port
  (** The chosen output port. *)

end
(** Allow to use an output port choice as a functor. *)


val string_of_input_port : input_port -> string
(** [string_of_input_port ip] returns the string value of [ip] *)

val string_of_output_port : output_port -> string
(** [string_of_output_port op] returns the string value of [op] *)
