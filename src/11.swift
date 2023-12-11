import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
  """

let inputFile = try String(contentsOfFile: "./src/11.input", encoding: .utf8)

struct Coordinate: Hashable {
  let x: Int
  let y: Int

  static func + (left: Coordinate, right: Coordinate) -> Coordinate {
    Coordinate(x: left.x + right.x, y: left.y + right.y)
  }
}

func manhattan(_ a: Coordinate, _ b: Coordinate) -> Int {
  abs(a.x - b.x) + abs(a.y - b.y)
}

struct Image {
  var rows: [String]
  var galaxies: [Coordinate]
  var emptyRows: [Int]
  var emptyColumns: [Int]
}

func parse(_ input: String) -> Image {
  let rows = input.split(separator: "\n").map({ String($0) })
  let emptyRows = rows.enumerated().filter({ $0.1.allSatisfy({ $0 == "." }) }).map({ $0.0 })

  var emptyColumns: [Int] = []
  for (index, _) in rows[0].enumerated() {
    if rows.map({ $0[index] }).allSatisfy({ $0 == "." }) {
      emptyColumns.append(index)
    }
  }

  var galaxies: [Coordinate] = []
  for (y, row) in rows.enumerated() {
    for (x, val) in row.enumerated() {
      if val == "#" {
        galaxies.append(Coordinate(x: x, y: y))
      }
    }
  }

  return Image(rows: rows, galaxies: galaxies, emptyRows: emptyRows, emptyColumns: emptyColumns)
}

func pairs<T>(_ list: [T]) -> [(T, T)] {
  var array: [(T, T)] = []
  for (i, a) in list.enumerated() {
    for (j, b) in list.enumerated() {
      if i < j {
        array.append((a, b))
      }
    }
  }
  return array
}

func distance(image: Image, expansion: Int, _ a: Coordinate, _ b: Coordinate) -> Int {
  let xRange = a.x <= b.x ? a.x...b.x : b.x...a.x
  let yRange = a.y <= b.y ? a.y...b.y : b.y...a.y

  let growth =
    image.emptyColumns.filter({ xRange.contains($0) }).count
    + image.emptyRows.filter({ yRange.contains($0) }).count

  return manhattan(a, b) - growth + (expansion * growth)
}

func answer(_ input: String, expansion: Int) -> Int {
  let image = parse(input)
  return pairs(image.galaxies).map({ distance(image: image, expansion: expansion, $0.0, $0.1) })
    .reduce(0) { $0 + $1 }
}

func part1(_ input: String) -> Int {
  answer(input, expansion: 2)
}

assert(part1(example) == 374)
print(part1(inputFile))

func part2(_ input: String) -> Int {
  answer(input, expansion: 1_000_000)
}

assert(answer(example, expansion: 10) == 1030)
assert(answer(example, expansion: 100) == 8410)
print(part2(inputFile))
