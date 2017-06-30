/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

enum Token {
    case plainText(string: String)
    case beginTag(name: String)
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
    let letter = satisfy({ $0 != "<" && $0 != ">" })
    let string = map(many1(letter)) { String($0) }
    return map(string) { .plainText(string: $0) }
}()

let tag: Parser<Token> = {
    let letter = satisfy({ $0 != "<" && $0 != ">" })
    let string = map(many1(letter)) { String($0) }
    let name = between(word("<"), string, eatRight(word(">"), spaces))
    return map(name) {
        if $0.hasPrefix("/") {
            return .endTag(name: String($0.dropFirst(1)))
        } else {
            return .beginTag(name: $0)
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
            break
        }
    }
    return tokens
}
