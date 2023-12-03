import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

let inputFile = try String(contentsOfFile: "./src/03.input", encoding: .utf8)

struct Coordinate: Hashable {
  var x: Int
  var y: Int
}

func isSymbol(char: Character) -> Bool {
  return !char.isNumber && char != "."
}

func surroundingCoords(coords: Coordinate) -> [Coordinate] {
  return [
    Coordinate(x: coords.x - 1, y: coords.y + 1), Coordinate(x: coords.x - 1, y: coords.y),
    Coordinate(x: coords.x - 1, y: coords.y - 1),
    Coordinate(x: coords.x, y: coords.y + 1), Coordinate(x: coords.x, y: coords.y - 1),
    Coordinate(x: coords.x + 1, y: coords.y + 1), Coordinate(x: coords.x + 1, y: coords.y),
    Coordinate(x: coords.x + 1, y: coords.y - 1),
  ]
}

// size isn't really a coordinate...
func hasAdjacentSymbol(lines: [Substring], coords: Coordinate, size: Coordinate) -> Bool {
  return surroundingCoords(coords: coords)
    .filter({ (c: Coordinate) -> Bool in
      return c.x >= 0 && c.y >= 0 && c.x < size.x && c.y < size.y
    })
    .contains(where: { isSymbol(char: lines[$0.y][$0.x]) })
}

func part1(input: String) -> Int {
  var nums: [Int] = []
  let lines = input.split(separator: "\n")

  let height = lines.count
  let width = lines[0].count

  var inProgress: [Character] = []
  var isPartNumber = false
  for y in 0..<lines.count {
    for x in 0..<lines[y].count {
      let char = lines[y][x]
      if char.isNumber {
        inProgress.append(char)
        isPartNumber =
          isPartNumber
          || hasAdjacentSymbol(
            lines: lines, coords: Coordinate(x: x, y: y), size: Coordinate(x: width, y: height))
      } else if inProgress.count > 0 {
        if isPartNumber {
          nums.append(Int(String(inProgress))!)
        }
        inProgress = []
        isPartNumber = false
      }
    }
  }

  return nums.reduce(0, { $0 + $1 })
}

assert(part1(input: example) == 4361)
print(part1(input: inputFile))

func getAdjacentGears(lines: [Substring], coords: Coordinate, size: Coordinate) -> [Coordinate] {
  return surroundingCoords(coords: coords)
    .filter({ (c: Coordinate) -> Bool in
      return c.x >= 0 && c.y >= 0 && c.x < size.x && c.y < size.y
    })
    .filter({ lines[$0.y][$0.x] == "*" })
}

func part2(input: String) -> Int {
  var gearToNumbers: [Coordinate: [Int]] = [:]
  let lines = input.split(separator: "\n")

  let height = lines.count
  let width = lines[0].count

  var inProgress: [Character] = []
  var adjacentGears: Set<Coordinate> = []
  for y in 0..<lines.count {
    for x in 0..<lines[y].count {
      let char = lines[y][x]
      if char.isNumber {
        inProgress.append(char)
        getAdjacentGears(
          lines: lines, coords: Coordinate(x: x, y: y), size: Coordinate(x: width, y: height)
        )
        .forEach({ adjacentGears.insert($0) })
      } else if inProgress.count > 0 {
        if !adjacentGears.isEmpty {
          let num = Int(String(inProgress))!
          adjacentGears.forEach({ (coord: Coordinate) in
            if var existing = gearToNumbers[coord] {
              existing.append(num)
              gearToNumbers.updateValue(existing, forKey: coord)
            } else {
              gearToNumbers.updateValue([num], forKey: coord)
            }
          })
        }
        inProgress = []
        adjacentGears = []
      }
    }
  }

  return gearToNumbers.values.map({ $0.count == 2 ? $0[0] * $0[1] : 0 }).reduce(0, { $0 + $1 })
}

assert(part2(input: example) == 467835)
print(part2(input: inputFile))
