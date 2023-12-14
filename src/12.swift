import Foundation

// let me access strings by index please
extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """

let inputFile = try String(contentsOfFile: "./src/12.input", encoding: .utf8)

enum Spring {
  case operational, damaged, unknown
}

struct Row {
  let springs: [Spring]
  let groups: [Int]
}

func parse(_ input: String) -> [Row] {
  input.split(separator: "\n").map({ line in
    let splits = line.split(separator: " ")
    let springs = splits[0].map({ char in
      switch char {
      case ".": return Spring.operational
      case "#": return Spring.damaged
      case "?": return Spring.unknown
      default: assert(false)
      }
    })
    return Row(springs: springs, groups: splits[1].split(separator: ",").map({ Int($0)! }))
  })
}

func part1(_ input: String) -> Int {
  let rows = parse(input)
  let counts = rows.map({ possibilities($0) })
  return counts.reduce(0, +)
}

assert(part1(example) == 21)
print(part1(inputFile))

func joinArrays<T>(arrays: [[T]], withSeparator separator: [T]) -> [T] {
  guard !arrays.isEmpty else { return [] }

  let joinedArray = arrays.dropFirst().reduce(arrays.first!) { result, array in
    result + separator + array
  }

  return joinedArray
}

func expand(_ rows: [Row]) -> [Row] {
  let repeatCount = 5
  return rows.map({ row in
    Row(
      springs: joinArrays(
        arrays: Array(repeatElement(row.springs, count: repeatCount)),
        withSeparator: [Spring.unknown]
      ),
      groups: Array(repeatElement(row.groups, count: repeatCount).flatMap { $0 })
    )
  })
}

func toString(_ springs: [Spring]) -> String {
  springs.map({ spring in
    switch spring {
    case Spring.damaged: return "#"
    case Spring.operational: return "."
    case Spring.unknown: return "?"
    }
  }).joined()
}

func possibilities(_ row: Row) -> Int {
  var springs = row.springs
  springs.append(Spring.operational)
  var cache: [Int: [Int: Int]] = [:]
  return possibilitesHelper(springs, row.groups, &cache)
}

func possibilitesHelper(_ springs: [Spring], _ groups: [Int], _ cache: inout [Int: [Int: Int]])
  -> Int
{
  // no more to find
  if groups.count == 0 {
    // if more are damaged, we've reached a dead end
    // otherwise we have no damaged left, so 1 possibility
    return springs.contains(Spring.damaged) ? 0 : 1
  }

  // make sure we have enough springs left
  if springs.count < groups.reduce(0, +) + groups.count {
    return 0
  }

  if let groupCache = cache[groups.count - 1], let cached = groupCache[springs.count - 1] {
    return cached
  }
  var result = 0
  if springs[0] != Spring.damaged {
    // handle .operational
    result += possibilitesHelper(Array(springs.dropFirst()), groups, &cache)
  }
  let nextGroup = groups[0]
  if !springs.prefix(nextGroup).contains(Spring.operational) && springs[nextGroup] != Spring.damaged
  {
    // handle damaged
    result += possibilitesHelper(
      Array(springs.dropFirst(nextGroup + 1)), Array(groups.dropFirst()), &cache)
  }

  if cache[groups.count - 1] == nil {
    cache[groups.count - 1] = [:]
  }
  cache[groups.count - 1]![springs.count - 1] = result
  return result
}

func part2(_ input: String) -> Int {
  let rows = parse(input)
  let expanded = expand(rows)
  return expanded.map({ possibilities($0) }).reduce(0, +)
}

assert(part2(example) == 525152)
print(part2(inputFile))
