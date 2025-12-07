open Utils
open Str


let rec process_line (regex) (acc : string list) (lines: string list) : string list=
  begin match lines with
  | head :: tail -> 
      if Str.string_match regex head 0 then
        process_line regex (head::acc) tail
      else
        process_line regex acc tail;
  | [] ->
      acc
  end

let process_file_for_todos (config: Utils.config) (lines: string list) = 
  Printf.printf "Config: %s %s\n" config.filename config.filetype;
  let regex = 
    match config.filetype with
    | "py" ->
        (* Python: #, ##, ###, etc. *)
        Str.regexp_case_fold "#+ *TODO *:* *"
    | "c" ->
        (* C: //, ///, //// etc. *)
        Str.regexp_case_fold "//+ *TODO *:* *"
    | "go" ->
        (* Go: same as C for // comments *)
        Str.regexp_case_fold "//+ *TODO *:* *"
    | _ ->
        (* fallback: any comment starter that makes sense *)
        Str.regexp_case_fold "\\(#\\|//\\) *TODO *:* *"
  in
  let filtered = process_line regex [] lines in
    let rec print lines = 
      match lines with
      | head :: tail ->
          Printf.printf "%s\n" head;
          print tail
      | [] -> ()
    in print filtered;

