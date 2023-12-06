import Foundation

let example = """
  Time:      7  15   30
  Distance:  9  40  200
  """

let inputFile = """
  Time:        60     94     78     82
  Distance:   475   2138   1015   1650
  """

struct Race {
  let time: Int
  let distance: Int
}

func parse(_ input: String) -> [Race] {
  let lists = input.split(separator: "\n").map({ (line: Substring) -> [Int] in
    var splits = line.split(separator: " ")
    splits.removeFirst()
    return splits.map({ Int($0)! })
  })
  return Array(zip(lists[0], lists[1])).map({ Race(time: $0.0, distance: $0.1) })
}

func part1(_ input: String) -> Int {
  parse(input).map({ (race: Race) -> Int in
    (0...race.time).map({ $0 * (race.time - $0) }).filter({ $0 > race.distance }).count
  }).reduce(1, { $0 * $1 })
}

assert(part1(example) == 288)
print(part1(inputFile))

func parse2(_ input: String) -> Race {
  let ints = input.split(separator: "\n").map({ (line: Substring) -> [Substring] in
    var splits = line.split(separator: " ")
    splits.removeFirst()
    return splits
  }).map({ Int($0.joined())! })
  return Race(time: (ints[0]), distance: ints[1])
}

func part2(_ input: String) -> Int {
  let race = parse2(input)

  var min = 0
  for i in (0...race.time) {
    let distance = i * (race.time - i)
    if distance > race.distance {
      min = i
      break
    }
  }

  var max = 0
  for i in (0...race.time).reversed() {
    let distance = i * (race.time - i)
    if distance > race.distance {
      max = i
      break
    }
  }
  return (min...max).count
}

assert(part2(example) == 71503)
print(part2(inputFile))
