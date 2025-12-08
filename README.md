# todo

A command-line tool that scans your codebase for `TODO` comments and annotates them with `git blame` information.

---

## Features

- Recursively scan directories for TODO comments  
- Supports multiple languages  
- Integrates with `git blame` to show author + timestamp  

---

## Usage

```sh
projects/ocaml [main] $ todo

Usage: TODO Checker [options] <arguments>
Options:
  -h, --help        Show the help message and exit
  -v, --verbose     Show git blame info
                    (Blame is only included when --verbose is enabled)
  -f, --file-name   File-name to check
  -r, --recursive   Check the entire child file tree

Output:
[Line][File][TODO] | [Blame][Line][File][TODO]
```

```sh
projects/ocaml [main] $ todo -r
   1. samples/sample_file.py         # TODO: basic todo
   2. samples/sample_file.py         ## TODO   with spaces
   3. samples/sample_file.py         ### TODO:: multiple colons
   4. samples/sample_file.py         #   TODO:::    spaced + colons
   5. samples/sample_file.py         #todo lower-case
   6. samples/sample_file.py         #   todo :: messy formatting
  12. samples/sample_file.py         ## TODO: check edge cases
  18. samples/sample_file.py         ### TODO: multiline example start
  24. samples/sample_file.py         ### TODO end multiline
  30. samples/sample_file.py         #### TODO   :
  31. samples/sample_file.py         #####   TODO::::
   4. samples/sample.c                 // TODO: Make it work.
   1. ocaml/README.md                # todo
```

```sh
projects/ocaml [main] $ todo -r -v
Mustafa 2025-12-07   1. samples/sample_file.py         # TODO: basic todo
Mustafa 2025-12-07   2. samples/sample_file.py         ## TODO   with spaces
Mustafa 2025-12-07   3. samples/sample_file.py         ### TODO:: multiple colons
Mustafa 2025-12-07   4. samples/sample_file.py         #   TODO:::    spaced + colons
Mustafa 2025-12-07   5. samples/sample_file.py         #todo lower-case
Mustafa 2025-12-07   6. samples/sample_file.py         #   todo :: messy formatting
Mustafa 2025-12-07  12. samples/sample_file.py         ## TODO: check edge cases
Mustafa 2025-12-07  18. samples/sample_file.py         ### TODO: multiline example start
Mustafa 2025-12-07  24. samples/sample_file.py         ### TODO end multiline
Mustafa 2025-12-07  30. samples/sample_file.py         #### TODO   :
Mustafa 2025-12-07  31. samples/sample_file.py         #####   TODO::::
Mustafa 2025-12-07   4. samples/sample.c                 // TODO: Make it work.
```

```sh
projects/ocaml [main] $ todo -f /Users/mmuhammad/Desktop/projects/ocaml/samples/sample.c
   4. samples/sample.c                 // TODO: Make it work.

projects/ocaml [main] $ todo -f /Users/mmuhammad/Desktop/projects/ocaml/samples/sample.c -v
Mustafa 2025-12-07   4. samples/sample.c                 // TODO: Make it work.
```

## Installation

### Precompiled Binaries

Download a pre-compiled bin for Mac or Linux from [here](https://github.com/MoMus2000/Todo/releases)

```sh
wget link_to_binary
sudo mv todo_linux_x86_64 /usr/local/bin/todo
sudo chmod +x todo
```

## Build From Source

### Note: Opam / Dune / Ocamlc Needed For Manual Build

```sh
sudo make install
```

## Remove

```sh
sudo make uninstall
```

