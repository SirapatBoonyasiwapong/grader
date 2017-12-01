import Vapor
import AuthProvider

public final class JoinClassController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
 
    //GET Join in class Teacher
    func acceptUser(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Class.self)
        
        let classUserObj = ClassUser(classID: classObj.id!, userID: request.user!.id!, status: "Joined")
        try classUserObj.save()

        return Response(redirect: "/classes/#(class.id)/join")
        
    }
    
    func cancelUser(request: Request) throws -> ResponseRepresentable {
        let classObj = try request.parameters.next(Class.self)
        
       // try classObj.dalete()
        
        return Response(redirect: "/classes")
    }
    
//    func cancelUser(request: Request) throws -> ResponseRepresentable {
//        let userID = try request.parameters.next(Int.self)
//        if let user = try Class.find(userID){
//            try user.delete()
//        }
//        
//        return Response(redirect: "/classes/#(class.id)/join")
//    }

//    
//    func form(request: Request) throws -> ResponseRepresentable {
//        let classroom = try request.parameters.next(Class.self)
//        let sequence = try request.parameters.next(Int.self)
//        
//        guard let user = request.user, classroom.isVisible(to: user) else {
//            throw Abort.unauthorized
//        }
//        
//        guard let classUser = try classroom.classUser.filter("sequence", sequence) else {
//            throw Abort.notFound
//        }
//        
//        return try render("Classes/",[ "classroom": classroom, "classUser": classUser, "user": user], for: request, with: view)
//
//    }
   
//    func submitStudent(request: Request) throws -> ResponseRepresentable {
//        let classroom = try request.parameters.next(ClassUser.self)
//        let sequence = try request.parameters.next(Int.self)
//        
//        guard let user = request.user, classroom.isVisible(to: user) else {
//            throw Abort.unauthorized
//        }
//        
//        guard let classUser = try classroom.classUser.filter("sequence", sequence).first() else {
//            throw Abort.notFound
//        }
//        
//        let joinClass = JoinClass(classUserID: classUser.id!, userID: user.id!)
//        try joinClass.save()
//        
//        return try render("Classes/", [:], for: request, with: view)
//        
//        //ถ้ากดรับแล้ว ให้แสดงคำว่า joined
//        //if accept 
//    }
    
    }


