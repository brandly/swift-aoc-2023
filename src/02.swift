import Foundation

let example = """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """

let inputFile = try String(contentsOfFile: "./src/02.input", encoding: .utf8)

struct Bag {
  var red = 0
  var green = 0
  var blue = 0
}

struct Game {
  var id: Int
  var grabs: [Bag]
}

func parse(input: String) -> [Game] {
  return input.split(whereSeparator: \.isNewline).map({ (line: Substring) -> Game in
    let gameAndGrabs = line.split(separator: ":")
    let gameId = Int(gameAndGrabs[0].filter { $0.isNumber })!

    let grabs = gameAndGrabs[1].split(separator: ";").map({ (bag: Substring) -> Bag in
      var result = Bag()
      for pair in bag.split(separator: ",") {
        let splits = pair.split(separator: " ")
        let count = Int(splits[0])!
        let color = splits[1]
        if color == "red" {
          result.red = count
        } else if color == "green" {
          result.green = count
        } else if color == "blue" {
          result.blue = count
        }
      }
      return result
    })

    return Game(id: gameId, grabs: grabs)
  })
}

func part1(input: String) -> Int {
  let games = parse(input: input)
  return games.filter({ $0.grabs.allSatisfy({ $0.red <= 12 && $0.green <= 13 && $0.blue <= 14 }) })
    .map({ $0.id })
    .reduce(0, { $0 + $1 })
}

assert(part1(input: example) == 8)
print(part1(input: inputFile))

func smallestBag(a: Bag, b: Bag) -> Bag {
  var bag = Bag()
  bag.blue = max(a.blue, b.blue)
  bag.red = max(a.red, b.red)
  bag.green = max(a.green, b.green)
  return bag
}

func part2(input: String) -> Int {
  let games = parse(input: input)
  return games.map({ $0.grabs.reduce(Bag(), smallestBag) })
    .map({ $0.red * $0.green * $0.blue })
    .reduce(0, { $0 + $1 })
}

assert(part2(input: example) == 2286)
print(part2(input: inputFile))
