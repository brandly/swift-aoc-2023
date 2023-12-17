import Foundation

let example = """
  2413432311323
  3215453535623
  3255245654254
  3446585845452
  4546657867536
  1438598798454
  4457876987766
  3637877979653
  4654967986887
  4564679986453
  1224686865563
  2546548887735
  4322674655533
  """

let inputFile = try String(contentsOfFile: "./src/17.input", encoding: .utf8).trimmingCharacters(
  in: .newlines)

struct Coordinate: Hashable {
  let x: Int
  let y: Int

  static func + (left: Coordinate, right: Coordinate) -> Coordinate {
    Coordinate(x: left.x + right.x, y: left.y + right.y)
  }
}

enum Direction {
  case right, left, up, down

  func toCoords() -> Coordinate {
    switch self {
    case .up: return Coordinate(x: 0, y: -1)
    case .down: return Coordinate(x: 0, y: 1)
    case .left: return Coordinate(x: -1, y: 0)
    case .right: return Coordinate(x: 1, y: 0)
    }
  }
}

struct City {
  let blocks: [Coordinate: Int]
  let width: Int
  let height: Int
}

func parse(_ input: String) -> City {
  let trios = input.split(separator: "\n").enumerated().flatMap({ y, row in
    row.enumerated().map({ x, char in (x, y, Int(String(char))!) })
  })
  let blocks: [Coordinate: Int] = trios.reduce(
    [:],
    { result, trio in
      var mutable = result
      mutable[Coordinate(x: trio.0, y: trio.1)] = trio.2
      return mutable
    })
  return City(
    blocks: blocks, width: input.split(separator: "\n")[0].count,
    height: input.split(separator: "\n").count)
}

struct State: Comparable {
  let coords: Coordinate
  let direction: Direction
  let heat: Int

  func turns() -> [Direction] {
    switch self.direction {
    case .left, .right:
      return [.up, .down]
    case .up, .down:
      return [.left, .right]
    }
  }

  static func < (lhs: State, rhs: State) -> Bool {
    lhs.heat < rhs.heat
  }
}

struct Index: Hashable {
  let coords: Coordinate
  let direction: Direction

  static func from(state: State) -> Index {
    Index(coords: state.coords, direction: state.direction)
  }
}

struct Best {
  var values: [Index: Int]

  func get(_ state: State) -> Int {
    self.values[Index.from(state: state)] ?? Int.max
  }

  mutating func set(_ state: State) {
    self.values[Index.from(state: state)] = state.heat
  }
}

func part1(_ input: String) -> Int {
  let city = parse(input)
  let start = Coordinate(x: 0, y: 0)
  let goal = Coordinate(x: city.width - 1, y: city.height - 1)
  var bestToGoal = Int.max

  let initial: [State] = [
    State(coords: start, direction: .right, heat: 0),
    State(coords: start, direction: .down, heat: 0),
  ]
  var best = Best(values: [:])
  let states = Heap<State>(comparator: <)
  for s in initial {
    best.set(s)
    states.insert(s)
  }

  while let state = states.popTop() {
    if state.coords == goal {
      bestToGoal = min(state.heat, bestToGoal)
      continue
    }

    if state.heat > bestToGoal {
      continue
    }

    for direction in state.turns() {
      var coords = state.coords
      var heat = state.heat
      let move = direction.toCoords()
      for _ in 1...3 {
        coords = coords + move
        // stepped out of city
        if !city.blocks.keys.contains(coords) {
          break
        }

        heat += city.blocks[coords]!
        let step = State(coords: coords, direction: direction, heat: heat)

        if step.heat < best.get(step) {
          best.set(step)
          states.insert(step)
        }
      }
    }
  }

  return bestToGoal
}

/// This is a simple Heap implementation which can be used as a priority queue.
public class Heap<T: Comparable> {
  typealias HeapComparator = (_ l: T, _ r: T) -> Bool
  var heap = [T]()
  var count: Int {
    heap.count
  }

  var comparator: HeapComparator

  /// bubbleUp is called after appending the item to the end of the queue.  Depending on the comparator,
  /// it will bubbleUp to its approriate spot
  /// - Parameter idx: Index to bubble up.  This starts after insert with last index being passed in.
  private func bubbleUp(idx: Int) {
    let parent = (idx - 1) / 2

    if idx <= 0 {
      return
    }

    if comparator(heap[idx], heap[parent]) {
      heap.swapAt(parent, idx)
      bubbleUp(idx: parent)
    }
  }

  /// Heapify the current heap.  This method walks down the children and rearranges them in comparator order.
  /// - Parameter idx: index to heapify.
  private func heapify(_ idx: Int) {
    let left = idx * 2 + 1
    let right = idx * 2 + 2

    var comp = idx

    if count > left && comparator(heap[left], heap[comp]) {
      comp = left
    }
    if count > right && comparator(heap[right], heap[comp]) {
      comp = right
    }
    if comp != idx {
      heap.swapAt(comp, idx)
      heapify(comp)
    }
  }

  init(comparator: @escaping HeapComparator) {
    self.comparator = comparator
  }

  /// Insert item into the heap.  This walks up the parents. This is a O(log n) operation
  /// - Parameter item: item that is comparable.
  func insert(_ item: T) {
    heap.append(item)
    bubbleUp(idx: count - 1)
  }

  /// Get the top item in the heap based on comparator. This is a 0(1) operation
  /// - Returns: top item or nil if empty.
  func getTop() -> T? {
    return heap.first
  }

  /// Remove the top item.  This is a O(log n) operation
  /// - Returns: returns top item based on comparator or nil if empty.
  func popTop() -> T? {
    let item = heap.first
    if count > 1 {
      // set the top to the last element and heapify
      // this means we can remove the last after "poping" the first.
      heap[0] = heap[count - 1]
      heap.removeLast()
      heapify(0)
    } else if count == 1 {
      heap.removeLast()
    } else {
      return nil
    }

    return item
  }
}

assert(part1(example) == 102)
print(part1(inputFile))
