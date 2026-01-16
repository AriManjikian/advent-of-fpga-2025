package main

import (
    "advent_of_code/internal/util"
    "fmt"
    "os"
    "strconv"
)

func Part1(lines []string) int {
    pos := 50
    pass := 0
    for _, line := range lines {
        move := line[0]
        count, err := strconv.Atoi(line[1:])
        if err != nil {
            panic(err)
        }
        count = count % 100
        if move == 'L' {
            pos = (pos - count) % 100
            if pos < 0 {
                pos += 100
            }
        } else if move == 'R' {
            pos = (pos + count) % 100
            if pos > 99 {
                pos -= 100
            }
        }
        if pos == 0 {
            pass++
        }
    }
    return pass
}

func Part2(lines []string) int {
    pos := 50
    pass := 0
    for _, line := range lines {
        move := line[0]
        count, err := strconv.Atoi(line[1:])
        if err != nil {
            panic(err)
        }
        step := count % 100
        var rotations int
        if move == 'L' {
            dist := (100 - pos) % 100
            rotations = (dist + count) / 100
            pos = (pos + 100 - step) % 100
        } else if move == 'R' {
            rotations = (pos + count) / 100
            pos = (pos + step) % 100
        }
        pass += rotations
    }
    return pass
}

func runTest(filename string) {
    if _, err := os.Stat(filename); os.IsNotExist(err) {
        fmt.Printf("Test file %s not found, skipping tests\n\n", filename)
        return
    }

    lines := util.ReadLines(filename)
    fmt.Println("=== Tests ===")
    fmt.Printf("Test Part1: %d\n", Part1(lines))
    fmt.Printf("Test Part2: %d\n", Part2(lines))
    fmt.Println()
}

func main() {
    fmt.Println("~~~~ Golang Results ~~~~")
    runTest("../sample.txt")

    lines := util.ReadLines("../input.txt")
    fmt.Println("=== Solution ===")
    fmt.Println("Part1:", Part1(lines))
    fmt.Println("Part2:", Part2(lines))
}
