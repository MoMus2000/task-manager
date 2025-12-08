open Task
open Utils

let default_config: Utils.config = {
  filename = "";
  verbose  = false;
  recursive = false;
  recursive_path = "";
}

let print_usage() = 
  let usage_string = "
Usage: TODO Checker [options] <arguments>
Options:
  -h, --help        Show the help message and exit
  -v, --verbose     Show the git blame
  -f, --file-name   File-name to check
  -r, --recursive   Check the entire child file tree
  " in
  print_endline usage_string

let print_args() =
  Printf.printf "[";
  let rec print_arr arr = 
    match arr with
    | [h] -> Printf.printf "%s" h
    | h :: t -> 
        Printf.printf "%s, " h;
        print_arr t;
    | [] -> ();
  in print_arr (Array.to_list Sys.argv);
  Printf.printf "]\n"

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

let rec parse_args (config: config) (args: string list) =
  match args with
  | [] ->
      begin match config with 
      | {filename; recursive; recursive_path;} -> 
          if recursive && Sys.file_exists recursive_path then begin
            Task.print_table(config);
            let files = Task.walk (recursive_path) in
            let func filename =
              let result = read_file filename in
              Task.process_file_for_todos {config with filename=filename} result
            in
            List.iter func files
          end
          else if recursive then
            let files = Task.walk (Sys.getcwd ()) in
            let func filename =
              let result = read_file filename in
              Task.process_file_for_todos config result
            in
            List.iter func files
          else
          let result = read_file filename in
          Task.process_file_for_todos config result
      end
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
    | _ :: tail -> parse_args default_config tail
    | [] -> parse_args default_config []

let () =
  entry_point Sys.argv

