import Vapor
import AuthProvider

public final class AdminController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Show users: Student
    func showStudent(request: Request) throws -> ResponseRepresentable {

        let users = try User.makeQuery().filter("role", request.user!.role != .student).all()
        return try render("Admin/students", ["users": users], for: request, with: view)
    }
    
    //Show users: Teacher
    func showTeacher(request: Request) throws -> ResponseRepresentable {

        let users = try User.makeQuery().filter("role", .notEquals, request.user!.role != .student).all()
        return try render("Admin/teachers", ["users": users], for: request, with: view)
    }
    
    //Get Delete student
    func deleteStudent(request: Request) throws -> ResponseRepresentable {
        
        let users = try request.parameters.next(User.self)
        try User.makeQuery().filter("id", users.id!).delete()
        
        return Response(redirect: "/users/student")
    }

    //Get Delete teacher
    func deleteTeacher(request: Request) throws -> ResponseRepresentable {

        let user = try request.parameters.next(User.self)
        try User.makeQuery().filter("id", user.id!).delete()
        
        return Response(redirect: "/users/teacher")
    }
    
}
