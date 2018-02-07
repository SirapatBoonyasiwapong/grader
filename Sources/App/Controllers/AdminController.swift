import Vapor
import AuthProvider

public final class AdminController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Show users: Student
    func showStudent(request: Request) throws -> ResponseRepresentable {

        let users = try User.makeQuery().filter("role", Role.student.rawValue).all()
        return try render("Admin/students", ["users": users], for: request, with: view)
    }
    
    //Get Delete student
    func deleteStudent(request: Request) throws -> ResponseRepresentable {
        
        let users = try request.parameters.next(User.self)
        try User.makeQuery().filter("id", users.id!).delete()
        
        return Response(redirect: "/users/student")
    }
    
    //Show users: Teacher
    func showTeacher(request: Request) throws -> ResponseRepresentable {

        let users = try User.makeQuery().filter("role", Role.teacher.rawValue).all()
        return try render("Admin/teachers", ["users": users], for: request, with: view)
    }

    //Get Delete teacher
    func deleteTeacher(request: Request) throws -> ResponseRepresentable {

        let user = try request.parameters.next(User.self)
        try User.makeQuery().filter("id", user.id!).delete()
        
        return Response(redirect: "/users/teacher")
    }
    
}
