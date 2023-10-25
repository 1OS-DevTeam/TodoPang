//
//  StatisticsObject.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/10/10.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation

struct StatisticsObject{
    // id
    let stat_user_id: String
    
    //content: Etc
    var stat_term: Int
    var stat_drop: Int
    
    //content: Project & Todo
    var stat_proj_reg: Int
    var stat_proj_fin: Int
    var stat_proj_alert: Int
    var stat_proj_ext: Int
    var stat_todo_reg: Int
    
    //content: Challenge
    var stat_chlg_step: [[Int : Int]]
    var stat_mychlg: [Int : Int]
    
    // maintenance
    var stat_upload_at: Date
    
    // Service Constructor
    // : Signup
    init(identifier: String, signupDate: Date){
        self.stat_user_id = identifier
        self.stat_term = 0
        self.stat_drop = 0
        self.stat_proj_reg = 0
        self.stat_proj_fin = 0
        self.stat_proj_alert = 0
        self.stat_proj_ext = 0
        self.stat_todo_reg = 0
        self.stat_chlg_step = [
            [ChallengeType.serviceTerm.rawValue : 1],
            [ChallengeType.totalTodo.rawValue : 1],
            [ChallengeType.projectRegist.rawValue : 1],
            [ChallengeType.projectFinish.rawValue : 1],
            [ChallengeType.waterDrop.rawValue : 1]
        ]
        self.stat_mychlg = [:]
        self.stat_upload_at = signupDate
    }
    
    // Store Constructor
    // : Get (CoreData)
    init(statEntity: StatisticsEntity) {
        self.stat_user_id = statEntity.stat_user_id ?? "Unknown"
        self.stat_term = Int(statEntity.stat_term)
        self.stat_drop = Int(statEntity.stat_drop)
        self.stat_proj_reg = Int(statEntity.stat_proj_reg)
        self.stat_proj_fin = Int(statEntity.stat_proj_fin)
        self.stat_proj_alert = Int(statEntity.stat_proj_alert)
        self.stat_proj_ext = Int(statEntity.stat_proj_ext)
        self.stat_todo_reg = Int(statEntity.stat_todo_reg)
        self.stat_chlg_step = statEntity.stat_chlg_step as! [[Int : Int]]
        self.stat_mychlg = statEntity.stat_mychlg as! [Int : Int]
        self.stat_upload_at = statEntity.stat_upload_at ?? Date()
    }
    
    // : Update (Coredata)
    init(updatedStat: StatisticsDTO){
        self.stat_user_id = updatedStat.stat_user_id
        self.stat_term = updatedStat.stat_term
        self.stat_drop = updatedStat.stat_drop
        self.stat_proj_reg = updatedStat.stat_proj_reg
        self.stat_proj_fin = updatedStat.stat_proj_fin
        self.stat_proj_alert = updatedStat.stat_proj_alert
        self.stat_proj_ext = updatedStat.stat_proj_ext
        self.stat_todo_reg = updatedStat.stat_todo_reg
        self.stat_chlg_step = updatedStat.stat_chlg_step
        self.stat_mychlg = updatedStat.stat_mychlg
        self.stat_upload_at = updatedStat.stat_upload_at
    }
    
    // : Get (Firestore)
    init?(statData: [String : Any]){
        guard let stat_user_id = statData["stat_user_id"] as? String,
              let stat_term = statData["stat_term"] as? Int,
              let stat_drop = statData["stat_drop"] as? Int,
              let stat_proj_reg = statData["stat_proj_reg"] as? Int,
              let stat_proj_fin = statData["stat_proj_fin"] as? Int,
              let stat_proj_alert = statData["stat_proj_alert"] as? Int,
              let stat_proj_ext = statData["stat_proj_ext"] as? Int,
              let stat_todo_reg = statData["stat_todo_reg"] as? Int,
              let stat_chlg_step = statData["stat_chlg_step"] as? [[Int : Int]],
              let stat_mychlg = statData["stat_mychlg"] as? [Int : Int],
              let stat_upload_at = statData["stat_upload_at"] as? Date
        else {
            return nil
        }
        
        // Assigning values
        self.stat_user_id = stat_user_id
        self.stat_term = stat_term
        self.stat_drop = stat_drop
        self.stat_proj_reg = stat_proj_reg
        self.stat_proj_fin = stat_proj_fin
        self.stat_proj_alert = stat_proj_alert
        self.stat_proj_ext = stat_proj_ext
        self.stat_todo_reg = stat_todo_reg
        self.stat_chlg_step = stat_chlg_step
        self.stat_mychlg = stat_mychlg
        self.stat_upload_at = stat_upload_at
    }
    
    //============================
    // MARK: Func
    //============================
    func toDictionary() -> [String : Any] {
        return [
            "stat_user_id": self.stat_user_id,
            "stat_term": self.stat_term,
            "stat_drop": self.stat_drop,
            "stat_proj_reg": self.stat_proj_reg,
            "stat_proj_fin": self.stat_proj_fin,
            "stat_proj_alert": self.stat_proj_alert,
            "stat_proj_ext": self.stat_proj_ext,
            "stat_todo_reg": self.stat_todo_reg,
            "stat_chlg_step": self.stat_chlg_step,
            "stat_mychlg": self.stat_mychlg,
            "stat_upload_at": self.stat_upload_at
        ]
    }
}
