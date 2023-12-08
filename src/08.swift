import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
  """

let example2 = """
  LLR

  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
  """

let inputFile = try String(contentsOfFile: "./src/08.input", encoding: .utf8)

struct Puzzle {
  let moves: String
  let graph: [String: (String, String)]
}

func clean(_ str: Substring) -> String {
  String(str).trimmingCharacters(in: CharacterSet(charactersIn: " "))
}

func parse(_ input: String) -> Puzzle {
  let splits = input.components(separatedBy: "\n\n")
  let graph = splits[1].split(separator: "\n").reduce(into: [:]) { (accum: inout [String: (String, String)], str: Substring) in
    let uh = str.split(separator: "=")
    let withoutParens = uh[1].trimmingCharacters(in: CharacterSet(charactersIn: "() "))
    let pair = withoutParens.split(separator: ",")
    accum[clean(uh[0])] = (clean(pair[0]), clean(pair[1]))
  }
  return Puzzle(moves: splits[0], graph: graph)
}

func simulate(_ puzzle: Puzzle, start: String, goal: (String) -> Bool) -> Int {
  var index = 0
  var status = start
  var count = 0
  while true {
    let step = puzzle.moves[index]
    if step == "L" {
      status = puzzle.graph[status]!.0
    } else {
      status = puzzle.graph[status]!.1
    }
    count += 1
    if goal(status) {
      return count
    }
    index = (index + 1) % puzzle.moves.count
  }
}

func part1(_ input: String) -> Int {
  simulate(parse(input), start: "AAA", goal: { $0 == "ZZZ"})
}

assert(part1(example) == 2)
assert(part1(example2) == 6)
print(part1(inputFile))

let example3 = """
  LR

  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
  """

func gcd(_ a: Int, _ b: Int) -> Int {
  b == 0 ? a : gcd(b, a % b)
}

func lcm(_ a: Int, _ b: Int) -> Int {
  (a * b) / gcd(a, b)
}

func part2(_ input: String) -> Int {
  let puzzle = parse(input)
  let starts = puzzle.graph.keys.filter({ $0.hasSuffix("A" )})
  let steps = starts.map({ simulate(puzzle, start: $0, goal: { $0.hasSuffix("Z") }) })
  return steps.reduce(1, lcm)
}

assert(part2(example3) == 6)
print(part2(inputFile))
