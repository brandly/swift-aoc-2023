import Foundation

let example = """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """

let inputFile = try String(contentsOfFile: "./src/01.input", encoding: .utf8)

func part1(input: String) -> Int {
  return input.split(whereSeparator: \.isNewline)
    .map({ (line: Substring) -> Int in
      let nums = line.filter { $0.isNumber }
      return Int(String([nums.first!, nums.last!]))!
    })
    .reduce(0, { $0 + $1 })
}

assert(part1(input: example) == 142)
print(part1(input: inputFile))

let example2 = """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

let numStrings = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

func parseNums(line: Substring) -> [String] {
  var nums: [String] = []
  for index in line.indices {
    let char = line[index]
    if char.isNumber {
      nums.append(String(char))
    } else {
      for strIndex in numStrings.indices {
        if line[index...].starts(with: numStrings[strIndex]) {
          nums.append(String(strIndex + 1))
        }
      }
    }
  }
  return nums
}

func part2(input: String) -> Int {
  return input.split(whereSeparator: \.isNewline)
    .map({ (line: Substring) -> Int in
      let nums = parseNums(line: line)
      return Int(nums.first! + nums.last!)!
    })
    .reduce(0, { $0 + $1 })
}

assert(part2(input: example2) == 281)
print(part2(input: inputFile))
