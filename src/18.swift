import Foundation

extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  R 6 (#70c710)
  D 5 (#0dc571)
  L 2 (#5713f0)
  D 2 (#d2c081)
  R 2 (#59c680)
  D 2 (#411b91)
  L 5 (#8ceee2)
  U 2 (#caa173)
  L 1 (#1b58a2)
  U 2 (#caa171)
  R 2 (#7807d2)
  U 3 (#a77fa3)
  L 2 (#015232)
  U 2 (#7a21e3)
  """

let inputFile = try String(contentsOfFile: "./src/18.input", encoding: .utf8).trimmingCharacters(
  in: .newlines)

struct Coordinate: Hashable {
  let x: Int
  let y: Int

  static func + (left: Coordinate, right: Coordinate) -> Coordinate {
    Coordinate(x: left.x + right.x, y: left.y + right.y)
  }

  static func * (left: Coordinate, right: Int) -> Coordinate {
    Coordinate(x: left.x * right, y: left.y * right)
  }
}

enum Direction {
  case right, left, up, down

  func toCoords() -> Coordinate {
    switch self {
    case .up: return Coordinate(x: 0, y: -1)
    case .down: return Coordinate(x: 0, y: 1)
    case .left: return Coordinate(x: -1, y: 0)
    case .right: return Coordinate(x: 1, y: 0)
    }
  }

  static func from(char: Character) -> Direction {
    switch char {
    case "U": return .up
    case "D": return .down
    case "L": return .left
    case "R": return .right
    default: assert(false)
    }
  }
  static func from(int: Int) -> Direction {
    [.right, .down, .left, .up][int]!
  }
}

struct Command {
  let direction: Direction
  let meters: Int
}

func parse(_ input: String) -> [Command] {
  input.split(separator: "\n").map({ line in
    let splits = line.split(separator: " ")
    return Command(direction: Direction.from(char: splits[0][0]), meters: Int(splits[1])!)
  })
}

func toString(_ land: [Coordinate: Bool]) -> String {
  let xs = land.keys.map({ $0.x })
  let ys = land.keys.map({ $0.y })

  var result: [Character] = []
  for y in ys.min()!...ys.max()! {
    for x in xs.min()!...xs.max()! {
      let value = land[Coordinate(x: x, y: y)] ?? false
      result.append(value ? "#" : ".")
    }
    result.append("\n")
  }
  return String(result)
}

func part1(_ input: String) -> Int {
  let commands = parse(input)
  var land: [Coordinate: Bool] = [:]
  var pos = Coordinate(x: 0, y: 0)
  land[pos] = true
  // walk path
  for command in commands {
    let move = command.direction.toCoords()
    for _ in 1...command.meters {
      pos = pos + move
      land[pos] = true
    }
  }

  // find point inside loop, could be more robust i guess
  let inside = Coordinate(x: 1, y: 1)
  land[inside] = true

  // flood fill
  //    get neighbors
  //    if not dug, dig and add to list
  var flood = [inside]
  while flood.count > 0 {
    let start = flood.removeFirst()

    for dir in [Direction.up, Direction.down, Direction.left, Direction.right] {
      let neighbor = start + dir.toCoords()
      if !land.keys.contains(neighbor) {
        land[neighbor] = true
        flood.append(neighbor)
      }
    }
  }
  // print(toString(land))
  return land.keys.count
}

assert(part1(example) == 62)
print(part1(inputFile))

func parse2(_ input: String) -> [Command] {
  input.split(separator: "\n").map({ line in
    let splits = line.split(separator: " ")
    var hex = splits[2].trimmingCharacters(in: CharacterSet(charactersIn: " (#)"))
    let last = hex.removeLast()
    return Command(direction: Direction.from(int: Int(String(last))!), meters: Int(hex, radix: 16)!)
  })
}

func shoelace(_ a: [Int], _ b: [Int]) -> Int {
  var result = 0
  for (i, aItem) in a.enumerated() {
    let bIndex = (i + 1) % a.count
    result += b[bIndex] * aItem
  }
  return result
}

func part2(_ input: String) -> Int {
  let commands = parse2(input)

  let start = Coordinate(x: 0, y: 0)
  var land: [Coordinate] = []
  var pos = start
  var perimeter = 0

  for command in commands {
    let move = command.direction.toCoords()
    pos = pos + (move * command.meters)
    land.append(pos)
    perimeter += command.meters
  }

  let xs = land.map({ c in c.x })
  let ys = land.map({ c in c.y })

  // i don't understand the + 1. Pick's theorem seems like it should be - 1
  return abs(shoelace(xs, ys) - shoelace(ys, xs)) / 2 + perimeter / 2 + 1
}

assert(part2(example) == 952_408_144_115)
print(part2(inputFile))
