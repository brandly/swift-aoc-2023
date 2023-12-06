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

func groupIntoTuples(_ array: [Int]) -> [(Int, Int)] {
  var result: [(Int, Int)] = []
  for i in stride(from: 0, to: array.count - 1, by: 2) {
    let tuple = (array[i], array[i + 1])
    result.append(tuple)
  }
  return result
}

struct Range {
  let start: Int
  let end: Int
}

struct Shift {
  let range: Range
  let offset: Int
}

func mappingToShifts(_ mapping: Mapping) -> [[Shift]] {
  [
    mapping.seedToSoil,
    mapping.soilToFertilizer,
    mapping.fertilizerToWater,
    mapping.waterToLight,
    mapping.lightToTemperature,
    mapping.temperatureToHumidity,
    mapping.humidityToLocation,
  ].map({
    $0.map({
      Shift(
        range: Range(start: $0.sourceRangeStart, end: $0.sourceRangeStart + $0.rangeLength),
        offset: $0.destinationRangeStart - $0.sourceRangeStart)
    })
  })
}

func applyShift(_ range: Range, _ shift: Shift) -> Range {
  Range(start: range.start + shift.offset, end: range.end + shift.offset)
}

func convert(_ r: Range, shifts: [Shift]) -> [Range] {
  var result: [Range] = []
  var rangesToHandle = [r]

  while rangesToHandle.count > 0 {
    let range = rangesToHandle.removeFirst()
    var partial: [Range] = []

    for shift in shifts {
      if range.start >= shift.range.start && range.end <= shift.range.end {
        // print("total overlap", range, shift)
        partial.append(applyShift(range, shift))
        break
      } else if range.end >= shift.range.start && range.end <= shift.range.end {
        // print("tail overlap", range, shift)
        let tail = Range(start: shift.range.start, end: range.end)
        let head = Range(start: range.start, end: shift.range.start - 1)
        partial.append(applyShift(tail, shift))
        rangesToHandle.append(head)
        break
      } else if range.start >= shift.range.start && range.start <= shift.range.end {
        // print("head overlap", range, shift)
        assert(shift.range.end < range.end)
        let head = Range(start: range.start, end: shift.range.end)
        let tail = Range(start: shift.range.end + 1, end: range.end)
        partial.append(applyShift(head, shift))
        rangesToHandle.append(tail)
        break
      } else if range.start <= shift.range.start && range.end > shift.range.end {
        // print("triad contained within range", range, shift)
        let head = Range(start: range.start, end: shift.range.start - 1)
        let overlap = shift.range
        let tail = Range(start: shift.range.end + 1, end: range.end)
        partial.append(applyShift(overlap, shift))
        rangesToHandle.append(head)
        rangesToHandle.append(tail)
        break
      } else {
        assert(range.end < shift.range.start || range.start > shift.range.end)
      }
    }

    if partial.count > 0 {
      result += partial
    } else {
      // Any source numbers that aren't mapped correspond to the same destination number.
      result.append(range)
    }
  }

  return result
}

func part2(input: String) -> Int {
  let (seeds, mapping) = parse(input: input)

  let shiftSets = mappingToShifts(mapping)
  var ranges = groupIntoTuples(seeds).map({ Range(start: $0.0, end: $0.0 + $0.1 - 1) })

  for shifts in shiftSets {
    ranges = ranges.flatMap({ convert($0, shifts: shifts) })
  }

  return ranges.map({ $0.start }).min()!
}
assert(part2(input: example) == 46)
print(part2(input: inputFile))
