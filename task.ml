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
        let captured = Str.matched_group 2 head in
        let issue_regex = Str.regexp_case_fold "@ISSUE(#[0-9]+)" in
        let pos = 
          (try
            ignore(Str.search_forward issue_regex head 0);
            true
          with Not_found -> false
          ) in
          if pos then begin
            process_line regex ((captured, counter, true)::acc) (counter+1) tail
          end
          else
          process_line regex ((captured, counter, false)::acc) (counter+1) tail
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
          | name1:: _ :: t1:: _ :: _ ->
              Printf.printf "%-7s %-10s" name1 t1;
          | _ :: _ -> ()
          | [] -> ()
    )
  | Unix.WEXITED 1 -> ()
  | _ -> ()


let process_file_for_todos (config: Utils.config) (lines: string list) = 
  let regex = Str.regexp_case_fold
  "^\\(.*\\)\\(TODO* *: *.*\\)"
  in
  let filtered = process_line regex [] 1 lines in
    let rec print lines = 
      match lines with
      | (head, lineno, _) :: tail ->
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
    in print filtered;
    filtered

