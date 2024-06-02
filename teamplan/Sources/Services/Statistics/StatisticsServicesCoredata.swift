//
//  StatisticsServiceCoredata.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/10/10.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import CoreData

final class StatisticsServicesCoredata: FullObjectManage {
    typealias Entity = StatisticsEntity
    typealias Object = StatisticsObject
    typealias DTO = StatUpdateDTO
    
    var context: NSManagedObjectContext
    init(coredataController: CoredataProtocol = CoredataMainController.shared) {
        self.context = coredataController.context
    }
    
    func setObject(with object: Object) throws {
        try createEntity(with: object)
        try self.context.save()
    }
    
    func getObject(with userId: String) throws -> Object {
        let entity = try getEntity(with: userId)
        return try convertToObject(with: entity)
    }
    
    func updateObject(with dto: DTO) throws {
        let entity = try getEntity(with: dto.userId)
        if try checkUpdate(from: entity, to: dto) {
            try self.context.save()
        }
    }
    
    func deleteObject(with userId: String) throws {
        let entity = try getEntity(with: userId)
        self.context.delete(entity)
        try self.context.save()
    }
    
    func isObjectExist(with userId: String) -> Bool {
        let reqeust = getFetchRequest(with: userId)
        do {
            let count = try context.count(for: reqeust)
            return count > 0
        } catch {
            return false
        }
    }
}


// MARK: - Set Extension
extension StatisticsServicesCoredata{
    
    private func createEntity(with object: Object) throws {
        let entity = StatisticsEntity(context: context)
        
        entity.user_id = object.userId
        entity.term = Int32(object.term)
        entity.drop = Int32(object.drop)
        entity.total_registed_projects = Int32(object.totalRegistedProjects)
        entity.total_finished_projects = Int32(object.totalFinishedProjects)
        entity.total_failed_projects = Int32(object.totalFailedProjects)
        entity.total_alerted_projects = Int32(object.totalAlertedProjects)
        entity.total_extended_projects = Int32(object.totalExtendedProjects)
        entity.total_registed_todos = Int32(object.totalRegistedTodos)
        entity.total_finished_todos = Int32(object.totalFinishedTodos)
        entity.challenge_step_status = try Utilities().convertToJSON(data: object.challengeStepStatus)
        entity.mychallenges = try Utilities().convertToJSON(data: object.mychallenges)
        entity.synced_at = object.syncedAt
    }
}


// MARK: - Get Extension
extension StatisticsServicesCoredata {
    
    private func getFetchRequest(with userId: String) -> NSFetchRequest<Entity> {
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: EntityPredicate.stat.format, userId)
        
        return fetchRequest
    }
    
    private func getEntity(with userId: String) throws -> Entity {
        let request = getFetchRequest(with: userId)
        guard let entity = try fetchEntity(with: request, and: self.context) else {
            throw CoredataError.fetchFailure(serviceName: .cd, dataType: .stat)
        }
        return entity
    }
    
    private func convertToObject(with entity: Entity) throws -> Object {
        guard let userId = entity.user_id,
              let challengeStepStatusString = entity.challenge_step_status,
              let myChallengesString = entity.mychallenges 
        else {
            throw CoredataError.convertFailure(serviceName: .cd, dataType: .stat)
        }
        let challengeStepStatus = try Utilities().convertFromJSON(jsonString: challengeStepStatusString, type: [Int: Int].self)
        let myChallenges = try Utilities().convertFromJSON(jsonString: myChallengesString, type: [Int].self)
        
        return StatisticsObject (
            userId: userId,
            term: Int(entity.term),
            drop: Int(entity.drop),
            totalRegistedProjects: Int(entity.total_registed_projects),
            totalFinishedProjects: Int(entity.total_finished_projects),
            totalFailedProjects: Int(entity.total_failed_projects),
            totalAlertedProjects: Int(entity.total_alerted_projects),
            totalExtendedProjects: Int(entity.total_extended_projects),
            totalRegistedTodos: Int(entity.total_registed_todos),
            totalFinishedTodos: Int(entity.total_finished_todos),
            challengeStepStatus: challengeStepStatus,
            mychallenges: myChallenges,
            syncedAt: entity.synced_at ?? Date()
        )
    }
}
    

// MARK: - Update Extension
struct StatUpdateDTO {
    let userId: String
    var newTerm: Int?
    var newDrop: Int?
    var newTotalRegistedProjects: Int?
    var newTotalFinishedProjects: Int?
    var newTotalFailedProjects: Int?
    var newTotalAlertedProjects: Int?
    var newTotalExtendedProjects: Int?
    var newTotalRegistedTodos: Int?
    var newTotalFinishedTodos: Int?
    var newChallengeStepStatus: [Int: Int]?
    var newMyChallenges: [Int]?
    var newSyncedAt: Date?
    
    init(userId: String,
         newTerm: Int? = nil,
         newDrop: Int? = nil,
         newTotalRegistedProjects: Int? = nil,
         newTotalFinishedProjects: Int? = nil,
         newTotalFailedProjects: Int? = nil,
         newTotalAlertedProjects: Int? = nil,
         newTotalExtendedProjects: Int? = nil,
         newTotalRegistedTodos: Int? = nil,
         newTotalFinishedTodos: Int? = nil,
         newChallengeStepStatus: [Int: Int]? = nil,
         newMyChallenges: [Int]? = nil,
         newSyncedAt: Date? = nil) {
        self.userId = userId
        self.newTerm = newTerm
        self.newDrop = newDrop
        self.newTotalRegistedProjects = newTotalRegistedProjects
        self.newTotalFinishedProjects = newTotalFinishedProjects
        self.newTotalFailedProjects = newTotalFailedProjects
        self.newTotalAlertedProjects = newTotalAlertedProjects
        self.newTotalExtendedProjects = newTotalExtendedProjects
        self.newTotalRegistedTodos = newTotalRegistedTodos
        self.newTotalFinishedTodos = newTotalFinishedTodos
        self.newChallengeStepStatus = newChallengeStepStatus
        self.newMyChallenges = newMyChallenges
        self.newSyncedAt = newSyncedAt
    }
}

extension StatisticsServicesCoredata {
    
    private func checkUpdate(from entity: StatisticsEntity, to dto: StatUpdateDTO) throws -> Bool {
        let util = Utilities()
        var isUpdated = false
        
        if let newTerm = dto.newTerm {
            isUpdated = util.updateIfNeeded(&entity.term, newValue: Int32(newTerm)) || isUpdated
        }
        if let newDrop = dto.newDrop {
            isUpdated = util.updateIfNeeded(&entity.drop, newValue: Int32(newDrop)) || isUpdated
        }
        if let newTotalRegistedProjects = dto.newTotalRegistedProjects {
            isUpdated = util.updateIfNeeded(&entity.total_registed_projects, newValue: Int32(newTotalRegistedProjects)) || isUpdated
        }
        if let newTotalFinishedProjects = dto.newTotalFinishedProjects {
            isUpdated = util.updateIfNeeded(&entity.total_finished_projects, newValue: Int32(newTotalFinishedProjects)) || isUpdated
        }
        if let newTotalFailedProjects = dto.newTotalFailedProjects {
            isUpdated = util.updateIfNeeded(&entity.total_failed_projects, newValue: Int32(newTotalFailedProjects)) || isUpdated
        }
        if let newTotalAlertedProjects = dto.newTotalAlertedProjects {
            isUpdated = util.updateIfNeeded(&entity.total_alerted_projects, newValue: Int32(newTotalAlertedProjects)) || isUpdated
        }
        if let newTotalExtendedProjects = dto.newTotalExtendedProjects {
            isUpdated = util.updateIfNeeded(&entity.total_extended_projects, newValue: Int32(newTotalExtendedProjects)) || isUpdated
        }
        if let newTotalRegistedTodos = dto.newTotalRegistedTodos {
            isUpdated = util.updateIfNeeded(&entity.total_registed_todos, newValue: Int32(newTotalRegistedTodos)) || isUpdated
        }
        if let newTotalFinishedTodos = dto.newTotalFinishedTodos {
            isUpdated = util.updateIfNeeded(&entity.total_finished_todos, newValue: Int32(newTotalFinishedTodos)) || isUpdated
        }
        if let newChallengeStepStatus = dto.newChallengeStepStatus {
            isUpdated = util.updateIfNeeded(&entity.challenge_step_status, newValue: try Utilities().convertToJSON(data: newChallengeStepStatus)) || isUpdated
        }
        if let newMyChallenges = dto.newMyChallenges {
            isUpdated = util.updateIfNeeded(&entity.mychallenges, newValue: try Utilities().convertToJSON(data: newMyChallenges)) || isUpdated
        }
        if let newSyncedAt = dto.newSyncedAt {
            isUpdated = util.updateIfNeeded(&entity.synced_at, newValue: newSyncedAt) || isUpdated
        }
        return isUpdated
    }
}

//MARK: DTO
// MARK: - StatChallengeDTO
struct StatDTO {
    
    let userId: String
    var term: Int
    var drop: Int
    var totalRegistedProjects: Int
    var totalFinishedProjects: Int
    var totalFailedProjects: Int
    var totalAlertedProjects: Int
    var totalExtendedProjects: Int
    var totalRegistedTodos: Int
    var totalFinishedTodos: Int
    var challengeStepStatus: [Int : Int]
    var myChallenges: [Int]
    
    init(){
        self.userId = ""
        self.term = 0
        self.drop = 0
        self.totalRegistedProjects = 0
        self.totalFinishedProjects = 0
        self.totalFailedProjects = 0
        self.totalAlertedProjects = 0
        self.totalExtendedProjects = 0
        self.totalRegistedTodos = 0
        self.totalFinishedTodos = 0
        self.challengeStepStatus = [ : ]
        self.myChallenges = []
    }
    
    init(with object: StatisticsObject){
        self.userId = object.userId
        self.term = object.term
        self.drop = object.drop
        self.totalRegistedProjects = object.totalRegistedProjects
        self.totalFinishedProjects = object.totalFinishedProjects
        self.totalFailedProjects = object.totalFailedProjects
        self.totalAlertedProjects = object.totalAlertedProjects
        self.totalExtendedProjects = object.totalExtendedProjects
        self.totalRegistedTodos = object.totalRegistedTodos
        self.totalFinishedTodos = object.totalFinishedTodos
        self.challengeStepStatus = object.challengeStepStatus
        self.myChallenges = object.mychallenges
    }
}

