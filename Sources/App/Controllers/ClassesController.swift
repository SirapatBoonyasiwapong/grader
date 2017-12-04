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
        
        let classUser = try ClassUser.makeQuery().filter("user_id", request.user!.id!)
            .filter("class_id", classObj.id!).first()
        
        return try render("Classes/join-class", ["class": classObj, "classUser": classUser], for: request, with: view)

    }
    
    //GET Joine class status waiting
    func joinClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        
        let classUserObj = ClassUser(classID: classObj.id!, userID: request.user!.id!, status: "Waiting")
        try classUserObj.save()
        
        return Response(redirect: "/classes/\(classObj.id!.string!)")
        
    }
}


