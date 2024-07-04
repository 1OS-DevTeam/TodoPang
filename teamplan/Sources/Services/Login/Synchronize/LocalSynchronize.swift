//
//  SynchronizeLocal.swift
//  teamplan
//
//  Created by 크로스벨 on 1/10/24.
//  Copyright © 2024 team1os. All rights reserved.
//

import Foundation

final class LocalSynchronize{
    
    private let userCD = UserServicesCoredata()
    private let statCD = StatisticsServicesCoredata()
    private let coreValueCD = CoreValueServicesCoredata()
    private let challengeCD = ChallengeServicesCoredata()
    private let accessLogCD = AccessLogServicesCoredata()
    private let projectCD = ProjectServicesCoredata()
    
    private let userFS = UserServicesFirestore()
    private let statFS = StatisticsServicesFirestore()
    private let coreValueFS = CoreValueServicesFirestore()
    private let challengeFS = ChallengeServicesFirestore()
    private let accessLogFS = AccessLogServicesFirestore()
    private let projectFS = ProjectServicesFirestore()
    
    private var userId: String
    
    // server properties
    private var coreValue: CoreValueObject
    private var serverUser: UserObject
    private var serverStat: StatisticsObject
    private var serverChallenges: [ChallengeObject]
    private var serverChallengesId: Set<Int>
    private var serverChallengesInfo: [Int : ChallengeInfoDTO]
    private var serverChallengesStatus: [Int : ChallengeStatusDTO]
    private var serverProjects: [ProjectObject]
    
    init(with userId: String) {
        self.userId = userId
        self.coreValue = CoreValueObject()
        self.serverUser = UserObject()
        self.serverStat = StatisticsObject()
        self.serverChallenges = []
        self.serverChallengesId = []
        self.serverChallengesInfo = [:]
        self.serverChallengesStatus = [:]
        self.serverProjects = []
    }
}

// MARK: - Main Executor

extension LocalSynchronize{
    
    func syncExecutor() async -> Bool {
        if await serverFetchExecutor() {
            if await localSetExecutor() {
                print("[LocalSync] Successfully set server data at local")
                return true
            } else {
               return false
            }
        } else {
            return false
        }
    }
}

// MARK: - Fetch From Server

extension LocalSynchronize{
    
    private func serverFetchExecutor() async -> Bool {
        async let isCoreValueFetched = fetchCoreValueFromServer()
        async let isUserFetched = fetchUserFromServer()
        async let isStatFetched = fetchStatFromServer()
        async let isProjectsFetched = fetchProjectFromServer()
        async let isChallengesFetched = fetchChallengesFromServer()
        
        let results = await [isCoreValueFetched, isUserFetched, isStatFetched, isProjectsFetched, isChallengesFetched]
        return results.allSatisfy{$0}
    }
    
    // CoreValue
    private func fetchCoreValueFromServer() async -> Bool {
        do {
            self.coreValue = try await coreValueFS.getDocs(with: userId)
            return true
        } catch {
            print("[LocalSync] Failed to fetch CoreValue from server")
            return false
        }
    }
    
    // User
    private func fetchUserFromServer() async -> Bool {
        do {
            self.serverUser = try await userFS.getDocs(with: userId)
            return true
        } catch {
            print("[LocalSync] Failed to fetch UserData from server")
            return false
        }
    }
    
    // Stat
    private func fetchStatFromServer() async -> Bool {
        do {
            self.serverStat = try await statFS.getDocs(with: userId)
            return true
        } catch {
            print("[LocalSync] Failed to fetch StatData from server")
            return false
        }
    }
    
    // Project
    private func fetchProjectFromServer() async -> Bool {
        do {
            self.serverProjects = try await projectFS.getDocsList(with: userId)
            return true
        } catch {
            print("[LocalSync] Failed to fetch projects from server")
            return false
        }
    }
    
    // Challenge
    private func fetchChallengesFromServer() async -> Bool {
        let isInfoFetch = await fetchChallengesInfos()
        let isStatusFetch = await fetchChallengesStatus()
        
        if isInfoFetch && isStatusFetch {
            return await convertToObject()
        } else {
            print("[LocalSync] Failed to fetch ChallengeData from server")
            return false
        }
    }
    
    private func fetchChallengesInfos() async -> Bool {
        do {
            let challengeInfoList = try await challengeFS.getInfoDocsList()
            for challenge in challengeInfoList {
                serverChallengesInfo[challenge.challengeId] = challenge
                serverChallengesId.insert(challenge.challengeId)
            }
            return true
        } catch {
            print("[LocalSync] Failed to fetch ChallengeInfo from server")
            return false
        }
    }
    
    private func fetchChallengesStatus() async -> Bool {
        do {
            let challengeStatusList = try await challengeFS.getStatusDocsList(with: userId)
            for challenge in challengeStatusList where serverChallengesId.contains(challenge.challengeId) {
                serverChallengesStatus[challenge.challengeId] = challenge
            }
            return true
        } catch {
            print("[LocalSync] Failed to fetch ChallengeStatus from server")
            return false
        }
    }
    
    private func convertToObject() async -> Bool {
        for challengeId in serverChallengesId {
            guard let challengeInfo = serverChallengesInfo[challengeId],
                  let challengeStatus = serverChallengesStatus[challengeId] else {
                print("[LocalSync] Failed to indexing challenge data")
                return false
            }
            let object = mergeInfoAndStatus(with: challengeInfo, and: challengeStatus)
            serverChallenges.append(object)
        }
        return true
    }
    
    private func mergeInfoAndStatus(with info: ChallengeInfoDTO, and status: ChallengeStatusDTO) -> ChallengeObject {
        return ChallengeObject(
            challengeId: status.challengeId,
            userId: status.userId,
            title: info.title,
            desc: info.desc,
            goal: info.goal,
            type: info.type,
            reward: info.reward,
            step: info.step,
            version: info.version,
            status: status.status,
            lock: status.lock,
            progress: status.progress,
            selectStatus: status.selectStatus,
            selectedAt: status.selectedAt,
            unselectedAt: status.unselectedAt,
            finishedAt: status.finishedAt
        )
    }
}

// MARK: - Apply Local

extension LocalSynchronize{
    
    private func localSetExecutor() async -> Bool {
        async let isCoreValueSet = setCoreValueAtLocal()
        async let isUserSet = setUserAtLocal()
        async let isStatSet = setStatAtLocal()
        async let isProjectsSet = setProjectsAtLocal()
        async let isChallengesSet = setChallengesAtLocal()
        
        let results = await [isCoreValueSet, isUserSet, isStatSet, isProjectsSet, isChallengesSet]
        if results.allSatisfy({$0}){
            return await LocalStorageManager.shared.saveContext()
        } else {
            return false
        }
    }
    
    private func setCoreValueAtLocal() async -> Bool {
        coreValueCD.setObject(with: self.coreValue)
        return true
    }
    
    private func setUserAtLocal() async -> Bool {
        userCD.setObject(with: self.serverUser)
        return true
    }
    
    private func setStatAtLocal() async -> Bool {
        do {
            try statCD.setObject(with: self.serverStat)
            return true
        } catch {
            print("[LocalSync] Failed to set StatData at Local")
            return false
        }
    }
    
    private func setProjectsAtLocal() async -> Bool {
        for project in self.serverProjects {
            projectCD.setObject(with: project)
        }
        return true
    }
    
    private func setChallengesAtLocal() async -> Bool {
        for challenge in self.serverChallenges {
            challengeCD.setObject(with: challenge)
        }
        return true
    }
}


