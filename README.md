# Advent of FPGA 2025

## Background

I decided to take on the [Advent of FPGA challenge](https://blog.janestreet.com/advent-of-fpga-challenge-2025/) by Jane Street and implement a solution to one of the [Advent of Code](https://adventofcode.com/2025) problems using Hardcaml. Initially, I faced some challenges since I had no functional programming background and was new to both OCaml and Hardcaml. After reading through OCaml code examples and finding inspiration from existing Hardcaml projects, I used Jane Street's [Hardcaml template](https://github.com/janestreet/hardcaml_template_project/tree/with-extensions) to set up my project structure.

This repository includes both the Hardcaml hardware implementation and a Go implementation that serves as a golden model for verification.

## Problem Overview - AOC2025 Day 1

The problem involves simulating a circular dial with 100 positions (0-99). Starting at position 50, the dial can be rotated left ('L') or right ('R') by a given amount. The goal is to count how many times the dial passes through or lands on position 0.

### Part 1
In Part 1, rotations happen instantaneously. A rotation wraps around the dial, and we check if the final position is 0.

### Part 2
In Part 2, rotations happen one click at a time. We must count every time the dial passes through position 0 during the rotation, not just the final position.

## Solution Approach

The OCaml solution implements both parts:

**Part 1 - Instantaneous Rotation:**
```ocaml
let rotate pos dir amount =
  match dir with
  | 'L' -> if pos - amount <  0 then pos + 100 - amount else pos - amount
  | 'R' -> if pos + amount > 99 then pos - 100 + amount else pos + amount
  | _ -> pos
```
This function calculates the final position after a rotation, handling wrapping around the 100-position dial.

**Part 2 - Click-by-Click Rotation:**
```ocaml
let clicking_rotate pos dir amount =
  let step (pos, count) _ =
    let pos' =
      match dir with
      | 'L' -> if pos =  0 then 99 else pos - 1
      | 'R' -> if pos = 99 then  0 else pos + 1
      | _ -> pos
    in
    let count' = if pos' = 0 then count + 1 else count in
    (pos', count')
  in
  let final_pos, clicks =
    Seq.(ints 0 |> take amount |> fold_left step (pos, 0))
  in
  (final_pos, clicks)
```
This function simulates each individual click, counting every time position 0 is encountered during the rotation.

## Project Structure

```
.
├── Makefile
├── bin
│   ├── dune
│   ├── gen_rtl.exe
│   └── gen_rtl.ml
├── dune-project
├── golang_solution
│   └── solver.go
├── input.txt
├── sample.txt
├── rtl
│   └── gen_rtl.v
├── solution
│   ├── dune
│   ├── hw_main.ml
│   ├── safe_dial.ml
│   └── solver.ml
└── test
    ├── dune
    └── testbench.ml
```

## Getting Started

### Installing OCaml and opam

First, install opam (OCaml's package manager) following the [official installation guide](https://opam.ocaml.org/doc/Install.html).

After installing opam, initialize it:
```bash
opam init
eval $(opam env)
```

### Installing Hardcaml

First, install the OxCaml compiler switch:
```bash
opam switch create 5.2.0+ox
opam switch 5.2.0+ox
eval $(opam env)
```

Then, install the required dependencies:
```bash
opam install -y hardcaml hardcaml_test_harness hardcaml_waveterm ppx_hardcaml
opam install -y core core_unix ppx_jane rope re dune
```

## Building and Running

### Build the Project

```bash
dune build
```

### Run Both Solutions

Compare the Go golden model with the Hardcaml implementation:
```bash
make run-all
```

This will run both the Go reference implementation and the Hardcaml simulation.

### Generate RTL

Generate Verilog RTL from the Hardcaml design:
```bash
make gen-rtl
```

The generated Verilog will be placed in `rtl/gen_rtl.v`.

### Run Individual Solutions

Run only the Hardcaml simulation:
```bash
dune exec solution/hw_main.exe
```

Run only the Go golden model:
```bash
cd golang_solution && go run solver.go
```
