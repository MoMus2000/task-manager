open Task
open Utils

let default_config: Utils.config = {
  filename = "";
  version  = "v0.0.0";
  recursive = false;
  recursive_path = "";
}

let print_usage() = 
  let usage_string = "
Usage: TODO Checker [options] <arguments>
Options:
  -h, --help        Show the help message and exit
  -v, --version     Show program version
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
          if recursive && Sys.file_exists recursive_path then
            let files = Task.walk (recursive_path) in
            let func filename =
              let result = read_file filename in
              Task.process_file_for_todos config result
            in
            List.iter func files
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
  | "-r"::path::rest | "--recursive"::path::rest ->
      parse_args {
        config with 
        recursive=true;
        recursive_path = path;
      } rest;
  | "-r":: rest | "--recursive"::rest ->
      parse_args {config with recursive=true} rest;
  | "-f":: file_name:: rest | "--filename"::file_name::rest ->
      parse_args {config with filename=file_name} rest;
  | "-f" :: _ | "--filename"::_ ->
      Printf.printf "Missing Filename\n";
      print_usage();
      exit(1);
  | "-v":: _ | "--version" :: _ ->
      Printf.printf "%s\n" config.version;
      exit(0);
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

