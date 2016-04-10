//
//  PerfectHandlers.swift
//  PerfectHello
//
//  Created by Alberto on 10/4/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import Foundation

import PerfectLib

// GLOBAL for tests
var todosJson: [[String:Any]] = [ [ "id":1, "content":"Buy food" ], [ "id":2, "content":"Go home" ], [ "id":3, "content":"Eat" ] ]


//public method that is being called by the server framework to initialise your module.
public func PerfectServerModuleInit() {
    
    // Install the built-in routing handler.
    // Using this system is optional and you could install your own system if desired.
    Routing.Handler.registerGlobally()
    
    // Create Routes
    Routing.Routes["GET", ["/", "index.html"] ] = { (_:WebResponse) in return IndexHandler() }
    
    // API Endpoints
    Routing.Routes["GET", "/todos"] = { _ in return TodosHandler() }
    Routing.Routes["GET", "/todo/{id}"] = { _ in return TodoHandler() }
    Routing.Routes["POST", "/todo"] = { _ in return TodoNewHandler() }
    Routing.Routes["DELETE", "/todo/{id}"] = { _ in return TodoDeleteHandler() }
    
    
    // Check the console to see the logical structure of what was installed.
    print("\(Routing.Routes.description)")
}

//Create a handler for index Route
class IndexHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        response.appendBodyString("<html><body><h1>Hello World!</h1></body></html>")
        response.requestCompletedCallback()
    }
}

class TodosHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        do{
            let jsonEncoded = try todosJson.jsonEncodedString()
            
            response.appendBodyString(jsonEncoded)
            response.requestCompletedCallback()
            
        }catch _ {
            print("Error")
        }
        
    }
}


class TodoHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        
        let tid = Int( request.urlVariables["id"]! )
        var rTodo: [String:Any] = ["error":1]
        
        for i in todosJson{
            let aid = i["id"] as! Int!
            
            if tid == aid{
                rTodo = i
                break
            }
        }
        
        do{
            let jsonEncoded = try rTodo.jsonEncodedString()
            
            response.appendBodyString(jsonEncoded)
            response.requestCompletedCallback()
            
        }catch _ {
            print("Error")
        }
    }
}

class TodoNewHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        
        let newTodoContent = request.param("content")

        var newTodo: [String:Any]
        
        
        var lastId = 0
        if todosJson.count > 0
        {
            lastId = todosJson.last!["id"] as! Int
        }
        
        let newId = lastId + 1
        
        newTodo = ["id":newId, "content": newTodoContent]
        todosJson.append(newTodo)
        
        do{
            let jsonEncoded = try newTodo.jsonEncodedString()
            
            response.appendBodyString(jsonEncoded)
            response.requestCompletedCallback()
            
        }catch _ {
            print("Error")
        }
    }
}


class TodoDeleteHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        let tid = Int( request.urlVariables["id"]! )
        var rTodo: [String:Any] = ["error":1]
        
        var k = 0
        for i in todosJson{
            print(i["id"])
            let aid = i["id"] as! Int!
            
            if tid == aid{
                rTodo = i
                todosJson.removeAtIndex(k)
                break
            }
            k = k + 1
        }
        
        do{
            let jsonEncoded = try rTodo.jsonEncodedString()
            
            response.appendBodyString(jsonEncoded)
            response.requestCompletedCallback()
            
        }catch _ {
            print("Error")
        }
        
    }
}
