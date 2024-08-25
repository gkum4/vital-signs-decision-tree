import Foundation

class Node {
    var value: NodeValue?
    
    var childrenAttribute: Attribute?
    var children: [Node]?
    
    init(value: NodeValue?, childrenAttribute: Attribute? = nil, children: [Node]? = nil) {
        self.value = value
        self.childrenAttribute = childrenAttribute
        self.children = children
    }
}
