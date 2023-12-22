import Foundation

extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

let example = """
  px{a<2006:qkq,m>2090:A,rfg}
  pv{a>1716:R,A}
  lnx{m>1548:A,A}
  rfg{s<537:gd,x>2440:R,A}
  qs{s>3448:A,lnx}
  qkq{x<1416:A,crn}
  crn{x>2662:A,R}
  in{s<1351:px,qqz}
  qqz{s>2770:qs,m<1801:hdj,R}
  gd{a>3333:R,R}
  hdj{m>838:A,pv}

  {x=787,m=2655,a=1222,s=2876}
  {x=1679,m=44,a=2067,s=496}
  {x=2036,m=264,a=79,s=2244}
  {x=2461,m=1339,a=466,s=291}
  {x=2127,m=1623,a=2188,s=1013}
  """

let inputFile = try String(contentsOfFile: "./src/19.input", encoding: .utf8).trimmingCharacters(
  in: .newlines)

enum Category {
  case x, m, a, s
}

enum Comparator {
  case gt, lt
}

enum Rule {
  case compare(Category, Comparator, Int, Next)
  case fallback(Next)
}

enum Result {
  case accepted, rejected
}

enum Next {
  case identifier(String)
  case result(Result)
}

struct Part {
  let x: Int
  let m: Int
  let a: Int
  let s: Int

  func get(_ category: Category) -> Int {
    switch category {
    case .x: return self.x
    case .m: return self.m
    case .a: return self.a
    case .s: return self.s
    }
  }

  func rating() -> Int {
    self.x + self.m + self.a + self.s
  }
}

typealias Workflow = [Rule]

struct System {
  let workflows: [String: Workflow]
  let parts: [Part]
}

func parseNext(_ input: String) -> Next {
  if input == "A" {
    return Next.result(Result.accepted)
  } else if input == "R" {
    return Next.result(Result.rejected)
  } else {
    return Next.identifier(input)
  }
}

func parseCategory(_ input: String) -> Category {
  switch input {
  case "x": return .x
  case "m": return .m
  case "a": return .a
  case "s": return .s
  default: assert(false)
  }
}

func parse(_ input: String) -> System {
  let components = input.components(separatedBy: "\n\n")

  var workflows: [String: Workflow] = [:]
  for line in components[0].split(separator: "\n") {
    let splits = line.split(separator: "{")
    let rules = String(splits[1]).trimmingCharacters(in: CharacterSet(charactersIn: "}")).split(
      separator: ","
    ).map({ stmt in
      if stmt.contains(":") {
        let colonSplits = stmt.split(separator: ":")
        let next = parseNext(String(colonSplits[1]))

        if stmt.contains(">") {
          let compareSplit = colonSplits[0].split(separator: ">")
          return Rule.compare(
            parseCategory(String(compareSplit[0])), Comparator.gt, Int(compareSplit[1])!, next)
        } else {
          let compareSplit = colonSplits[0].split(separator: "<")
          return Rule.compare(
            parseCategory(String(compareSplit[0])), Comparator.lt, Int(compareSplit[1])!, next)
        }

      } else {
        return Rule.fallback(parseNext(String(stmt)))
      }
    })

    workflows[String(splits[0])] = rules
  }

  return System(
    workflows: workflows,
    parts: components[1].split(separator: "\n").map({ line in
      let pairs = String(line).trimmingCharacters(in: CharacterSet(charactersIn: "{}")).split(
        separator: ","
      ).map({ pair in
        let splits = pair.split(separator: "=")
        return (splits[0], Int(splits[1])!)
      })
      return Part(
        x: pairs.first(where: { $0.0 == "x" })!.1,
        m: pairs.first(where: { $0.0 == "m" })!.1,
        a: pairs.first(where: { $0.0 == "a" })!.1,
        s: pairs.first(where: { $0.0 == "s" })!.1
      )
    })
  )
}

func applyWorkflow(_ part: Part, _ workflow: Workflow) -> Next {
  for rule in workflow {
    // print("    rule", rule)
    switch rule {
    case .compare(let category, let comparator, let int, let next):
      if comparator == Comparator.gt && part.get(category) > int {
        return next
      } else if comparator == Comparator.lt && part.get(category) < int {
        return next
      }
    case .fallback(let next):
      return next
    }
  }
  assert(false)
}

func apply(_ part: Part, _ workflows: [String: Workflow]) -> Result {
  // print("apply", part)
  var status = Next.identifier("in")
  while true {
    // print("  status", status)
    switch status {
    case .result(let result):
      return result
    case .identifier(let str):
      let workflow = workflows[str]!
      status = applyWorkflow(part, workflow)
    }
  }
}

func part1(_ input: String) -> Int {
  let system = parse(input)
  return system.parts.filter({ part in apply(part, system.workflows) == Result.accepted }).map({
    part in part.rating()
  }).reduce(0, +)
}

assert(part1(example) == 19114)
print(part1(inputFile))

// analyze ranges of values for each Category

typealias Contraints = [Category: ClosedRange<Int>]

func possibilitiesInContraints(_ contraints: Contraints) -> Int {
  contraints.reduce(
    1,
    { result, keyValue in
      let (_, value) = keyValue
      let range = value.upperBound - value.lowerBound + 1
      return result * range
    })
}

func countCombos(
  _ workflows: [String: Workflow], _ current: Next, _ contraints: Contraints
) -> Int {
  switch current {
  case .identifier(let identifier):
    var localContraints = contraints
    var result = 0
    for rule in workflows[identifier]! {
      switch rule {
      case .compare(let category, let comparator, let int, let next):
        switch comparator {
        case .gt:
          var ruleContraints = localContraints
          ruleContraints[category] = ruleContraints[category]!.clamped(to: (int + 1)...Int.max)
          result += countCombos(workflows, next, ruleContraints)
          localContraints[category] = localContraints[category]!.clamped(to: 1...int)
        case .lt:
          var ruleContraints = localContraints
          ruleContraints[category] = ruleContraints[category]!.clamped(to: 1...(int - 1))
          result += countCombos(workflows, next, ruleContraints)
          localContraints[category] = localContraints[category]!.clamped(to: int...Int.max)
        }
      case .fallback(let next):
        result += countCombos(workflows, next, localContraints)
      }
    }
    return result
  case .result(.accepted):
    return possibilitiesInContraints(contraints)
  case .result(.rejected):
    return 0
  }
}

func part2(_ input: String) -> Int {
  countCombos(
    parse(input).workflows, Next.identifier("in"),
    [
      .x: 1...4000,
      .m: 1...4000,
      .a: 1...4000,
      .s: 1...4000,
    ])
}

assert(part2(example) == 167_409_079_868_000)
print(part2(inputFile))
