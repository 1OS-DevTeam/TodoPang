//
//  UserServiceCoredata.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/08/22.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import CoreData

//MARK: Main

final class UserServicesCoredata {
    typealias Entity = UserEntity
    typealias Object = UserObject
    typealias DTO = UserUpdateDTO
    
    var object = UserObject()
    
    func setObject(context: NSManagedObjectContext, object: UserObject) -> Bool {
        let entity = UserEntity(context: context)
        createEntity(with: object, at: entity)
        return checkEntity(with: entity)
    }
    
    func getObject(context: NSManagedObjectContext, userId: String) throws -> Bool {
        let entity = try getEntity(context: context, userId: userId)
        return convertToObject(with: entity)
    }
    
    func updateObject(context: NSManagedObjectContext, dto: UserUpdateDTO) throws -> Bool {
        let entity = try getEntity(context: context, userId: dto.userId)
        return checkUpdate(from: entity, to: dto)
    }
    
    func deleteObject(context: NSManagedObjectContext, userId: String) throws {
        let entity = try getEntity(context: context, userId: userId)
        context.delete(entity)
    }
}

// MARK: - Sub

extension UserServicesCoredata {
    
    func isObjectExist(context: NSManagedObjectContext, userId: String) -> Bool {
        let reqeust = constructFetchRequest(with: userId)
        do {
            let count = try context.count(for: reqeust)
            return count > 0
        } catch {
            return false
        }
    }
}

// MARK: - Context Related

extension UserServicesCoredata {
    
    private func createEntity(with object: Object, at entity: Entity) {
        entity.user_id = object.userId
        entity.email = object.email
        entity.name = object.name
        entity.social_type = object.socialType.rawValue
        entity.status = object.status.rawValue
        entity.access_log_head = Int32(object.accessLogHead)
        entity.created_at = object.createdAt
        entity.changed_at = object.changedAt
        entity.synced_at = object.syncedAt
    }
    
    private func checkEntity(with entity: Entity) -> Bool {
        if entity.user_id == nil {
            print("[Coredata-User] nil detected: 'user_id'")
            return false
        }
        if entity.email == nil {
            print("[Coredata-User] nil detected: 'email'")
            return false
        }
        if entity.name == nil {
            print("[Coredata-User] nil detected: 'name'")
            return false
        }
        if entity.social_type == nil {
            print("[Coredata-User] nil detected: 'social_type'")
            return false
        }
        if entity.status == nil {
            print("[Coredata-User] nil detected: 'status' ")
            return false
        }
        if entity.created_at == nil {
            print("[Coredata-User] nil detected: 'created_at'")
            return false
        }
        if entity.changed_at == nil {
            print("[Coredata-User] nil detected: 'changed_at'")
            return false
        }
        if entity.synced_at == nil {
            print("[Coredata-User] nil detected: 'synced_at'")
            return false
        }
        return true
    }
    
    private func constructFetchRequest(with userId: String) -> NSFetchRequest<Entity> {
        let fetchRequest: NSFetchRequest<Entity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: EntityPredicate.user.format, userId)
        
        return fetchRequest
    }
    
    private func getEntity(context: NSManagedObjectContext, userId: String) throws -> Entity {
        let request = constructFetchRequest(with: userId)
        guard let entity = try context.fetch(request).first else {
            throw CoredataError.fetchFailure(serviceName: .cd, dataType: .user)
        }
        return entity
    }
}

// MARK: - Util

extension UserServicesCoredata{
    
    private func convertToObject(with entity: UserEntity) -> Bool {
        guard let userId = entity.user_id,
              let email = entity.email,
              let name = entity.name,
              let stringSocialType = entity.social_type,
              let socialType = Providers(rawValue: stringSocialType),
              let stringStatus = entity.status,
              let status = UserStatus(rawValue: stringStatus),
              let createdAt = entity.created_at,
              let changedAt = entity.changed_at,
              let syncedAt = entity.synced_at
        else {
            print("[Coredata-User] Failed to convert entity to object")
            return false
        }
        self.object = UserObject(
            userId: userId,
            email: email,
            name: name,
            socialType: socialType,
            status: status,
            accessLogHead: Int(entity.access_log_head),
            createdAt: createdAt,
            changedAt: changedAt,
            syncedAt: syncedAt
        )
        return true
    }
    
    private func checkUpdate(from entity: UserEntity, to dto: UserUpdateDTO) -> Bool {
        let util = Utilities()
        var isUpdated = false
        
        if let newEmail = dto.newEmail {
            isUpdated = util.updateIfNeeded(&entity.email, newValue: newEmail) || isUpdated
        }
        if let newName = dto.newName {
            isUpdated = util.updateIfNeeded(&entity.name, newValue: newName) || isUpdated
        }
        if let newStatus = dto.newStatus?.rawValue {
            isUpdated = util.updateIfNeeded(&entity.status, newValue: newStatus) || isUpdated
        }
        if let newLogHead = dto.newLogHead {
            isUpdated = util.updateIfNeeded(&entity.access_log_head, newValue: Int32(newLogHead)) || isUpdated
        }
        if let newChangedAt = dto.newChangedAt {
            isUpdated = util.updateIfNeeded(&entity.changed_at, newValue: newChangedAt) || isUpdated
        }
        if let newSyncedAt = dto.newSyncedAt {
            isUpdated = util.updateIfNeeded(&entity.synced_at, newValue: newSyncedAt) || isUpdated
        }
        return isUpdated
    }
}

// MARK: - DTO

struct UserUpdateDTO{
    let userId: String
    let newEmail: String?
    let newName: String?
    let newStatus: UserStatus?
    let newLogHead: Int?
    let newChangedAt: Date?
    let newSyncedAt: Date?
    
    init(userId: String,
         newEmail: String? = nil,
         newName: String? = nil,
         newStatus: UserStatus? = nil,
         newLogHead: Int? = nil,
         newChangedAt: Date? = nil,
         newSyncedAt: Date? = nil)
    {
        self.userId = userId
        self.newEmail = newEmail
        self.newName = newName
        self.newStatus = newStatus
        self.newLogHead = newLogHead
        self.newChangedAt = newChangedAt
        self.newSyncedAt = newSyncedAt
    }
}
