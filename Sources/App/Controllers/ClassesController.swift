import Foundation
import Vapor
import AuthProvider

public final class ClassesController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Show class
    func showClasses(request: Request) throws -> ResponseRepresentable {
        if request.user != nil {
            let myClasses: [Group]
            let otherClasses: [Group]
            if request.user!.role == .student {
                myClasses = try Group.makeQuery().join(GroupUser.self, baseKey: "id", joinedKey: "group_id").filter(GroupUser.self, "user_id", request.user!.id!).all()
                if myClasses.count == 0 {
                    otherClasses = try Group.all()
                }
                else {
                    let myClassIDs = myClasses.map { $0.id! }
                    otherClasses = try Group.makeQuery().filter("id", notIn: myClassIDs).all()
                }
            }
            else {
                myClasses = try Group.makeQuery().filter("ownerID", request.user!.id!).all()
                otherClasses = try Group.makeQuery().filter("ownerID", .notEquals, request.user!.id!).all()
            }
            return try render("Classes/classes", ["myClasses": myClasses, "classes": otherClasses], for: request, with: view)
        }
        else {
            let classes = try Group.all()
            return try render("Classes/classes", ["classes": classes], for: request, with: view)
        }

    }
    
    //GET Create class
    func createClassForm(request: Request) throws -> ResponseRepresentable {
        return try render("Classes/class-new", [:], for: request, with: view)

    } 
    
    //POST Create class
    func classForm(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string,
              let imageClass = request.formData?["image"] else{
                throw Abort.badRequest
        }
        let classes = Group(name: name, ownerID: request.user!.id!)
        try classes.save()
        
        let path = "\(uploadPath)\(classes.id!.string!).jpg"
        _ = save(bytes: imageClass.bytes!, path: path)
        
        return Response(redirect: "/")
    }
    
    //GET Show all the events for a class
    func showClassEvents(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Group.self)
        let classUser = try GroupUser.makeQuery().filter("user_id", request.user!.id!)
            .filter("group_id", classObj.id!).first()
        
        if request.user!.role == .student && (classUser == nil || classUser?.status == "Waiting") {
            return Response(redirect: "/classes/\(classObj.id!.string!)/join")
        }
        
        let events = try Event.makeQuery().join(GroupEvent.self, baseKey: "id", joinedKey: "event_id").filter(GroupEvent.self, "group_id", classObj.id!).all()
        
        return try render("Classes/events", ["class": classObj, "events": events], for: request, with: view)
    }
    
    //GET Show all the students in the class
    func showClassUsers(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Group.self)
        
        let classUser = try GroupUser.makeQuery().filter("user_id", request.user!.id!)
            .filter("group_id", classObj.id!).first()
        
        return try render("Classes/join-class", ["class": classObj, "classUser": classUser], for: request, with: view)
    }
    
    //GET OtherClass
    func joinClassForm(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Group.self)
        let classUserObj = try GroupUser.makeQuery().filter("group_id", classObj.id!).filter("user_id", request.user!.id!).first()
        return try render("Classes/join-class", ["class": classObj, "classUser": classUserObj], for: request, with: view)
    }
    
    //POST Join class when student don't join class (OtherClasses)
    func joinClass(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Group.self)

        let classUserObj = GroupUser(groupID: classObj.id!, userID: request.user!.id!, status: "Waiting")
        try classUserObj.save()
        
        return Response(redirect: "/classes/\(classObj.id!.string!)/join")

    }
    
    //GET Show all the events for a class
    func showClassRanking(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Group.self)
        
        guard let user = request.user, classObj.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        let scores = try User.database!.raw("SELECT x.user_id, u.name, SUM(x.score) score, SUM(x.attempts) attempts, COUNT(1) problems FROM users u JOIN (SELECT s.user_id, s.event_problem_id, MAX(s.score) score, COUNT(1) attempts FROM submissions s JOIN event_problems ep ON s.event_problem_id = ep.id JOIN events e ON ep.event_id = e.id JOIN group_events ge ON e.id = ge.event_id WHERE ge.group_id = ? AND (s.created_at > e.starts_at OR e.starts_at IS NULL) AND (s.created_at < e.ends_at OR e.ends_at IS NULL) AND (s.language = e.language_restriction OR e.language_restriction IS NULL) GROUP BY s.user_id, event_problem_id) x ON u.id = x.user_id WHERE u.role = 1 GROUP BY x.user_id, u.name ORDER BY score DESC, attempts ASC, problems DESC", [classObj.id!])
        
        return try render("Classes/class-ranking", ["class": classObj, "scores": scores], for: request, with: view)
    }
    
    //GET Delete a class
    func deleteClass(request: Request) throws -> ResponseRepresentable {
        let group = try request.parameters.next(Group.self)
        
        try GroupUser.makeQuery().filter("group_id", group.id!).delete()
        try GroupEvent.makeQuery().filter("group_id", group.id!).delete()
        try Group.makeQuery().filter("id", group.id!).delete()
        return Response(redirect: "/classes")
    }
    
    //GET Create new event in class
    func createEvent(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Group.self)
        return try render("Classes/event-new", ["class": classObj], for: request, with: view)
    }
    
    //POST Submit event in class
    func submitEvent(request: Request) throws -> ResponseRepresentable {
        let group = try request.parameters.next(Group.self)
        
        guard
            let userId = request.user?.id,
            let name = request.data["name"]?.string,
            let imageEvent = request.formData?["image"]
            else {
                throw Abort.badRequest
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let startsAt = request.data["starts_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["starts_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }
        
        let endsAt = request.data["ends_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["ends_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }
        
        let languageRestriction = request.data["language_restriction"]?.string.flatMap { raw in Language(rawValue: raw) }

        let event = Event(
            name: name,
            userID: userId,
            startsAt: startsAt,
            endsAt: endsAt,
            languageRestriction: languageRestriction
        )
        try event.save()
        
        let groupEvent = GroupEvent(groupID: group.id!, eventID: event.id!)
        try groupEvent.save()
        
        let path = "\(uploadPath)\(event.id!.string!).jpg"
        _ = save(bytes: imageEvent.bytes!, path: path)

        return Response(redirect: "/classes/\(group.id!.string!)/events")
    }
}


