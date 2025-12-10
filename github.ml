let push_issue_message_to_github title body repo_url =
  let curl = Curl.init () in
  let buffer = Buffer.create 16384 in

  let write_buffer s =
    Buffer.add_string buffer s;
    String.length s
  in

  Curl.set_writefunction curl write_buffer;
  Curl.set_url curl repo_url;
  Curl.set_post curl true;

  let title = title in
  let json_body = 
    Printf.sprintf "{\"title\": \"%s\", \"body\": \"%s\"}" title body
  in
  Printf.printf "%s" json_body;
  Curl.set_postfields curl json_body;

  let headers = [
    "Content-Type: application/json";
    "User-Agent: OcamlApp";
    "Authorization: Bearer " ^ Sys.getenv "GITHUB_TOKEN"
  ] in 

  Curl.set_httpheader curl headers;

  Curl.perform curl;

  let response_code = Curl.get_responsecode curl
    in
    match response_code with
    | 200 -> Printf.printf "200 Reponse: %s" (Buffer.contents buffer)
    | _ -> Printf.printf "Something went wrong ! %s" (Buffer.contents buffer);

  ()

