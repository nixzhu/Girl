/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

typealias Stream = String.CharacterView
typealias Parser<A> = (Stream) -> (A, Stream)?

func character(_ character: Character) -> Parser<Character> {
    return { stream in
        guard let firstCharacter = stream.first, firstCharacter == character else { return nil }
        return (firstCharacter, stream.dropFirst())
    }
}

func word(_ string: String) -> Parser<String> {
    let parsers = string.characters.map({ character($0) })
    return { stream in
        var characters: [Character] = []
        var remainder = stream
        for parser in parsers {
            guard let (character, newRemainder) = parser(remainder) else { return nil }
            characters.append(character)
            remainder = newRemainder
        }
        return (String(characters), remainder)
    }
}

func satisfy(_ condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return { stream in
        guard let firstCharacter = stream.first, condition(firstCharacter) else { return nil }
        return (firstCharacter, stream.dropFirst())
    }
}

func many<A>(_ parser: @escaping Parser<A>) -> Parser<[A]> {
    return { stream in
        var result = [A]()
        var remainder = stream
        while let (element, newRemainder) = parser(remainder) {
            result.append(element)
            if remainder.count == newRemainder.count {
                break
            }
            remainder = newRemainder
        }
        return (result, remainder)
    }
}

func many1<A>(_ parser: @escaping Parser<A>) -> Parser<[A]> {
    return { stream in
        guard let (element, remainder1) = parser(stream) else { return nil }
        if let (array, remainder2) = many(parser)(remainder1) {
            return ([element] + array, remainder2)
        } else {
            return ([element], remainder1)
        }
    }
}

func map<A, B>(_ parser: @escaping Parser<A>, _ transform: @escaping (A) -> B) -> Parser<B> {
    return { stream in
        guard let (result, remainder) = parser(stream) else { return nil }
        return (transform(result), remainder)
    }
}

func optional<A>(_ parser: @escaping Parser<A>) -> Parser<A?> {
    return { stream in
        if let (result, remainder) = parser(stream) {
            return (result, remainder)
        } else {
            return (nil, stream)
        }
    }
}

func one<A>(of parsers: [Parser<A>]) -> Parser<A> {
    return { stream in
        for parser in parsers {
            if let x = parser(stream) {
                return x
            }
        }
        return nil
    }
}

func and<A, B>(_ left: @escaping Parser<A>, _ right: @escaping Parser<B>) -> Parser<(A, B)> {
    return { stream in
        guard let (result1, remainder1) = left(stream) else { return nil }
        guard let (result2, remainder2) = right(remainder1) else { return nil }
        return ((result1, result2), remainder2)
    }
}

func or<A>(_ leftParser: @escaping Parser<A>, _ rightParser: @escaping Parser<A>) -> Parser<A> {
    return { stream in
        return leftParser(stream) ?? rightParser(stream)
    }
}

func between<A, B, C>(_ a: @escaping Parser<A>, _ b: @escaping Parser<B>, _ c: @escaping Parser<C>) -> Parser<B> {
    return { stream in
        guard let (_, remainder1) = a(stream) else { return nil }
        guard let (result2, remainder2) = b(remainder1) else { return nil }
        guard let (_, remainder3) = c(remainder2) else { return nil }
        return (result2, remainder3)
    }
}

func eatLeft<A, B>(_ left: @escaping Parser<A>, _ right: @escaping Parser<B>) -> Parser<B> {
    return { stream in
        guard let (_, remainder1) = left(stream) else { return nil }
        guard let (result2, remainder2) = right(remainder1) else { return nil }
        return (result2, remainder2)
    }
}

func eatRight<A, B>(_ left: @escaping Parser<A>, _ right: @escaping Parser<B>) -> Parser<A> {
    return { stream in
        guard let (result1, remainder1) = left(stream) else { return nil }
        guard let (_, remainder2) = right(remainder1) else { return nil }
        return (result1, remainder2)
    }
}

func list<A, B>(_ parser: @escaping Parser<A>, _ separator: @escaping Parser<B>) -> Parser<[A]> {
    return { stream in
        let separatorThenParser = and(separator, parser)
        let parser = and(parser, many(separatorThenParser))
        guard let (result, remainder) = parser(stream) else { return nil }
        let finalResult = [result.0] + result.1.map({ $0.1 })
        return (finalResult, remainder)
    }
}

