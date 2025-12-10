let issue_prompt_string = "

ATTENTION:
The following issues were found:

Usage:
  Enter 'y' or 'yes' to confirm; any other input will skip.

Issues marked as CREATED upon confirmation.

"

let prepare_message comment issue_number line_number =
  ignore(Printf.sprintf "

  Title: ISSUE # %d

  LineNo : %d
  Message: %s

  " issue_number line_number comment);
  ()

let push_issues_to_git_tracker (create_issues: bool) issues = 
  if create_issues then
  Printf.printf "%s" issue_prompt_string;
  let rec print_issue issues = 
    match issues with
    | (comment, lineno, true) :: tail ->
        if create_issues then begin
        Printf.printf "\n%4d. %s\n" lineno comment;
        Printf.printf "\nConfirm [y/yes to create, else skip]: ";
        let line = read_line() in
          if String.equal line "y" || String.equal line "yes" then begin
            Printf.printf "Creating Issue\n";
            let title = Printf.sprintf "ISSUE: %d" 67  in
            let message = Printf.sprintf 
            "LineNo : %d\\nMessage: %s\\n" lineno comment in
            Github.push_issue_message_to_github 
            title message "https://api.github.com/repos/momus2000/Todo/issues"
          end
            ;
            print_issue tail
          end
    | (_, _, false) :: tail -> 
        print_issue tail;
    | [] -> ()
  in
  print_issue issues;
  ()

