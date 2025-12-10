let default_config: Utils.config = {
  filename = "";
  verbose  = false;
  recursive = false;
  recursive_path = "";
  create_issues = false;
}

let print_usage() = 
  let usage_string = "
Usage: TODO Checker [options] <arguments>
Options:
  -h, --help          Show the help message and exit
  -v, --verbose       Show git blame info
                      (Blame is only included when --verbose is enabled)
  -f, --file-name     File-name to check
  -r, --recursive     Check the entire child file tree
  -i, --create-issue  Create Issues After Search

Output:
[Line][File][TODO] | [Blame][Line][File][TODO]
" in
  print_endline usage_string

let read_file file_name : string list = 
  let chan = open_in file_name in
    let rec loop acc =
      try
        let line = input_line chan in
        loop (line :: acc)
      with End_of_file ->
        close_in chan;
        List.rev acc
    in
    loop []

let rec parse_args (config: Utils.config) (args: string list) =
  match args with
  | [] ->
      begin match config with 
      | {filename; recursive; create_issues; _ } -> 
          if (String.equal filename "") && recursive then begin
            let files = Task.walk (".") in
            let func fname =
              let result = read_file fname in
              Task.process_file_for_todos {config with filename=fname} result
            in
            Issues.push_issues_to_git_tracker create_issues (List.concat_map func files);
          end
          else if filename <> "" && not recursive then begin
            let result = read_file filename in
            let output = Task.process_file_for_todos config result in 
              match output with
              | (a , b , c) :: _ ->
                  Printf.printf "%s %d %b" a b c;
                  ()
              | _ -> ()
          end
          else begin
            print_usage();
            exit(1)
          end
      end
  | "-i"::rest | "--create-issue"::rest->
      (match Sys.getenv_opt "GITHUB_TOKEN" with
      | Some token when token <> "" ->
        parse_args {
          config with
          create_issues = true
        } rest;
      | _ ->
          exit(1)
      )
  | "-r"::rest | "--recursive"::rest->
      parse_args {
        config with 
        recursive=true;
        recursive_path = Sys.getcwd();
      } rest;
  | "-f":: file_name:: rest | "--filename"::file_name::rest ->
      parse_args {config with filename=file_name} rest;
  | "-f" :: _ | "--filename"::_ ->
      Printf.printf "Missing Filename\n";
      print_usage();
      exit(1);
  | "-v":: rest | "--verbose" :: rest ->
      parse_args {config with verbose=true} rest;
  | "-h" :: _ | "--help" :: _ ->
      print_usage();
      exit(1);
  | unknown::_ -> 
      Printf.printf "Unknown Argument: %s\n" unknown;
      print_usage();
      exit(1)

let entry_point (args : string array) =
  match Array.to_list args with
    | _ :: [] -> 
        print_usage();
        exit(1)
    | _ :: tail -> parse_args default_config tail
    | [] ->
        exit(1)

let () =
  entry_point Sys.argv

