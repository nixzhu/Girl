/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

public struct Attribute {
    public let key: String
    public let value: String

    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
}

public struct Element {
    public let name: String
    public let attributes: [Attribute]
    public let children: [Node]

    public init(_ name: String, _ attributes: [Attribute], _ children: [Node]) {
        self.name = name
        self.attributes = attributes
        self.children = children
    }
}

public enum Node {
    case element(Element)
    case text(String)
}

public func render(node: Node) -> String {
    switch node {
    case let .element(e):
        return render(element: e)
    case let .text(t):
        return t
    }
}

public func render(element: Element) -> String {
    let openTag = "<\(element.name)"
    let openTagWithAttrs = openTag
        + (element.attributes.isEmpty ? "" : " ")
        + render(attributes: element.attributes)
        + ">"
    let children = element.children.map(render(node:)).joined()
    let closeTag = "</\(element.name)>"

    return openTagWithAttrs + children + closeTag
}

public func render(attributes: [Attribute]) -> String {
    return attributes
        .map { attr in "\(attr.key)=\"\(attr.value)\"" }
        .joined(separator: " ")
}
