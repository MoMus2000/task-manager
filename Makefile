all:
	mkdir -p build
	ocamlfind ocamlc -package str -linkpkg utils.ml task.ml main.ml -o build/task-manager

run:
	./build/task-manager $(args)

