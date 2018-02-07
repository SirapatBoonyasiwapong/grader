import Vapor

final class ProtectedRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        let profileController = ProfileController(view)
        builder.get("profile", handler: profileController.profile)
        builder.get("edit", handler: profileController.editForm)
        builder.post("edit", handler: profileController.edit)
        builder.get("logout", handler: profileController.logout)
        
        let problemsController = ProblemsController(view)
        builder.get("events", Event.parameter, "problems", handler: problemsController.problems)
        builder.get("events", Event.parameter, "submissions", handler: problemsController.submissions)
        builder.get("events", Event.parameter, "scores", handler: problemsController.scores)
        
        builder.get("events", Event.parameter, "problems", Int.parameter, handler: problemsController.form)
        builder.post("events", Event.parameter, "problems", Int.parameter, handler: problemsController.submit)
        
        let loginController = LoginController(view)
        builder.get("changepassword", handler: loginController.changePasswordForm)
        builder.post("changepassword", handler: loginController.changePassword)
        
        let classesController = ClassesController(view)
        builder.get("classes", Group.parameter, "events", handler: classesController.showClassEvents)
        builder.get("classes", Group.parameter, "join", handler: classesController.joinClassForm)
        builder.post("classes", Group.parameter, "join", handler: classesController.joinClass)
        builder.get("classes", Group.parameter, "ranking", handler: classesController.showClassRanking)
        
        let joinClassController = JoinClassController(view)
        builder.get("classes", Group.parameter, Event.parameter, "ranking", handler: joinClassController.rankingClass)
        
        let adminController = AdminController(view)
        builder.get("users", "student", handler: adminController.showStudent)
        builder.get("users", "student", User.parameter, "delete", handler: adminController.deleteStudent)
        builder.get("users", "teacher", handler: adminController.showTeacher)
        builder.get("users", "teacher", User.parameter, "delete", handler: adminController.deleteTeacher)   
        
        
    }
}

