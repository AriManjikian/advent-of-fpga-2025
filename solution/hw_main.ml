open Hardcaml

module HW = Solution.Safe_dial
module Sim = Cyclesim.With_interface (HW.I) (HW.O)

open! HW.I
open! HW.O

let dir_of_char = function
  | 'L' | 'l' -> false
  | 'R' | 'r' -> true
  | c -> invalid_arg (Printf.sprintf "unknown direction %c" c)

let create_sim () =
  let sim = Sim.create (HW.create (Scope.create ())) in
  let inputs : Bits.t ref HW.I.t = Cyclesim.inputs sim in
  inputs.rst := Bits.vdd;
  inputs.step := Bits.gnd;
  inputs.dir := Bits.gnd;
  Cyclesim.cycle sim;
  inputs.rst := Bits.gnd;
  sim, inputs

let apply_move sim inputs (dir_char, amount) =
  let dir = dir_of_char dir_char in
  for _ = 1 to amount do
    inputs.step := Bits.vdd;
    inputs.dir := if dir then Bits.vdd else Bits.gnd;
    Cyclesim.cycle sim;
    inputs.step := Bits.gnd
  done

let part1 moves =
  let sim, inputs = create_sim () in
  let moves_ending_at_zero = ref 0 in
  List.iter
    (fun move ->
      apply_move sim inputs move;
      let o = Cyclesim.outputs ~clock_edge:After sim in
      let pos = Bits.to_int_trunc !(o.pos) in
      if pos = 0 then incr moves_ending_at_zero)
    moves;
  !moves_ending_at_zero

let part2 moves =
  let sim, inputs = create_sim () in
  List.iter (apply_move sim inputs) moves;
  let o = Cyclesim.outputs ~clock_edge:After sim in
  Bits.to_int_trunc !(o.zero_count)

let moves_from_file filename =
  Solution.Solver.read_moves filename

let () =
  Printf.printf "~~~~ Hardware Results ~~~~\n";
  let test_lines = moves_from_file "sample.txt" in
  Printf.printf "=== Tests ===\n";
  Printf.printf "Test Part1: %d\n" (part1 test_lines);
  Printf.printf "Test Part2: %d\n\n" (part2 test_lines);

  let sol_lines = moves_from_file "input.txt" in
  Printf.printf "=== Solution ===\n";
  Printf.printf "Part1: %d\n" (part1 sol_lines);
  Printf.printf "Part2: %d\n" (part2 sol_lines)
