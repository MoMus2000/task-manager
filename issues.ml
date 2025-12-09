let issue_prompt_string = "

ATTENTION:
The following issues were found:

Usage:
  Enter 'y' or 'yes' to confirm; any other input will skip.

Issues marked as CREATED upon confirmation.

"
let push_issues_to_git_tracker issues = 
  Printf.printf "%s" issue_prompt_string;
  let rec print_issue issues = 
    match issues with
    | (comment, lineno, true) :: tail ->
        Printf.printf "%4d. %s\n" lineno comment;
        Printf.printf "\nConfirm [y/yes to create, else skip]: ";
        let line = read_line() in
        Printf.printf "Input: %s\n" line;
        print_issue tail
    | (comment, _, false) :: tail -> 
        print_issue tail;
    | [] -> ()
  in
  print_issue issues;
  ()

