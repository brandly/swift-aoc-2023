import Foundation

let example = """
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """

let inputFile = try String(contentsOfFile: "./src/04.input", encoding: .utf8)

struct Card {
  var id: Int
  var winningNumbers: [Int]
  var numbersYouHave: [Int]
}

func parseCards(input: String) -> [Card] {
  input.split(separator: "\n").map({ (line: Substring) -> Card in
    let cardAndNums = line.split(separator: ":")
    let id = Int(cardAndNums[0].split(separator: " ")[1])!
    let nums = cardAndNums[1].split(separator: "|").map({
      $0.split(separator: " ").map({ Int($0)! })
    })
    return Card(id: id, winningNumbers: nums[0], numbersYouHave: nums[1])
  })
}

func points(card: Card) -> Int {
  let count = card.numbersYouHave.filter({ card.winningNumbers.contains($0) }).count
  return count == 0 ? 0 : Int(pow(Double(2), Double(count - 1)))
}

func part1(input: String) -> Int {
  return parseCards(input: input).map(points).reduce(0, { $0 + $1 })
}

assert(part1(input: example) == 13)
print(part1(input: inputFile))

func part2(input: String) -> Int {
  let cards = parseCards(input: input)
  var counts = cards.map { _ in 1 }

  for (index, card) in cards.enumerated() {
    let count = card.numbersYouHave.filter({ card.winningNumbers.contains($0) }).count

    let start = index + 1
    let end = min(index + count, counts.count - 1)
    // this doesn't feel graceful
    if end >= start {
      for i in start...end {
        counts[i] += counts[index]
      }
    }
  }

  return counts.reduce(0, { $0 + $1 })
}

assert(part2(input: example) == 30)
print(part2(input: inputFile))
