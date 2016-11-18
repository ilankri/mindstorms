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

(** Simple representation of a path finder. *)

(** {2 Path finder creation} *)

module type PATH_FINDER = sig
  
  val get_path : unit -> string
  (** [get_path ()] returns the calculated path.
      The path is calculated only once. *)
    
  val is_available : unit -> bool
  (** [is_available ()] check if the path is available.contents *)
    
end
(** The signature of every path finder implementation *)


module type CONDITIONS = sig
  
  val prefix : string
  (** [prefix] is the the prefix path where to search *)
    
  val conditions : (string * string) list
  (** [conditions] is a list of (filename, expected_value). *)
      
end
(** Conditions to search the correct path *)



module Make(C : CONDITIONS) : PATH_FINDER
(** Create a path finder with the given conditions. *)


module Make_absolute(C : sig val path : string end) : PATH_FINDER
(** Create an absolute path. It's the same as using Make with empty
    conditions. *)

(*
Local Variables:
compile-command: "make -C .."
End:
*)
