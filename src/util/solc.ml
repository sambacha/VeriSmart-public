open Options
open Vocab

exception CompilationError
exception UnsupportedSolc

let solc_lst = (* 0.4.11 does not support compact json option. *)
  ["0.4.16"; "0.4.17"; "0.4.18"; "0.4.19"; "0.4.20"; "0.4.21"; "0.4.23"; "0.4.24"; "0.4.25"; "0.4.26";
   "0.5.0"; "0.5.1"; "0.5.2"; "0.5.3"; "0.5.4"; "0.5.5"; "0.5.6"; "0.5.7"; "0.5.8"; "0.5.9"; "0.5.10";
   "0.5.11"; "0.5.12"; "0.5.13"; "0.5.14"; "0.5.15"; "0.5.16"; "0.5.17";
   "0.6.0"; "0.6.1"; "0.6.2"; "0.6.3"; "0.6.4"; "0.6.5"; "0.6.6"; "0.6.7"; "0.6.8"; "0.6.9"; "0.6.10"; "0.6.11"; "0.6.12";
   "0.7.0"; "0.7.1"; "0.7.2"; "0.7.3"; "0.7.4"; "0.7.5"; "0.7.6";
   "0.8.0"; "0.8.1"; "0.8.2"; "0.8.3"; "0.8.4"; "0.8.5"; "0.8.6"
  ]

let get_solc () =
  if !Options.solc_ver = "" then "solc"
  else if !Options.solc_ver = "0.5.0" then "solc_0.5.1" (* solc_0.5.0 --ast-compact-json produces a solc error. *)
  else if BatString.starts_with !Options.solc_ver "0.4" && not (List.mem !solc_ver solc_lst) then "solc_0.4.25"
  else if List.mem !solc_ver solc_lst then "solc_" ^ !solc_ver (* e.g., solc_0.4.25 *)
  else raise UnsupportedSolc

let get_json_ast file =
  let buf = Unix.open_process_in (get_solc() ^ " --ast-compact-json " ^ !inputfile ^ " 2>/dev/null") in
  try
    let _ = ignore (input_line buf); ignore (input_line buf); ignore (input_line buf); ignore (input_line buf) in
    let json = Yojson.Basic.from_channel buf in
    match Unix.close_process_in buf with
    | WEXITED 0 -> json
    | _ -> assert false
  with e ->
    match Unix.close_process_in buf with
    | WEXITED n when n!=0 -> raise CompilationError
    | _ -> assert false
