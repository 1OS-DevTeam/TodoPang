//
//  NotificationView.swift
//  teamplan
//
//  Created by sungyeon kim on 2023/08/11.
//  Copyright © 2023 team1os. All rights reserved.
//

import SwiftUI
import WrappingHStack

struct NotificationView: View {
    
    @State private var isLoading = true
    @State private var showAlert = false
    
    @EnvironmentObject private var notifyVM: NotificationViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if isLoading {
                LoadingView()
            } else {
                section
                    .frame(height: 61)
                
                if notifyVM.filteredNotiList.isEmpty {
                    Spacer()
                    NotificationEmptyView()
                    Spacer()
                } else {
                    ScrollView {
                        NotificationListView()
                            .environmentObject(notifyVM)
                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("알림")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("left_arrow_home")
                }
            }
        }
        .onAppear {
            Task {
                if await notifyVM.prepareViewModel() {
                    isLoading = false
                } else {
                    showAlert = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to load notifications."),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }
}

extension NotificationView {
    private var section: some View {
        WrappingHStack(notifyVM.notiSections, id: \.self) { section in
            VStack {
                Text(section.title)
                    .foregroundColor(section.isSelected ? .theme.whiteColor : Color(hex: "3B3B3B"))
                    .font(.appleSDGothicNeo(.regular, size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(section.isSelected ? Color.theme.mainPurpleColor : Color.theme.whiteColor)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                    )
                
                Spacer()
                    .frame(height: 10)
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    self.filterNotification(type: section.type)
                    self.filterSection(title: section.title)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func filterSection(title: String) {
        notifyVM.notiSections = notifyVM.notiSections.map { section in
            var updatedSection = section
            updatedSection.isSelected = section.title == title ? true : false
            return updatedSection
        }
    }
    
    private func filterNotification(type: NotificationType) {
        notifyVM.filterNotifications(type: type)
    }
}
