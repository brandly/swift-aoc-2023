import Foundation

let example = """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

let inputFile = try String(contentsOfFile: "./src/07.input", encoding: .utf8)

enum HandType: Int, Comparable {
  case HighCard = 0
  case OnePair, TwoPair, ThreeKind, FullHouse, FourKind, FiveKind

  static func < (lhs: HandType, rhs: HandType) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  static func == (lhs: HandType, rhs: HandType) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}
enum Card: Int, Comparable {
  case Two = 2
  case Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace

  static func < (lhs: Card, rhs: Card) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  static func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}
struct Hand {
  let cards: [Card]
  let type: HandType
  let bid: Int
}

func parseCard(_ str: Character) -> Card {
  switch str {
  case "2": return Card.Two
  case "3": return Card.Three
  case "4": return Card.Four
  case "5": return Card.Five
  case "6": return Card.Six
  case "7": return Card.Seven
  case "8": return Card.Eight
  case "9": return Card.Nine
  case "T": return Card.Ten
  case "J": return Card.Jack
  case "Q": return Card.Queen
  case "K": return Card.King
  case "A": return Card.Ace
  default: assert(false)
  }
}

func getType(_ cards: [Card]) -> HandType {
  let cardToCount = cards.reduce(into: [:]) { (accum: inout [Card: Int], card: Card) in
    if let val = accum[card] {
      accum[card] = val + 1
    } else {
      accum[card] = 1
    }
  }

  let uniqueCards = cardToCount.keys.count
  let pairs = cardToCount.values.filter({ $0 == 2 })
  if uniqueCards == 1 {
    return HandType.FiveKind
  } else if uniqueCards == 2 {
    return cardToCount.values.contains(4) ? HandType.FourKind : HandType.FullHouse
  } else if cardToCount.values.contains(3) {
    return HandType.ThreeKind
  } else if pairs.count == 2 {
    return HandType.TwoPair
  } else if pairs.count == 1 {
    return HandType.OnePair
  }
  return HandType.HighCard
}

func parse(_ input: String) -> [Hand] {
  input.split(separator: "\n").map({ (line: Substring) -> Hand in
    let splits = line.split(separator: " ")
    let cards = splits[0].map(parseCard)
    let bid = Int(splits[1])!

    return Hand(cards: cards, type: getType(cards), bid: bid)
  })
}

func part1(_ input: String) -> Int {
  let hands = parse(input)
  return hands.sorted { (a, b) -> Bool in
    if a.type > b.type {
      return true
    } else if a.type == b.type {
      for (aCard, bCard) in zip(a.cards, b.cards) {
        if aCard > bCard {
          return true
        } else if aCard == bCard {
          continue
        } else {
          break
        }
      }
    }

    return false
  }.enumerated().map({ (index, card) in
    let rank = hands.count - index
    return rank * card.bid
  }).reduce(0, { $0 + $1 })
}

assert(part1(example) == 6440)
print(part1(inputFile))

func mostCommonElement<T: Hashable>(in array: [T]) -> T? {
  var counts = [T: Int]()
  for element in array {
    counts[element, default: 0] += 1
  }
  return counts.max(by: { $0.value < $1.value })?.key
}

func elevateHand(_ hand: Hand) -> Hand {
  let noJokers = hand.cards.filter({ $0 != Card.Jack })
  if let popular = mostCommonElement(in: noJokers) {
    let imaginedCards = hand.cards.map({ $0 == Card.Jack ? popular : $0 })
    return Hand(cards: hand.cards, type: getType(imaginedCards), bid: hand.bid)
  } else {
    // all jokers baby
    return Hand(cards: hand.cards, type: HandType.FiveKind, bid: hand.bid)
  }
}

func part2(_ input: String) -> Int {
  let hands = parse(input)
  return hands.map(elevateHand).sorted { (a, b) -> Bool in
    if a.type > b.type {
      return true
    } else if a.type == b.type {
      for (aCard, bCard) in zip(a.cards, b.cards) {
        if aCard == Card.Jack && bCard == Card.Jack { continue }
        if bCard == Card.Jack { return true }
        if aCard == Card.Jack { return false }
        if aCard > bCard {
          return true
        } else if aCard == bCard {
          continue
        } else {
          break
        }
      }
    }

    return false
  }.enumerated().map({ (index, card) in
    let rank = hands.count - index
    return rank * card.bid
  }).reduce(0, { $0 + $1 })
}

assert(part2(example) == 5905)
print(part2(inputFile))
