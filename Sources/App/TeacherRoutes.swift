import Vapor

final class TeacherRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
                
        let eventsController = EventsController(view)
        let problemsController = ProblemsController(view)
        let submissionsController = SubmissionsController(view)
        let userController = UsersController(view)
        let loginController = LoginController(view)
        let classesController = ClassesController(view)
        let joinClassController = JoinClassController(view)
        
        builder.get("events/new", handler: eventsController.eventNew)
        builder.post("events/new", handler: eventsController.eventNewSubmit)
        
        builder.get("events", Event.parameter, "problems/new", handler: eventsController.eventProblemNew)
        builder.post("events", Event.parameter, "problems/new", handler: eventsController.eventProblemNewSubmit)
        
        builder.get("events", Event.parameter, "problems", ":eventProblemSeq", "edit", handler: eventsController.eventProblemEdit)
        builder.post("events", Event.parameter, "problems", ":eventProblemSeq", "edit", handler: eventsController.eventProblemNewSubmit)
        
        builder.get("problems", Problem.parameter, "cases/new", handler: problemsController.problemCaseNew)
        builder.post("problems", Problem.parameter, "cases/new", handler: problemsController.problemCaseNewSubmit)
        
        builder.post("submissions", Submission.parameter, "run", handler: submissionsController.manualRun)
        
        builder.get("users", handler: userController.showUser)
        builder.get("users", Int.parameter, "edit", handler: userController.editForm)
        builder.post("users", Int.parameter, "edit", handler: userController.edit)
        builder.get("users", Int.parameter,"delete", handler: userController.deleteForm)
        builder.post("users", Int.parameter,"delete", handler: userController.delete)
        
        builder.get("events", Event.parameter, "edit", handler: eventsController.eventEditForm)
        builder.post("events", Event.parameter, "edit", handler: eventsController.eventEdit)
        
        builder.get("users",Int.parameter, "changepassword", handler: loginController.changePassword)
        
        builder.get("classes", "create", handler: classesController.createClassForm)
        builder.post("classes", "create", handler: classesController.classForm)
        
      
        
      //  builder.get("classes", Class.parameter, "join", handler: joinClassController.studentJoin)
    }
}
