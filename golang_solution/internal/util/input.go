package util

import (
    "os"
    "strings"
)

func ReadInput(path string) string {
    data, err := os.ReadFile(path)
    if err != nil {
        panic(err)
    }
    return strings.TrimRight(string(data), "\n")
}

func ReadLines(path string) []string {
    return strings.Split(ReadInput(path), "\n")
}
