import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
  """

let inputFile = try String(contentsOfFile: "./src/13.input", encoding: .utf8)

struct Map {
  let rows: [String]
  let columns: [String]
}

func transpose(_ val: [String]) -> [String] {
  guard let firstRow = val.first else { return [] }
  let rowCount = val.count
  let columnCount = firstRow.count

  return (0..<columnCount).map { columnIndex in
    String((0..<rowCount).map { rowIndex in val[rowIndex][columnIndex] })
  }
}

func parse(_ input: String) -> [Map] {
  input.components(separatedBy: "\n\n").map({ comp in
    Map(
      rows: comp.split(separator: "\n").map({ String($0) }),
      columns: transpose(comp.split(separator: "\n").map({ String($0) })))
  })
}

func countDiff(_ a: String, _ b: String) -> Int {
  zip(a, b).filter({ $0.0 != $0.1 }).count
}

func isReflection(_ lines: [String], _ i: Int, _ j: Int, usedSmudge: Bool) -> Bool {
  if i < 0 {
    return usedSmudge
  }
  if j > lines.count - 1 {
    return usedSmudge
  }
  let differences = countDiff(lines[i], lines[j])
  switch (usedSmudge, differences) {
  case (_, 0): return isReflection(lines, i - 1, j + 1, usedSmudge: usedSmudge)
  case (false, 1): return isReflection(lines, i - 1, j + 1, usedSmudge: true)
  default: return false
  }
}

func findReflectionIndex(_ lines: [String], _ usedSmudge: Bool) -> Int? {
  for index in 0..<(lines.count - 1) {
    if isReflection(lines, index, index + 1, usedSmudge: usedSmudge) {
      return index + 1
    }
  }
  return nil
}

func score(_ map: Map, _ usedSmudge: Bool) -> Int {
  if let vertical = findReflectionIndex(map.columns, usedSmudge) {
    return vertical
  }
  if let horizontal = findReflectionIndex(map.rows, usedSmudge) {
    return 100 * horizontal
  }
  print("No reflection found!", map)
  assert(false)
}

func part1(_ input: String) -> Int {
  parse(input).map({ score($0, true) }).reduce(0, +)
}

assert(part1(example) == 405)
print(part1(inputFile))

func part2(_ input: String) -> Int {
  parse(input).map({ score($0, false) }).reduce(0, +)
}

assert(part2(example) == 400)
print(part2(inputFile))
