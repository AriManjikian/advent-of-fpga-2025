.PHONY: run-all

run-all:
	@cd golang_solution && go run solver.go
	@echo "\n"
	@dune exec solution/hw_main.exe

gen-rtl:
	@mkdir -p rtl/
	@dune exec bin/gen_rtl.exe -- safe-dial > rtl/gen_rtl.v
