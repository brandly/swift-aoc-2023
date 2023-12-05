import Foundation

infix operator >>> : MultiplicationPrecedence
func >>> <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) -> C) -> (A) -> C {
  return { rhs(lhs($0)) }
}

let example = """
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """

let inputFile = try String(contentsOfFile: "./src/05.input", encoding: .utf8)

struct Mapping {
  let seedToSoil: [Triad]
  let soilToFertilizer: [Triad]
  let fertilizerToWater: [Triad]
  let waterToLight: [Triad]
  let lightToTemperature: [Triad]
  let temperatureToHumidity: [Triad]
  let humidityToLocation: [Triad]
}

struct Triad {
  let destinationRangeStart: Int
  let sourceRangeStart: Int
  let rangeLength: Int
}

func createConverter(_ triads: [Triad]) -> (Int) -> Int {
  return { id in
    for triad in triads {
      if id >= triad.sourceRangeStart && id < (triad.sourceRangeStart + triad.rangeLength) {
        return (id - triad.sourceRangeStart) + triad.destinationRangeStart
      }
    }
    return id
  }
}

func parseSeeds(input: String) -> [Int] {
  input.split(separator: ":")[1].split(separator: " ").map({ Int($0)! })
}

func parseTriads(component: String) -> [Triad] {
  var splits = component.split(separator: "\n")
  splits.removeFirst()  // it's the text label
  return splits.map({ (line: Substring) -> Triad in
    let nums = line.split(separator: " ").map({ Int($0)! })
    return Triad(destinationRangeStart: nums[0], sourceRangeStart: nums[1], rangeLength: nums[2])
  })
}

func parse(input: String) -> ([Int], Mapping) {
  let components = input.components(separatedBy: "\n\n")

  let seedToSoil = parseTriads(component: components[1])
  let soilToFertilizer = parseTriads(component: components[2])
  let fertilizerToWater = parseTriads(component: components[3])
  let waterToLight = parseTriads(component: components[4])
  let lightToTemperature = parseTriads(component: components[5])
  let temperatureToHumidity = parseTriads(component: components[6])
  let humidityToLocation = parseTriads(component: components[7])

  return (
    parseSeeds(input: components[0]),
    Mapping(
      seedToSoil: seedToSoil,
      soilToFertilizer: soilToFertilizer,
      fertilizerToWater: fertilizerToWater,
      waterToLight: waterToLight,
      lightToTemperature: lightToTemperature,
      temperatureToHumidity: temperatureToHumidity,
      humidityToLocation: humidityToLocation)
  )
}

func part1(input: String) -> Int {
  let (seeds, mapping) = parse(input: input)

  let seedToSoil = createConverter(mapping.seedToSoil)
  let soilToFertilizer = createConverter(mapping.soilToFertilizer)
  let fertilizerToWater = createConverter(mapping.fertilizerToWater)
  let waterToLight = createConverter(mapping.waterToLight)
  let lightToTemperature = createConverter(mapping.lightToTemperature)
  let temperatureToHumidity = createConverter(mapping.temperatureToHumidity)
  let humidityToLocation = createConverter(mapping.humidityToLocation)

  let seedToLocation =
    seedToSoil >>> soilToFertilizer >>> fertilizerToWater >>> waterToLight >>> lightToTemperature
    >>> temperatureToHumidity >>> humidityToLocation

  return seeds.map(seedToLocation).min()!
}

assert(part1(input: example) == 35)
print(part1(input: inputFile))
