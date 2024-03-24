//
//  ProjectViewModel.swift
//  teamplan
//
//  Created by sungyeon on 2024/02/01.
//  Copyright © 2024 team1os. All rights reserved.
//

import Foundation
import Combine

final class ProjectViewModel: ObservableObject {
    
    @Published var userName: String = ""
    @Published var projectStatus: userStatProjectDTO?
    @Published var userProjects: [ProjectCardDTO] = []
    @Published var isProjectEmpty: Bool = true
    
    // AddProjectView에 필요한 프로퍼티
    @Published var projectName: String = ""
    @Published var startDate: StartDateSelection = .none
    @Published var duration: DurationSelection = .none

    let identifier: String
    lazy var projectService = ProjectIndexService(with: self.identifier)
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        let userDefaultManager = UserDefaultManager.loadWith(key: "user")
        let identifier = userDefaultManager?.identifier
        self.identifier = identifier ?? ""
        Task {
            await self.getUserName()
        }
        try? projectService.readyService()
    }
    
    func getProjectsInfo() {
        
        self.userProjects = try! projectService.getProjects()
        self.projectStatus = try! projectService.getStatistics()
        print(self.userProjects)
        print(self.projectStatus)
        
        self.$userProjects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projects in
                self?.isProjectEmpty = projects.isEmpty
            }
            .store(in: &cancellables)
        
    }
    
    func addNewProject() {
        let start = self.startDate.futureDate(from: Date())
        let end = self.duration.futureDate(from: Date())
        let newProject = ProjectSetDTO(title: projectName, startedAt: start, deadline: end)
        try? projectService.setProject(with: newProject)
        self.userProjects = try! projectService.getProjects()
        self.projectStatus = try! projectService.getStatistics()
        self.startDate = .none
        self.duration = .none
        self.projectName = ""
    }
    
    func addNewTodo(projectId: Int, Todo: TodoSetDTO) {
        print(#function)
        let service = ProjectDetailService(userId: identifier, projectId: projectId)
        try? service.setTodo(with: Todo)
    }
    
    @MainActor
    private func getUserName() async {
        let userDefaultManager = UserDefaultManager.loadWith(key: "user")
        self.userName = userDefaultManager?.userName ?? "Unkown"
    }
}
