import Foundation
import FluentProvider

final class JoinClass: Model, NodeRepresentable {
    
   
    var classUserID: Identifier
    var userID: Identifier
    var joinClassStatus: JoinClassStatus
    
    var classUser: Parent<JoinClass, ClassUser> {
        return parent(id: classUserID)
    }
    
    var user: Parent<JoinClass, User> {
        return parent(id: userID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        classUserID = try row.get("class_user_id")
        userID = try row.get("user_id")
        joinClassStatus = JoinClassStatus(rawValue: try row.get("joinClassStatus"))!
       
    }
    
    init(classUserID: Identifier, userID: Identifier, joinClassStatus: JoinClassStatus = .joined ) {
        self.classUserID = classUserID
        self.userID = userID
        self.joinClassStatus = joinClassStatus

    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("class_user_id", classUserID)
        try row.set("user_id", userID)
        try row.set("joinClassStatus", joinClassStatus.rawValue)

        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "classUserID": classUserID,
            "userID": userID,
            "joinClassStatus": joinClassStatus ])
        
    }
}

