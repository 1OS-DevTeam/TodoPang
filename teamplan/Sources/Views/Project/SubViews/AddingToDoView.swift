//
//  AddingToDoView.swift
//  teamplan
//
//  Created by sungyeon on 3/18/24.
//  Copyright © 2024 team1os. All rights reserved.
//

import SwiftUI

struct AddingToDoView: View {
    
    @State private var toDo: String = ""
    @State private var isEditing: Bool = false
    let projectId: Int
    
    @ObservedObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        HStack {
            HStack {
                Image("checkBox_none")
                    .onTapGesture {
                        print("toggle")
                    }
                ZStack {
                    TextField("할 일은 삭제가 불가능하지만 수정은 가능해요", text: $toDo) { editing in
                        self.isEditing = editing
                    }
                    .onSubmit {
                        let randomInt32 = Int32.random(in: Int32.min...Int32.max)
                        let todoId = Int(randomInt32)
                        let todo = TodoSetDTO(projectId: projectId, todoId: todoId, userId: projectViewModel.identifier, desc: toDo)
                        projectViewModel.addNewTodo(projectId: projectId, Todo: todo)
                    }
                    
                    .padding(.horizontal, 16)
                    .font(.appleSDGothicNeo(.regular, size: 14))
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isEditing ? SwiftUI.Color.theme.mainPurpleColor : Color(hex: "E2E2E2"), lineWidth: 1)
                    
                }
                .frame(height: 38)
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
    }
}
//
//#Preview {
//    AddingToDoView(projectId: 1)
//}
