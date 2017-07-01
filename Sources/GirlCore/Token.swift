/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

enum Token {
    case plainText(string: String)
    case beginTag(name: String, attributes: [Attribute])
    case endTag(name: String)
}

let spaces: Parser<String> = {
    let space = one(of: [
        character(" "),
        character("\0"),
        character("\t"),
        character("\r"),
        character("\n"),
        ]
    )
    let spaceString = map(space) { String($0) }
    return map(many(or(spaceString, word("\r\n")))) { $0.joined() }
}()

let plainText: Parser<Token> = {
    let letter = satisfy({ ($0 != "<") && ($0 != ">") })
    let string = map(many1(letter)) { String($0) }
    return map(string) { .plainText(string: $0) }
}()

let tag: Parser<Token> = {
    let letter = satisfy({ ($0 != "<") && ($0 != ">") && ($0 != "=") })
    let string = map(many1(letter)) { String($0) }
    let condition: (Character) -> Bool = {
        let a: Bool = ($0 != "<")
        let b: Bool = ($0 != ">")
        let c: Bool = ($0 != "=")
        let d: Bool = ($0 != " ")
        return a && b && c && d
    }
    let letterNoSpace = satisfy(condition)
    let stringNoSpace = map(many1(letterNoSpace)) { String($0) }
    let keyValue = and(eatRight(string, word("=")), stringNoSpace)
    let attribute = map(keyValue) { (arg: (String, String)) -> Attribute in
        let (key, value) = arg
        return Attribute(key, value)
    }
    let attributes = list(attribute, spaces)
    let info = between(
        word("<"),
        and(eatRight(stringNoSpace, spaces), optional(attributes)),
        eatRight(word(">"), spaces)
    )
    return map(info) { arg in
        let (name, attributes) = arg
        if name.hasPrefix("/") {
            return .endTag(name: String(name.dropFirst(1)))
        } else {
            return .beginTag(name: name, attributes: attributes ?? [])
        }
    }
}()

func tokenize(_ htmlString: String) -> [Token] {
    var tokens: [Token] = []
    var remainder = htmlString.characters
    let parsers = [
        plainText,
        tag
    ]
    while true {
        guard !remainder.isEmpty else { break }
        let remainderLength = remainder.count
        for parser in parsers {
            if let (token, newRemainder) = parser(remainder) {
                tokens.append(token)
                remainder = newRemainder
            }
        }
        let newRemainderLength = remainder.count
        guard newRemainderLength < remainderLength else {
            fatalError("Can not be consumed!")
        }
    }
    return tokens
}
