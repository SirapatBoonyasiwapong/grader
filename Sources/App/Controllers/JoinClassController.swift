import Vapor
import AuthProvider

public final class JoinClassController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
 
    //GET Join in class Teacher
    func showUserInClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Group.self)
        let classUsers = try GroupUser.makeQuery().filter("group_id", classObj.id!).all()
        
        return try render("Classes/accept-in-class", ["class": classObj, "classUsers": classUsers], for: request, with: view)
    }
    
    //GET Accept user
    func acceptUser(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Group.self)
        let user = try request.parameters.next(User.self)
        
        if let classUser = try GroupUser.makeQuery().filter("group_id", classObj.id!).filter("user_id", user.id!).first() {
            classUser.status = "Joined"
            try classUser.save()
        }
        
        return Response(redirect:"/classes/\(classObj.id!.string!)/users")
    }
    
    //Get Delete user
    func deleteUser(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Group.self)
        let user = try request.parameters.next(User.self)
        
        try GroupUser.makeQuery().filter("group_id", classObj.id!).filter("user_id", user.id!).delete()
        
        return Response(redirect: "/classes/\(classObj.id!.string!)/users")
    }
    
    //scores in class
    func rankingClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Group.self)
        let event = try request.parameters.next(Event.self)
        
        guard let user = request.user, classObj.isVisible(to: user), event.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        let scores = try User.database!.raw("SELECT x.user_id, u.name, SUM(x.score) score, SUM(x.attempts) attempts, COUNT(1) problems FROM users u JOIN (SELECT s.user_id, s.event_problem_id, MAX(s.score) score, COUNT(1) attempts FROM submissions s JOIN group_users cu ON cu.user_id = s.user_id JOIN groups c ON cu.group_id = c.id JOIN event_problems ep ON s.event_problem_id = ep.id JOIN events e ON ep.event_id = e.id WHERE cu.group_id = ? AND ep.event_id = ? AND (s.created_at > e.starts_at OR e.starts_at is null) AND (s.created_at < e.ends_at OR e.ends_at is null) AND (s.language = e.language_restriction OR e.language_restriction is null) GROUP BY s.user_id, event_problem_id) x ON u.id = x.user_id WHERE u.role = 1 GROUP BY x.user_id, u.name ORDER BY score DESC, attempts ASC, problems DESC", [classObj.id!, event.id!])
        
        return try render("Classes/class-ranking",["class": classObj, "event": event, "scores": scores], for: request, with: view)
        
    }
}



