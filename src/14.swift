import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

infix operator >>> : MultiplicationPrecedence
func >>> <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) -> C) -> (A) -> C {
  return { rhs(lhs($0)) }
}

let example = """
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
  """

let inputFile = try String(contentsOfFile: "./src/14.input", encoding: .utf8)

enum Rock {
  case round, cube, empty
}

// to the right
func rotate<T>(_ val: [[T]]) -> [[T]] {
  guard let firstRow = val.first else { return [] }
  let columnCount = firstRow.count

  return (0..<columnCount).map { columnIndex in
    val.reversed().map { $0[columnIndex] }
  }
}

func parse(_ input: String) -> [[Rock]] {
  input.split(separator: "\n").map({ line in
    line.map({ char in
      switch char {
      case "#": return Rock.cube
      case "O": return Rock.round
      default: return Rock.empty
      }
    })
  })
}

// to the right
func tilt(_ start: [[Rock]]) -> [[Rock]] {
  var platform = start
  for (rowIndex, column) in platform.enumerated() {
    for (i, rock) in column.enumerated().reversed() {
      if rock == Rock.round {
        // gonna move it
        platform[rowIndex][i] = Rock.empty
        for j in (i + 1)...column.count {
          if j >= column.count {
            platform[rowIndex][column.count - 1] = Rock.round
          } else if platform[rowIndex][j] != Rock.empty {
            platform[rowIndex][j - 1] = Rock.round
            break
          }
        }
      }
    }
  }
  return platform
}

func toString(_ platform: [[Rock]]) -> String {
  platform.map({ column in
    column.map({ rock in
      switch rock {
      case Rock.empty: return "."
      case Rock.round: return "O"
      case Rock.cube: return "#"
      }
    }).joined()
  }).joined(separator: "\n")
}

func score(_ platform: [[Rock]]) -> Int {
  platform.flatMap({ column in
    column.enumerated().map({ (index, rock) in rock == Rock.round ? index + 1 : 0 })
  }).reduce(0, +)
}

let part1 = parse >>> rotate >>> tilt >>> score

assert(part1(example) == 136)
print(part1(inputFile))

func cycle(_ platform: [[Rock]]) -> [[Rock]] {
  (0..<4).reduce(platform, { (p, _) in (rotate >>> tilt)(p) })
}

func part2(_ input: String) -> Int {
  let platform = parse(input)
  let cycles = 1_000_000_000

  var seen: [String] = []
  var current = platform
  var n = 0

  while true {
    current = cycle(current)
    let str = toString(current)
    if let index = seen.firstIndex(of: str) {
      n = index
      break
    } else {
      seen.append(str)
    }
  }

  let cycleLength = seen.count - n
  let seenIndex = n + (cycles - n) % cycleLength - 1
  return (parse >>> rotate >>> score)(seen[seenIndex])
}

assert(part2(example) == 64)
print(part2(inputFile))
