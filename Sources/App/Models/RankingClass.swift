import Foundation
import FluentProvider

final class RankingClass: Model, NodeRepresentable {
    
    var classID: Identifier
    var classUserID: Identifier
    var submissionID: Identifier
    var eventProblemID: Identifier
    var userID: Identifier
    var score: Int
    
    var classroom: Parent<RankingClass, Class> {
        return parent(id: classID)
    }
    
    var classUser: Parent<RankingClass, ClassUser> {
        return parent(id: classUserID)
    }
    
    var submission: Parent<RankingClass, Submission> {
        return parent(id: submissionID)
    }
    
    var eventProblem: Parent<RankingClass, EventProblem> {
        return parent(id: eventProblemID)
    }
    
    var user: Parent<RankingClass, User> {
        return parent(id: userID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        classID = try row.get("class_id")
        classUserID = try row.get("class_user_id")
        submissionID = try row.get("submission_id")
        eventProblemID = try row.get("event_problem_id")
        userID = try row.get("user_id")
        score = try row.get("score")
        
    }
    
    init(classID: Identifier, classUserID: Identifier, submissionID: Identifier, eventProblemID: Identifier, userID: Identifier, score: Int) {
        self.classID = classID
        self.classUserID = classUserID
        self.submissionID = submissionID
        self.eventProblemID = eventProblemID
        self.userID = userID
        self.score = score
        
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("class_id", classID)
        try row.set("class_user_id", classUserID)
        try row.set("submission_id", submissionID)
        try row.set("event_problem_id", eventProblemID)
        try row.set("user_id", userID)
        try row.set("score", score)
        
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let user = try self.user.get()
        return try Node(node: [
            "id": id!.string!,
            "classID": classID,
            "classUserID": classUserID,
            "submissionID": submissionID,
            "eventProblemID": eventProblemID,
            "userID": userID,
            "score": score,
            "user": user.makeNode(in: context)])
    }
}

