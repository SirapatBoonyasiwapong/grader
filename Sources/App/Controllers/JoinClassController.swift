import Vapor
import AuthProvider

public final class JoinClassController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
 
    //GET Join in class Teacher
    func showUserInClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        let classUsers = try ClassUser.makeQuery().filter("class_id", classObj.id!).all()
        
        return try render("Classes/join-in-class", ["class": classObj, "classUsers": classUsers], for: request, with: view)
    }
    
    //GET Accept user
    func acceptUser(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        let user = try request.parameters.next(User.self)
        
        if let classUser = try ClassUser.makeQuery().filter("class_id", classObj.id!).filter("user_id", user.id!).first() {
            classUser.status = "Joined"
            try classUser.save()
        }
        
        return Response(redirect:"/classes/\(classObj.id!.string!)")
        
    }
    
    //Get Delete user
    func deleteUser(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        let user = try request.parameters.next(User.self)
        
        try ClassUser.makeQuery().filter("class_id", classObj.id!).filter("user_id", user.id!).delete()
        
        return Response(redirect: "/classes/\(classObj.id!.string!)")
    }
    
}


