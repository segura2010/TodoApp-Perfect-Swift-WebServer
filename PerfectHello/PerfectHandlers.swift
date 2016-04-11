//
//  PerfectHandlers.swift
//  PerfectHello
//
//  Created by Alberto on 10/4/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import Foundation

import PerfectLib
import MongoDB

let MONGODB_URL = "mongodb://localhost:27017"
let DB_NAME = "todoswift"
let COLLECTION_NAME = "todos"

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
    
    do{
        var mongoClient = try MongoClient(uri: MONGODB_URL)
        var todoDB = mongoClient.getDatabase(DB_NAME)
        var todosCollection = todoDB.getCollection(COLLECTION_NAME)
    }catch{
        print("Error MongoDB")
    }
    
    /* MongoDB checks
    let status = mongoClient.serverStatus()
    switch status {
    case .Error(let domain, let code, let message):
        print("Error: \(domain) \(code) \(message)")
    case .ReplyDoc(let doc):
        print("Status doc: \(doc)")
    default:
        print("Strange reply type \(status)")
    }
    */
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
            //let jsonEncoded = try todosJson.jsonEncodedString()
            //var todosJson2 = [String]()
            
            // Conect
            var mongoClient = try MongoClient(uri: MONGODB_URL)
            var todoDB = mongoClient.getDatabase(DB_NAME)
            var todosCollection = todoDB.getCollection(COLLECTION_NAME)
            
            var mongoTodos = try todosCollection.find(BSON(json:"{}"))
            var todo = mongoTodos!.next()
            var todosJson2 = [BSON]()
            while todo != nil{
                print(todo)
                todosJson2.append( BSON(document:todo!) )
                todo = mongoTodos!.next()
            }
            
            let jsonEncoded = todosJson2.description
            response.appendBodyString(jsonEncoded)
            response.requestCompletedCallback()
            
        }catch _ {
            response.appendBodyString("[]")
            response.requestCompletedCallback()
            
            print("Error")
        }
        
    }
}


class TodoHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        
        let tid = request.urlVariables["id"]!
        
        do{
            // Conect
            var mongoClient = try MongoClient(uri: MONGODB_URL)
            var todoDB = mongoClient.getDatabase(DB_NAME)
            var todosCollection = todoDB.getCollection(COLLECTION_NAME)
            
            var mongoTodos = try todosCollection.find(BSON(json:"{\"_id\":{ \"$oid\" : \"\(tid)\" }}"))
            var todo = mongoTodos!.next()
            var todosJson2 = [BSON]()
            while todo != nil{
                //print(todo)
                todosJson2.append( todo! )
                todo = mongoTodos!.next()
            }
            
            let jsonEncoded = todosJson2.description
            response.appendBodyString(jsonEncoded)
            response.requestCompletedCallback()
            
        }catch _ {
            response.appendBodyString("[]")
            response.requestCompletedCallback()
            
            print("Error")
        }
    }
}

class TodoNewHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        
        let newTodoContent = request.param("content")

        var newTodo: [String:Any]
        
        newTodo = ["content": newTodoContent]
        
        do{
            let jsonEncoded = try newTodo.jsonEncodedString()
            
            // Conect
            var mongoClient = try MongoClient(uri: MONGODB_URL)
            var todoDB = mongoClient.getDatabase(DB_NAME)
            var todosCollection = todoDB.getCollection(COLLECTION_NAME)
            
            // Save
            let bson = try BSON(json:jsonEncoded)
            todosCollection.save(bson)
            
            response.appendBodyString(bson.asString)
            response.requestCompletedCallback()
            
        }catch _ {
            response.appendBodyString("[]")
            response.requestCompletedCallback()
            
            print("Error")
        }
    }
}


class TodoDeleteHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        let tid = request.urlVariables["id"]!
        var rTodo: [String:Any] = ["error":1]
        
        do{
            // Conect
            var mongoClient = try MongoClient(uri: MONGODB_URL)
            var todoDB = mongoClient.getDatabase(DB_NAME)
            var todosCollection = todoDB.getCollection(COLLECTION_NAME)
            
            var mongoTodos = try todosCollection.remove(BSON(json: "{\"_id\":{ \"$oid\" : \"\(tid)\" }}"))
            
            response.appendBodyString("{\"success\":true}")
            response.requestCompletedCallback()
            
        }catch _ {
            response.appendBodyString("{\"success\":false}")
            response.requestCompletedCallback()
            
            print("Error")
        }
        
    }
}
