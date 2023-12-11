import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  -L|F7
  7S-7|
  L|7||
  -L-J|
  L|-JF
  """

let example2 = """
  7-F7-
  .FJ|7
  SJLL7
  |F--J
  LJ.LJ
  """

let inputFile = try String(contentsOfFile: "./src/10.input", encoding: .utf8)

struct Coordinate: Hashable {
  let x: Int
  let y: Int

  static func + (left: Coordinate, right: Coordinate) -> Coordinate {
    Coordinate(x: left.x + right.x, y: left.y + right.y)
  }
}

enum Dir {
  case north, south, east, west
}

func pos(_ dir: Dir) -> (Int, Int) {
  switch dir {
  case Dir.north: return (0, -1)
  case Dir.south: return (0, 1)
  case Dir.east: return (1, 0)
  case Dir.west: return (-1, 0)
  }
}

func takeStep(_ coords: Coordinate, _ dir: Dir) -> Coordinate {
  coords + Coordinate(x: pos(dir).0, y: pos(dir).1)
}

func updateDir(char: Character, dir: Dir) -> Dir? {
  switch (char, dir) {
  // | is a vertical pipe connecting north and south.
  case ("|", Dir.north): return Dir.north
  case ("|", Dir.south): return Dir.south
  // - is a horizontal pipe connecting east and west.
  case ("-", Dir.east): return Dir.east
  case ("-", Dir.west): return Dir.west
  // L is a 90-degree bend connecting north and east.
  case ("L", Dir.south): return Dir.east
  case ("L", Dir.west): return Dir.north
  // J is a 90-degree bend connecting north and west.
  case ("J", Dir.south): return Dir.west
  case ("J", Dir.east): return Dir.north
  // 7 is a 90-degree bend connecting south and west.
  case ("7", Dir.north): return Dir.west
  case ("7", Dir.east): return Dir.south
  // F is a 90-degree bend connecting south and east.
  case ("F", Dir.north): return Dir.east
  case ("F", Dir.west): return Dir.south
  case ("S", _): return dir
  default: return nil
  }
}

func findS(_ map: [Substring]) -> Coordinate {
  for (y, row) in map.enumerated() {
    for (x, val) in row.enumerated() {
      if val == "S" {
        return Coordinate(x: x, y: y)
      }
    }
  }
  assert(false)
}

// for a connected pipe, returns 2 Dirs
func dirOptions(_ coords: Coordinate, _ map: [Substring]) -> [Dir] {
  [Dir.north, Dir.east, Dir.south, Dir.west]
    .map({ (takeStep(coords, $0), $0) })
    .filter({ $0.0.x >= 0 && $0.0.y >= 0 })
    .filter({ updateDir(char: map[$0.0.y][$0.0.x], dir: $0.1) != nil })
    .map({ $0.1 })
}

func pipeAtCoords(_ coords: Coordinate, _ map: [Substring]) -> Character {
  let options = dirOptions(coords, map)
  assert(options.count == 2)
  switch (options[0], options[1]) {
  // | is a vertical pipe connecting north and south.
  case (Dir.north, Dir.south): return "|"
  // - is a horizontal pipe connecting east and west.
  case (Dir.east, Dir.west): return "-"
  // L is a 90-degree bend connecting north and east.
  case (Dir.north, Dir.east): return "L"
  // J is a 90-degree bend connecting north and west.
  case (Dir.north, Dir.west): return "J"
  // 7 is a 90-degree bend connecting south and west.
  case (Dir.south, Dir.west): return "7"
  // F is a 90-degree bend connecting south and east.
  case (Dir.east, Dir.south): return "F"
  default: assert(false)
  }
}

func orient(_ coords: Coordinate, _ map: [Substring]) -> Dir {
  dirOptions(coords, map).first!
}

func walkLoop(_ map: [Substring], _ c: Coordinate) -> [Coordinate] {
  var coords = c
  var dir = orient(coords, map)
  var result: [Coordinate] = []
  repeat {
    let nextCoords = takeStep(coords, dir)
    if let update = updateDir(char: map[nextCoords.y][nextCoords.x], dir: dir) {
      coords = nextCoords
      dir = update
      result.append(coords)
    } else {
      print("Unable to take next step", coords, dir)
      assert(false)
    }
  } while map[coords.y][coords.x] != "S"
  return result
}

func part1(_ input: String) -> Int {
  let map = input.split(separator: "\n")
  let coords = findS(map)
  let steps = walkLoop(map, coords)
  return steps.count / 2
}

assert(part1(example) == 4)
assert(part1(example2) == 8)
print(part1(inputFile))

let example3 = """
  ...........
  .S-------7.
  .|F-----7|.
  .||.....||.
  .||.....||.
  .|L-7.F-J|.
  .|..|.|..|.
  .L--J.L--J.
  ...........
  """

let example4 = """
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
  """

func allCoords(_ map: [Substring]) -> [Coordinate] {
  var result: [Coordinate] = []
  for (y, row) in map.enumerated() {
    for (x, _) in row.enumerated() {
      result.append(Coordinate(x: x, y: y))
    }
  }
  return result
}

func part2(_ input: String) -> Int {
  let map = input.split(separator: "\n")
  let coords = findS(map)
  let pipeAtS = pipeAtCoords(coords, map)

  let pipes = Set(walkLoop(map, coords))
  let west = Coordinate(x: -1, y: 0)
  let crossings: Set<Character> = ["|", "J", "L"]

  let contained = allCoords(map).filter({ !pipes.contains($0) }).filter({ (c: Coordinate) -> Bool in
    var focus = c + west
    var intersections = 0
    while focus.x >= 0 {
      let raw = map[focus.y][focus.x]
      let val = raw == "S" ? pipeAtS : raw
      if pipes.contains(focus) && crossings.contains(val) {
        intersections += 1
      }
      focus = focus + west
    }
    return (intersections % 2) == 1
  })

  return contained.count
}

assert(part2(example3) == 4)
assert(part2(example4) == 8)
print(part2(inputFile))
