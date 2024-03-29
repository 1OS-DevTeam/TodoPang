//
//  TodoDTO.swift
//  teamplan
//
//  Created by 주찬혁 on 1/3/24.
//  Copyright © 2024 team1os. All rights reserved.
//

import Foundation

//============================
// MARK: Set
//============================
struct TodoSetDTO{
    
    //--------------------
    // content
    //--------------------
    let todoId: Int
    let projectId: Int
    let userId: String
    let todoDesc: String
    
    //--------------------
    // constructor
    //--------------------
    init(projectId: Int, todoId: Int, userId: String, desc: String){
        self.projectId = projectId
        self.todoId = todoId
        self.userId = userId
        self.todoDesc = desc
    }
}

//============================
// MARK: Get & Delete
//============================
/// Page Service => Storage Service
struct TodoRequestDTO{
    
    //--------------------
    // content
    //--------------------
    let projectId: Int
    let userId: String
    var todoId: Int?
    
    //--------------------
    // constructor
    //--------------------
    init(projectId: Int, userId: String,
         todoId: Int? = nil
    ){
        self.projectId = projectId
        self.todoId = todoId
        self.userId = userId
    }
}

//============================
// MARK: Update - Project
//============================
struct TodoUpdateDTO{
    
    //--------------------
    // content
    //--------------------
    let projectId: Int
    let todoId: Int
    let userId: String
    
    var newDesc: String?
    var newStatus: Bool?
    var newPinned: Bool?
    
    var registedAt: Date?
    var changedAt: Date?
    var updatedAt: Date?
    
    //--------------------
    // constructor
    //--------------------
    // ProjectDetail: Update Desc
    init(projectId: Int, todoId: Int, userId: String,
         newDesc: String? = nil,
         newStatus: Bool? = nil,
         newPinned: Bool? = nil,
         registedAt: Date? = nil,
         changedAt: Date? = nil,
         updatedAt: Date? = nil )
    {
        self.projectId = projectId
        self.todoId = todoId
        self.userId = userId
        self.newDesc = newDesc
        self.newStatus = newStatus
        self.newPinned = newPinned
        self.registedAt = registedAt
        self.changedAt = changedAt
        self.updatedAt = updatedAt
    }
}




//============================
// MARK: toViewModel
//============================
struct TodoListDTO{
    
    //--------------------
    // Content
    //--------------------
    let todoId: Int
    let desc: String

    let pinned: Bool
    let status: Bool
    
    //--------------------
    // Constructor
    //--------------------
    init(with object: TodoObject){
        self.todoId = object.todo_id
        self.desc = object.todo_desc
        self.pinned = object.todo_pinned
        self.status = object.todo_status
    }
}
