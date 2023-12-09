import Foundation

let example = """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

let inputFile = try String(contentsOfFile: "./src/09.input", encoding: .utf8)

func parse(_ input: String) -> [[Int]] {
  input.split(separator: "\n").map({ $0.split(separator: " ").map({ Int($0)! }) })
}

func diffSequence(_ seq: [Int]) -> [Int] {
  var result: [Int] = []
  for (i, val) in seq.enumerated() {
    if i == 0 {
      continue
    }
    result.append(val - seq[i - 1])
  }
  return result
}

func nextInSequence(_ seq: [Int]) -> Int {
  seq.allSatisfy({ $0 == 0 }) ? 0 : (seq.last! + nextInSequence(diffSequence(seq)))
}

func part1(_ input: String) -> Int {
  parse(input).map(nextInSequence).reduce(0) { $0 + $1 }
}

assert(part1(example) == 114)
print(part1(inputFile))

func prevInSequence(_ seq: [Int]) -> Int {
  seq.allSatisfy({ $0 == 0 }) ? 0 : (seq.first! - prevInSequence(diffSequence(seq)))
}

func part2(_ input: String) -> Int {
  parse(input).map(prevInSequence).reduce(0) { $0 + $1 }
}

assert(part2(example) == 2)
print(part2(inputFile))
