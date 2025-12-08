all:
	mkdir -p build
	ocamlfind ocamlc -package str,unix -c utils.ml -o build/utils.cmo
	ocamlfind ocamlc -package str,unix -I build -c task.ml -o build/task.cmo
	ocamlfind ocamlc -package str,unix -I build -c main.ml -o build/main.cmo
	ocamlfind ocamlc -package str,unix -I build -linkpkg build/utils.cmo build/task.cmo build/main.cmo -o build/task-manager

run:
	./build/task-manager $(args)

clean:
	rm -rf build/*

