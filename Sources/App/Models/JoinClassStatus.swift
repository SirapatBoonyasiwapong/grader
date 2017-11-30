import Node

enum JoinClassStatus: Int {
    
    case joined = 0
    case waiting = 1
    
    var string: String {
        switch self {
        case .joined:
            return "Joined"
        case .waiting:
            return "Waiting"
        }
    }
    
}

extension JoinClassStatus: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        return Node(self.hashValue)
    }
}
