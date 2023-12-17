import Foundation

let example = try String(contentsOfFile: "./src/16.example", encoding: .utf8).trimmingCharacters(
  in: .newlines)

let inputFile = try String(contentsOfFile: "./src/16.input", encoding: .utf8).trimmingCharacters(
  in: .newlines)

func parse(_ input: String) -> [[(Character, Bool)]] {
  input.split(separator: "\n").map({ line in line.map({ ($0, false) }) })
}

enum Direction {
  case right, left, up, down
}

struct Coordinate: Hashable {
  let x: Int
  let y: Int

  static func + (left: Coordinate, right: Coordinate) -> Coordinate {
    Coordinate(x: left.x + right.x, y: left.y + right.y)
  }
}

struct Beam: Hashable {
  let coord: Coordinate
  let direction: Direction

  func go(direction: Direction) -> Beam {
    return Beam(coord: self.coord + dirToCoord(direction), direction: direction)
  }

  func step() -> Beam {
    self.go(direction: self.direction)
  }
}

func dirToCoord(_ direction: Direction) -> Coordinate {
  switch direction {
  case .up: return Coordinate(x: 0, y: -1)
  case .down: return Coordinate(x: 0, y: 1)
  case .left: return Coordinate(x: -1, y: 0)
  case .right: return Coordinate(x: 1, y: 0)
  }
}

func move(_ beam: Beam, _ char: Character) -> [Beam] {
  switch (beam.direction, char) {
  case (_, "."):
    return [beam.step()]
  case (.right, "|"), (.left, "|"):
    return [beam.go(direction: .up), beam.go(direction: .down)]
  case (_, "|"):
    return [beam.step()]
  case (.down, "-"), (.up, "-"):
    return [beam.go(direction: .right), beam.go(direction: .left)]
  case (_, "-"):
    return [beam.step()]
  case (.right, "/"):
    return [beam.go(direction: .up)]
  case (.left, "/"):
    return [beam.go(direction: .down)]
  case (.up, "/"):
    return [beam.go(direction: .right)]
  case (.down, "/"):
    return [beam.go(direction: .left)]
  case (.up, "\\"):
    return [beam.go(direction: .left)]
  case (.down, "\\"):
    return [beam.go(direction: .right)]
  case (.left, "\\"):
    return [beam.go(direction: .up)]
  case (.right, "\\"):
    return [beam.go(direction: .down)]
  default:
    print("not handled", beam, char)
    assert(false)
  }
}

func toString(_ contraption: [[(Character, Bool)]]) -> String {
  contraption.map({
    $0.map({
      $0.1 ? "#" : "."
    }).joined()
  }).joined(separator: "\n")
}

func simulate(_ initContraption: [[(Character, Bool)]], start: Beam) -> Int {
  var contraption = initContraption
  let height = contraption.count
  let width = contraption[0].count
  var beams: [Beam] = [start]
  var seen: Set<Beam> = []

  while beams.count > 0 {
    let beam = beams.removeFirst()
    if !seen.contains(beam) {
      let char = contraption[beam.coord.y][beam.coord.x].0
      contraption[beam.coord.y][beam.coord.x] = (char, true)
      beams =
        beams
        + move(beam, char).filter({
          $0.coord.x >= 0 && $0.coord.x < width && $0.coord.y >= 0 && $0.coord.y < height
        })
      seen.insert(beam)
    }
  }

  return contraption.flatMap({ $0.map({ $0.1 }) }).filter({ $0 == true }).count
}

func part1(_ input: String) -> Int {
  simulate(
    parse(input),
    start: Beam(coord: Coordinate(x: 0, y: 0), direction: Direction.right))
}

assert(part1(example) == 46)
print(part1(inputFile))

func part2(_ input: String) -> Int {
  let contraption = parse(input)

  let maxX = contraption[0].count - 1
  let maxY = contraption.count - 1
  let xs = 0..<maxX
  let ys = 0..<maxY

  let startingPoints =
    xs.map({ Beam(coord: Coordinate(x: $0, y: 0), direction: .down) })
    + xs.map({ Beam(coord: Coordinate(x: $0, y: maxY), direction: .up) })
    + ys.map({ Beam(coord: Coordinate(x: 0, y: $0), direction: .right) })
    + ys.map({ Beam(coord: Coordinate(x: maxX, y: $0), direction: .left) })

  return startingPoints.map({ simulate(contraption, start: $0) }).max()!
}

assert(part2(example) == 51)
print(part2(inputFile))
