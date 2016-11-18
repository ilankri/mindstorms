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

module type PATH_FINDER = sig
  val get_path : unit -> string
  val is_available : unit -> bool
end

module type CONDITIONS = sig
  val prefix : string
  val conditions : (string * string) list
end

module Make(C : CONDITIONS) = struct

  let saved_path = ref None

  let find_in_array array =
    let buffer = C.prefix in
    let rec aux i =
      if i >= Array.length array then
        None
      else begin
        let next_path = Filename.concat buffer array.(i) in
        let is_valid =
          Sys.is_directory next_path &&
          List.for_all (fun (file, expected_value) ->
              let file = Filename.concat next_path file in
              IO.read_string file = expected_value
            ) C.conditions
        in
        if is_valid then Some next_path else aux (succ i)
      end
    in aux 0

  let find_path () =
    if C.conditions = [] then C.prefix
    else match find_in_array (Sys.readdir C.prefix) with
      | None   -> raise Not_found
      | Some s -> s

  let get_path () =
    match !saved_path with
    | None ->
      let path = find_path () in
      saved_path := Some path;
      path
    | Some path ->
      path

  let is_available () = !saved_path <> None

end

module Make_absolute(C : sig val path : string end) = struct
  include Make(struct
      let prefix = C.path
      let conditions = []
    end)
end

(*
Local Variables:
compile-command: "make -C .."
End:
*)
