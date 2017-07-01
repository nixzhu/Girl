/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

enum Item {
    case token(Token)
    case node(Node)

    var node: Node? {
        switch self {
        case .token(let token):
            switch token {
            case .plainText(let string):
                return .text(string)
            default:
                print("Should not be there!")
                return nil
            }
        case .node(let node):
            return node
        }
    }
}

class Stack {
    var array: [Item] = []

    func push(_ item: Item) {
        array.append(item)
    }

    func pop() -> Item? {
        guard !array.isEmpty else { return nil }
        return array.removeLast()
    }
}

func parse(_ tokens: [Token]) -> Node {
    let stack = Stack()
    var next = 0
    func _parse() -> Bool {
        guard next < tokens.count else {
            return false
        }
        let token = tokens[next]
        switch token {
        case let .plainText(string):
            stack.push(.token(.plainText(string: string)))
        case let .beginTag(name, attributes):
            stack.push(.token(.beginTag(name: name, attributes: attributes)))
        case let .endTag(name):
            var attributes: [Attribute] = []
            var items: [Item] = []
            while let item = stack.pop() {
                if case let .token(token) = item {
                    if case let .beginTag(_name, _attributes) = token, name == _name {
                        attributes = _attributes
                        break
                    }
                }
                items.append(item)
            }
            let children: [Node]
            if items.count == 1 {
                let item = items[0]
                children = item.node.flatMap({ [$0] }) ?? []
            } else {
                children = items.map({ $0.node }).flatMap({ $0 }).reversed()
            }
            stack.push(.node(.element(Element(name, attributes, children))))
        }
        return true
    }
    while true {
        if !_parse() {
            break
        }
        next += 1
    }
    let children = stack.array.map({ $0.node }).flatMap({ $0 })
    if children.count == 1 {
        return children[0]
    } else {
        return .element(Element("Root", [], children))
    }
}

public func parse(_ htmlString: String) -> Node {
    let tokens = tokenize(htmlString)
    return parse(tokens)
}
