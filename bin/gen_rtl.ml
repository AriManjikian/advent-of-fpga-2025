open! Core
open! Hardcaml
open! Solution

module HW = Solution.Safe_dial

let generate_safe_dial_rtl () =
  let module C = Circuit.With_interface (HW.I) (HW.O) in
  let scope = Scope.create ~auto_label_hierarchical_ports:true () in
  let circuit = C.create_exn ~name:"safe_dial_top" (HW.create scope) in
  let rtl_circuits =
    Rtl.create ~database:(Scope.circuit_database scope) Verilog [ circuit ]
  in
  let rtl = Rtl.full_hierarchy rtl_circuits |> Rope.to_string in
  print_endline rtl
;;

let safe_dial_rtl_command =
  Command.basic
    ~summary:"Generate Verilog RTL for Safe_dial"
    [%map_open.Command
      let () = return () in
      fun () -> generate_safe_dial_rtl ()]
;;

let () =
  Command_unix.run
    (Command.group ~summary:"Hardware commands"
       [ "safe-dial", safe_dial_rtl_command ])
;;
