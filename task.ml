open Unix
open Utils
open Str

let rec walk dir : string list =
  let entries = Array.to_list (Sys.readdir dir) in
  let rec loop acc entries =
    match entries with
    | [] -> acc
    | name :: rest ->
        let path = Filename.concat dir name in
        let acc =
          if Sys.is_directory path then
            if name <> "." && name <> ".." then
              walk path @ acc  (* recurse and append *)
            else acc
          else
            path :: acc       (* add file to acc *)
        in
        loop acc rest
  in
  loop [] entries

let rec process_line (regex) (acc) (counter: int) (lines: string list) =
  begin match lines with
  | head :: tail -> 
      if Str.string_match regex head 0 then
          process_line regex ((head, counter)::acc) (counter+1) tail
      else
        process_line regex acc (counter+1) tail;
  | [] -> List.rev acc
  end


let parse_git_blame cmd =
  let ic  = Unix.open_process_in cmd in
  let buf = Buffer.create 128 in
  ( try
    while true do
      Buffer.add_string buf (input_line ic);
      Buffer.add_char buf '\n'
    done
  with End_of_file -> ()
  );
  let status = Unix.close_process_in ic in
  match status with
  | Unix.WEXITED 0 ->
    let contents = Buffer.contents buf in
    (match String.split_on_char '(' contents with
    | [] -> ()
    | _ :: [] -> ()
    | _ :: rest :: _ -> 
        let meat = String.trim rest in
          match String.split_on_char ' ' meat with
          | name1:: _ :: t1:: t2:: rest ->
              Printf.printf "%-7s %-10s" name1 t1;
          | unknown :: _ -> ()
          | [] -> ()
    )
  | Unix.WEXITED 1 -> ()
  | _ -> ()


let print_table config =
  if config.verbose then begin
    Printf.printf "%-19s %4s  %-20s %s\n" "Blame" "Line" "File" "TODO";
    Printf.printf "%-8s %-10s %4s %-20s %s\n" "--------" "----------" "----" "--------------------" "-------------------------------";
  end
  else begin
    Printf.printf "Line  File                         TODO\n";
    Printf.printf "----  --------------------         -------------------------------\n"
  end

let process_file_for_todos (config: Utils.config) (lines: string list) = 
  let regex = Str.regexp_case_fold
  "[ \t]*[^ \t\\w]*\\(/\\*\\*\\*\\|/\\*\\*\\|\\*/\\*\\*\\|\\*\\|//\\|#\\|'\\|--\\|%\\|;\\|\\\"\\\"\\\"\\|'''\\) *TODO[\\-()]? *:* *"
  in
  let filtered = process_line regex [] 1 lines in
    let rec print lines = 
      match lines with
      | (head, lineno) :: tail ->
          if config.verbose then
            parse_git_blame (Printf.sprintf "git blame -L %d,%d %s 2>&1" 
              lineno lineno config.filename);
          let trimmed_filename = 
            match List.rev (String.split_on_char '/' config.filename) with
            | last :: second_last :: _ -> second_last ^ "/" ^ last
            | last :: _ -> last
            | [] -> exit 1
          in
          Printf.printf "%4d. %-30s %s\n" lineno trimmed_filename head;
          print tail
      | [] -> ()
  in print filtered

