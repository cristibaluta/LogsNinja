import Cocoa

struct Filter {
    var words: [String]
    var isPositive = true
}

let logs = [
    "log1 do something",
    "log1 do something with str1"
]
var str = "log0, log1 && str1,log2 && str2 str3 ,log3 || str4 || str5, log4"
var comp = str.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
print(comp)

let singles: [String] = comp.compactMap({
    return (!$0.contains("&&") && !$0.contains("||")) ? $0 : nil
})
let ands: [[String]] = comp.compactMap({
    let c = $0.components(separatedBy: "&&").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
    return c.count > 1 ? c : nil
})
let ors: [[String]] = comp.compactMap({
    let c = $0.components(separatedBy: "||").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
    return c.count > 1 ? c : nil
})
print(singles)
print(ands)
print(ors)

let filters = singles.map({ Filter(words: [$0], isPositive: true) }) +
    ands.map({ Filter(words: $0, isPositive: true) }) +
    ors.map({ Filter(words: $0, isPositive: false) })
print(filters)
