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

func contiguousGroups(_ springs: [Spring]) -> [Int] {
  var progress = 0
  var groups: [Int] = []
  for spring in springs {
    if spring == Spring.damaged {
      progress += 1
    } else if progress > 0 {
      groups.append(progress)
      progress = 0
    }
  }
  if progress > 0 {
    groups.append(progress)
  }
  return groups
}

func part1(_ input: String) -> Int {
  let rows = parse(input)
  let counts = rows.map({ possibilities($0).count })
  print("ZZZ counts!", counts)
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

func extend(_ springs: [Spring], _ progress: [Spring]) -> [[Spring]] {
  if springs.count == progress.count {
    print("called extend but already reached limit")
    assert(false)
  }
  let next = springs[progress.count]
  switch next {
  case Spring.operational:
    return [progress + [next]]
  case Spring.damaged:
    return [progress + [next]]
  case Spring.unknown:
    return [progress + [Spring.operational], progress + [Spring.damaged]]
  }
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

func possibilities(_ row: Row) -> [[Spring]] {
  // BFS + pruning
  var inProgress: [[Spring]] = [[]]
  for _ in 0..<row.springs.count {
    inProgress = inProgress.flatMap({ extend(row.springs, $0) }).filter({ (springs: [Spring]) in
      let groups = contiguousGroups(springs)
      if groups.count == 0 {
        return true
      }
      if groups.count > row.groups.count {
        return false
      }
      let relevantGroups = row.groups.prefix(groups.count)
      var zipped = Array(zip(groups, relevantGroups))
      let last = zipped.removeLast()

      let remainingGroups = Array(row.groups.dropFirst(groups.count))
      let remainingSprings = Array(row.springs.dropFirst(springs.count))
      let enoughRemaining =
        remainingSprings.count >= (remainingGroups.reduce(0, +) + remainingGroups.count) - 1
      // print("remainingGroups", remainingGroups, "remainingSprings", toString(remainingSprings), "enoughRemaining", enoughRemaining)

      let countsAlign =
        zipped.allSatisfy({ $0.0 == $0.1 })
        && (springs.last == Spring.damaged ? last.0 <= last.1 : last.0 == last.1)
      let result = countsAlign && enoughRemaining
      // if !result {
      //   print("prune!", toString(springs))
      // }

      return result
    })
    // print("inProgress")
    // for (i, springs) in inProgress.enumerated() {
    //   print("  ", i + 1, toString(springs))
    // }
  }

  return inProgress
}

func part2(_ input: String) -> Int {
  let rows = parse(input)

  let expanded = expand(rows)
  // print(rows)
  return expanded.map({ possibilities($0).count }).reduce(0, +)
}

// assert(part2(example) == 525152)
print(part2(inputFile))
