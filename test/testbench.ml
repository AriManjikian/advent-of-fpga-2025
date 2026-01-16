open! Core
open! Hardcaml
open! Hardcaml_test_harness
open! Hardcaml_waveterm

module Safe_dial = Solution.Safe_dial
module Harness = Cyclesim_harness.Make (Safe_dial.I) (Safe_dial.O)

let sample_moves = [ ('L', 3); ('R', 2); ('L', 1); ('L', 5) ]

let simple_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  inputs.rst := Bits.vdd;
  inputs.step := Bits.gnd;
  inputs.dir := Bits.gnd;
  cycle ();
  inputs.rst := Bits.gnd;
  cycle ();
  
  let step dir =
    inputs.dir := if Char.(dir = 'L') then Bits.gnd else Bits.vdd;
    inputs.step := Bits.vdd;
    cycle ();
    inputs.step := Bits.gnd;
    cycle ()
  in
  
  List.iter sample_moves ~f:(fun (dir, amount) ->
      for _ = 1 to amount do step dir done
    );
  
  let final_pos = Bits.to_int_trunc !(outputs.pos) in
  let zero_count = Bits.to_int_trunc !(outputs.zero_count) in
  print_s [%message "Result" (final_pos : int) (zero_count : int)];
  
  cycle ~n:2 ()
;;

let waves_config = Waves_config.no_waves

let%expect_test "Safe_dial testbench" =
  Harness.run_advanced
    ~waves_config
    ~create:Safe_dial.create
    simple_testbench;
  [%expect {| (Result (final_pos 43) (zero_count 0)) |}]
;;

let%expect_test "Safe_dial with waveforms" =
  Harness.run_advanced
    ~waves_config
    ~create:Safe_dial.create
    ~trace:`All_named
    ~print_waves_after_test:(fun waves ->
      Waveform.print
        ~signals_width:30
        ~display_width:130
        ~wave_width:1
        waves)
    simple_testbench;
  [%expect {|
    (Result (final_pos 43) (zero_count 0))
    ┌Signals─────────────────────┐┌Waves─────────────────────────────────────────────────────────────────────────────────────────────┐
    │clk                         ││┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─│
    │                            ││  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ │
    │rst                         ││                                                                                                  │
    │                            ││──────────────────────────────────────────────────────────────────────────────────────────────────│
    │dir                         ││                                ┌───────────────┐                                                 │
    │                            ││────────────────────────────────┘               └─────────────────────────────────────────────────│
    │step                        ││        ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐     │
    │                            ││────────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └─────│
    │                            ││────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬─────│
    │pos                         ││ 00 │32     │31     │30     │2F     │30     │31     │30     │2F     │2E     │2D     │2C     │2B   │
    │                            ││────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴─────│
    │                            ││──────────────────────────────────────────────────────────────────────────────────────────────────│
    │zero_count                  ││ 00000000                                                                                         │
    │                            ││──────────────────────────────────────────────────────────────────────────────────────────────────│
    │zero_pulse                  ││                                                                                                  │
    │                            ││──────────────────────────────────────────────────────────────────────────────────────────────────│
    └────────────────────────────┘└──────────────────────────────────────────────────────────────────────────────────────────────────┘
    |}]
;;
