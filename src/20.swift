import Foundation

// extension StringProtocol {
//   subscript(offset: Int) -> Character {
//     self[index(startIndex, offsetBy: offset)]
//   }
// }

let example = """
  broadcaster -> a, b, c
  %a -> b
  %b -> c
  %c -> inv
  &inv -> a
  """

let example2 = """
  broadcaster -> a
  %a -> inv, con
  &inv -> b
  %b -> con
  &con -> output
  """

let inputFile = try String(contentsOfFile: "./src/20.input", encoding: .utf8).trimmingCharacters(
  in: .newlines)

enum ModuleType {
  case flipFlop, conjunction, broadcast
}

struct Module: Hashable {
  let type: ModuleType
  let identifier: String
}

enum Pulse {
  case high, low
}

protocol Node {
  mutating func receive(_ pulse: Pulse, from: String) -> Pulse?
}

struct FlipFlop: Node {
  var on: Bool

  mutating func receive(_ pulse: Pulse, from: String) -> Pulse? {
    switch pulse {
    case .high:
      return nil
    case .low:
      let result: Pulse = self.on ? .low : .high
      self.on = !self.on
      return result
    }
  }
}

struct Conjunction: Node {
  var memory: [String: Pulse]

  mutating func receive(_ pulse: Pulse, from: String) -> Pulse? {
    self.memory[from] = pulse
    let allHigh = self.memory.reduce(true, { accum, keyValue in accum && keyValue.1 == .high })
    return allHigh ? .low : .high
  }
}

struct Broadcast: Node {
  mutating func receive(_ pulse: Pulse, from: String) -> Pulse? {
    return pulse
  }
}

struct Graph {
  let edges: [String: [String]]
  var nodes: [String: Node]
  var queue: [(from: String, to: String, pulse: Pulse)]
}

func parse(_ input: String) -> Graph {
  let mapping: [(module: Module, destinations: [String])] = input.split(separator: "\n").map({
    line in
    let splits = line.components(separatedBy: " -> ")
    let destinationModules = splits[1].components(separatedBy: ", ").map({ String($0) })
    let type =
      splits[0].first == "%"
      ? ModuleType.flipFlop : splits[0].first == "&" ? ModuleType.conjunction : ModuleType.broadcast
    let identifier: String = type == .broadcast ? splits[0] : String(splits[0].dropFirst())
    let module = Module(type: type, identifier: identifier)
    return (module, destinationModules)
  })

  var edges: [String: [String]] = [:]
  for (module, destinations) in mapping {
    edges[module.identifier] = destinations
  }

  var nodes: [String: Node] = [:]
  for (module, _) in mapping {
    let node: Node = {
      switch module.type {
      case .conjunction:
        let inputs: [String] = edges.keys.filter({ edges[$0]!.contains(module.identifier) })
        return Conjunction(memory: Dictionary(uniqueKeysWithValues: inputs.map { ($0, .low) }))
      case .flipFlop:
        return FlipFlop(on: false)
      case .broadcast:
        return Broadcast()
      }
    }()
    nodes[module.identifier] = node
  }

  return Graph(edges: edges, nodes: nodes, queue: [])
}

struct Presses {
  var high = 0
  var low = 0
}

func part1(_ input: String) -> Int {
  var graph = parse(input)
  var presses = Presses(high: 0, low: 0)

  for _ in 1...1000 {
    graph.queue.append(("button", "broadcaster", .low))

    while graph.queue.count > 0 {
      let item = graph.queue.removeFirst()

      switch item.pulse {
      case .high: presses.high += 1
      case .low: presses.low += 1
      }

      if let outputPulse = graph.nodes[item.to]?.receive(item.pulse, from: item.from) {
        let destinations = graph.edges[item.to]!
        for dest in destinations {
          graph.queue.append((from: item.to, to: dest, pulse: outputPulse))
        }
      }
    }
  }
  return presses.high * presses.low
}

assert(part1(example) == 32_000_000)
assert(part1(example2) == 11_687_500)
print(part1(inputFile))

// day 8
func gcd(_ a: Int, _ b: Int) -> Int {
  b == 0 ? a : gcd(b, a % b)
}

func lcm(_ a: Int, _ b: Int) -> Int {
  (a * b) / gcd(a, b)
}

func part2(_ input: String) -> Int {
  // conjunction module feeds rx calle &jz
  // repeatedly press button and record when each input hits &jz
  // once they've all hit, take lcm
  var graph = parse(input)
  let penultimate = graph.edges.keys.first(where: { graph.edges[$0]!.contains("rx") })!
  let inputs = graph.edges.keys.filter({ graph.edges[$0]!.contains(penultimate) })

  var hits = Dictionary(uniqueKeysWithValues: inputs.map { ($0, -1) })

  var presses = 0
  while true {
    graph.queue.append(("button", "broadcaster", .low))
    presses += 1

    while graph.queue.count > 0 {
      let item = graph.queue.removeFirst()

      if item.to == penultimate && item.pulse == .high && hits[item.from] == -1 {
        hits[item.from] = presses

        if hits.values.allSatisfy({ $0 != -1 }) {
          return hits.values.reduce(1, lcm)
        }
      }

      if let outputPulse = graph.nodes[item.to]?.receive(item.pulse, from: item.from) {
        let destinations = graph.edges[item.to]!
        for dest in destinations {
          graph.queue.append((from: item.to, to: dest, pulse: outputPulse))
        }
      }
    }
  }
  assert(false)
}

print(part2(inputFile))
