//
//  ProjectDetailView.swift
//  teamplan
//
//  Created by sungyeon on 2024/02/19.
//  Copyright © 2024 team1os. All rights reserved.
//

import SwiftUI

struct ProjectDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var projectViewModel: ProjectViewModel
    
    @State private var isShowAddToDo: Bool = false
    @State private var isShowEmptyView: Bool = true
    let index: Int
    
    var body: some View {
        VStack {
            header
            
            Divider()
                .padding(.horizontal, 16)
            
            contents
            
            button
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("막걸리 브랜딩어쩌구")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {

                Button {
                    dismiss.callAsFunction()
                    
                } label: {
                    Image("left_arrow_home")
                }
            }
        }
//        .navigationTitle("\(projectViewModel.projects[index].name)")
        .onAppear {
            isShowEmptyView = projectViewModel.userProjects[index].registedTodo == 0
        }
    }
}

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailView(index: 0)
    }
}

extension ProjectDetailView {
    private var header: some View {
        ZStack{
            VStack(alignment: .leading) {
                Text("D-14")
                    .foregroundColor(Color.theme.mainPurpleColor)
                    .font(.appleSDGothicNeo(.bold, size: 24))
                    .padding(.bottom, 5)
                
                HStack {
                    Text("23.08.12")
                    Text("~")
                    Text("23.08.26")
                }
                .foregroundColor(Color.theme.mainBlueColor)
                .font(.appleSDGothicNeo(.regular, size: 12))
     
                HStack {
                    Text("할 일을 추가해주세요!")
                        .font(.appleSDGothicNeo(.bold, size: 17))
                        .foregroundColor(.theme.darkGreyColor)
                        .background(
                            Color.init(hex: "7248E1").opacity(0.5)
                                .frame(height: 3)
                                .offset(y: 7)
                        )
                    Spacer()
                }
                .padding(.bottom, 1)
                
                Text("오늘, 추가할 수 있는 할 일은 10개 남았어요")
                    .font(.appleSDGothicNeo(.regular, size: 14))
                    .foregroundColor(.theme.darkGreyColor)
                
                Spacer()
                    .frame(height: 20)
            }
            
            HStack {
                Spacer()
                HStack() {
                    Image(systemName: "plus")
                        .foregroundColor(.theme.mainPurpleColor)
                        .imageScale(.small)
                    Text("할 일")
                        .font(.appleSDGothicNeo(.semiBold, size: 14))
                        .foregroundColor(.theme.mainPurpleColor)
                        .offset(x: -3)
                    
                }
                .frame(width: 72, height: 38)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.greyColor, lineWidth: 1)
                )
                .offset(x: 0)
                .onTapGesture {
                    self.addToDo()
                }
            }
        }
        .padding(.leading, 38)
        .padding(.trailing, 24)

    }
    
    private var contents: some View {
        ZStack{
            if !isShowEmptyView {
                ScrollView {
                    Spacer()
                        .frame(height: 25)
                    VStack(spacing: 8) {
                        if isShowAddToDo {
                            let projectId = Int(projectViewModel.userProjects[index].id) ?? 0
                            AddingToDoView(projectId: projectId)
                        }
//                        ForEach(Array(projectViewModel.projects[index].toDos.enumerated()), id: \.1.id) { index, toDo in
//                            ToDoView(toDo: toDo)
//                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    projectEmpty
                    Spacer()
                }
            }
        }
        .padding(.leading, 38)
        .padding(.trailing, 24)

    }
    
    private var projectEmpty: some View {
        VStack {
            
            Image("project_empty")
                .frame(width: 67, height: 68.5)
                .padding(.bottom, 10)
            
            HStack {
                Text("할 일이")
                    .font(.appleSDGothicNeo(.regular, size: 16))
                    .foregroundColor(.theme.blackColor)
                Text("텅!")
                    .font(.appleSDGothicNeo(.semiBold, size: 18))
                    .foregroundColor(.theme.mainPurpleColor)
                Text("비었어요")
                    .font(.appleSDGothicNeo(.regular, size: 16))
                    .foregroundColor(.theme.blackColor)
            }
            .multilineTextAlignment(.center)
            
            
            Text("얼른 할 일을 추가해보세요")
                .font(.appleSDGothicNeo(.regular, size: 16))
                .foregroundColor(.theme.blackColor)
        }

    }
    
    private var button: some View {
        
        VStack {
            Divider()
                .padding(.bottom, 13)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            
            
            Text("프로젝트 완료하기")
                .foregroundColor(.white)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.theme.greyColor)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .onTapGesture {
                    print("프로젝트 완료")
                }
        }
    }
}

extension ProjectDetailView {
    private func addToDo() {
        withAnimation(.spring()) {
            self.isShowAddToDo = true
            self.isShowEmptyView = false
        }
    }
}
