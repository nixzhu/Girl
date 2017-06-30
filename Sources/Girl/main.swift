/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

import GirlCore

let htmlString = """
    <p>I'm NIX</p>
    <div>
        <div>
            <p>Hello</p>
            <p>World</p>
        </div>
    </div>
    """
print("")
print(htmlString)
print("")
let node = parse(htmlString)
print(node)
print("")
print(render(node: node))
print("")
