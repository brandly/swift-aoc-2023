import Foundation

let example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

let inputFile = try String(contentsOfFile: "./src/15.input", encoding: .utf8).trimmingCharacters(
  in: .newlines)

func parse(_ input: String) -> [String] {
  input.split(separator: ",").map({ String($0) })
}

func HASH(_ input: String) -> Int {
  var current = 0
  for char in input {
    if let asciiValue = char.asciiValue {
      current = ((current + Int(asciiValue)) * 17) % 256
    } else {
      assert(false)
    }
  }
  return current
}

func part1(_ input: String) -> Int {
  parse(input).map(HASH).reduce(0, +)
}

assert(HASH("HASH") == 52)
assert(part1(example) == 1320)
print(part1(inputFile))

enum Action {
  case insert(Int)
  case remove
}

func parse2(_ input: String) -> [(String, Action)] {
  parse(input).map({ item in
    if item.last == "-" {
      return (String(item.dropLast()), Action.remove)
    } else {
      let splits = item.split(separator: "=")
      return (String(splits[0]), Action.insert(Int(splits[1])!))
    }
  })
}

func part2(_ input: String) -> Int {
  let pairs = parse2(input)
  var hashmap: [[(String, Int)]] = (0..<256).map { _ in [] }

  for pair in pairs {
    let key = HASH(pair.0)
    switch pair.1 {
    case .insert(let value):
      if hashmap[key].map({ $0.0 }).contains(pair.0) {
        hashmap[key] = hashmap[key].map({ $0.0 == pair.0 ? (pair.0, value) : $0 })
      } else {
        hashmap[key].append((pair.0, value))
      }
    case .remove:
      hashmap[key] = hashmap[key].filter({ $0.0 != pair.0 })
    }
  }

  return hashmap.enumerated().flatMap({ boxIndex, list in
    list.enumerated().map({ slotIndex, pair in
      (boxIndex + 1) * (slotIndex + 1) * pair.1
    })
  }).reduce(0, +)
}

assert(part2(example) == 145)
print(part2(inputFile))
