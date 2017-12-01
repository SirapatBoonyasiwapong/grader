import Vapor
import AuthProvider

public final class ClassesController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Show class
    func showClasses(request: Request) throws -> ResponseRepresentable {
        let classes = try Class.all()
        return try render("Classes/classes", ["classes": classes], for: request, with: view)

    }
    
    //GET Create class
    func createClassForm(request: Request) throws -> ResponseRepresentable {
        
        return try render("Classes/class-new", [:], for: request, with: view)

    }
    
    //POST Create class
    func classForm(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string
            else{
                throw Abort.badRequest
        }
        
        let classes = Class(name: name, events: "", users: "", ownerID: request.user!.id!)
        try classes.save()
        
        return Response(redirect: "/")
    }
    
    //GET Join in class Student
    func showClass(request: Request) throws -> ResponseRepresentable {

        let classObj = try request.parameters.next(Class.self)
        return try render("Classes/join-class", ["class" : classObj], for: request, with: view)
//        guard let user = request.user, className.isVisible(to: user) else {
//            throw Abort.unauthorized
//        }
//
//        var query = try JoinClass.makeQuery()
//            .join(ClassUser.self, baseKey: "class_user_id", joinedKey: "id")
//            .filter(ClassUser.self, "class_id", className.id).sort("status", .descending).limit(20)
//        
////        if user.role == .student {
////            query = try query.filter(JoinClass.self, "user_id", request.user!.id)
////        }
//        
//        let joinClasses = try query.all()
//        
//        var shouldRefreshPageAutomatically = false
//        
//        var joinedClasses: [Node] = []
//        for joinClass in joinClasses {
//            var joinedClass = try joinClass.makeNode(in: nil)
//            let user = try joinClass.user.get()!
//            let classroom = try joinClass.classUser.get()!.user.get()!
//            joinedClass["className"] = classroom.name.makeNode(in: nil)
//            joinedClass["userName"] = user.name.makeNode(in: nil)
//            joinedClasses.append(joinedClass)
//            
//            if joinClass.joinClassStatus == .joined || joinClass.joinClassStatus == .waiting {
//               shouldRefreshPageAutomatically = true
//            }
//        }
//        return try render("Classes/join-class", ["className": className,
//                                                 "joinedClasses": joinedClasses,
//                                                 "shouldRefresh": shouldRefreshPageAutomatically
//                                                ], for: request, with: view)
    }
    
    func joinClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        
        let classUserObj = ClassUser(classID: classObj.id!, userID: request.user!.id!, status: "Waiting")
        try classUserObj.save()
        
        return Response(redirect: "/classes")
        
    }
}


