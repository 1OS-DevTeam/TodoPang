//
//  ChallengesView.swift
//  teamplan
//
//  Created by sungyeon kim on 2023/09/21.
//  Copyright © 2023 team1os. All rights reserved.
//

import SwiftUI

struct ChallengesView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var allChallenge: [ChallengeObject]
    let pageSize = 12

    @State private var currentPage = 0
    
    let columns = [
      //추가 하면 할수록 화면에 보여지는 개수가 변함
        GridItem(.adaptive(minimum: 57)),
        GridItem(.adaptive(minimum: 57)),
        GridItem(.adaptive(minimum: 57)),
        GridItem(.adaptive(minimum: 57)),
    ]
    
    private let myChallengeCards: [ChallengeCardModel] = [
        ChallengeCardModel(image: "applelogo", title: "목표달성의 쾌감!", description: "물방울 3개 모으기"),
        ChallengeCardModel(image: "applelogo", title: "프로젝트 완주", description: "프로젝트 한개 완주"),
        ChallengeCardModel(image: "applelogo", title: "화이팅!", description: "물방울 10개 모으기")
    ]
    
    private let itemsPerPage = 12
    private var numberOfPages: Int {
        return (allChallenge.count + itemsPerPage - 1) / itemsPerPage
    }

    @State private var selectedCardIndex: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                
                descriptionSection
                    .padding(.bottom, 24)
                topCardSection
                    .padding(.bottom, 21)
                
                gridSection
                Spacer()
                pageControl
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("도전과제")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {

                    Button {
                        dismiss.callAsFunction()
                        
                    } label: {
                        Image("left_arrow_home")
                    }
                }
            }
        }
    }
}

//struct ChallengesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChallengesView()
//    }
//}

extension ChallengesView {
    
    private var descriptionSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("도전과제에 하나씩 도전해보세요!")
                    .font(.appleSDGothicNeo(.bold, size: 17))
                    .foregroundColor(.theme.darkGreyColor)
                Spacer()
            }
            
            HStack {
                Text("도전과제는 '나의 도전과제'에 등록한 시점부터 수치가 계산됩니다.")
                    .font(.appleSDGothicNeo(.regular, size: 12))
                    .foregroundColor(.theme.darkGreyColor)
                Spacer()
            }
        
        }
        .padding(.leading, 16)
        .padding(.top, 14)
    }
    
    private var topCardSection: some View {
        VStack {
            HStack {
                Text("나의 도전과제")
                    .font(.appleSDGothicNeo(.semiBold, size: 20))
                    .foregroundColor(.theme.blackColor)
                Spacer()
            }
            .padding(.leading, 16)
            
            HStack(spacing: 17) {
                ForEach(Array(myChallengeCards.enumerated()), id: \.element.id) { index, challenge in
                    let screenWidth = UIScreen.main.bounds.size.width
                    ZStack {
                        if self.selectedCardIndex == index {
                            ChallengeCardBackView(challenge: challenge, parentsWidth: screenWidth)
                                .background(.white)
                                .cornerRadius(4)
                                .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
                        } else {
                            ChallengeCardFrontView(challenge: challenge, parentsWidth: screenWidth)
                                .background(.white)
                                .cornerRadius(4)
                        }
                    }
                    .rotation3DEffect(
                        .degrees(self.selectedCardIndex == index ? 180 : 0),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    .onTapGesture {
                        withAnimation(.linear) {
                            self.selectedCardIndex = (self.selectedCardIndex == index) ? nil : index
                        }
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)

        }
    }
    private var gridSection: some View {
        
        VStack {
            HStack {
                Text("모든 도전과제")
                    .font(.appleSDGothicNeo(.semiBold, size: 20))
                    .foregroundColor(.theme.blackColor)
                    .padding(.leading, 16)
                Spacer()
            }
            
            TabView(selection: $currentPage) {
                ForEach(0..<(allChallenge.count / 12), id: \.self) { pageIndex in
                    let startIndex = pageIndex * 12
                    let endIndex = min(startIndex + 12, allChallenge.count)
                    let pageItems = Array(allChallenge[startIndex..<endIndex])
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(pageItems, id: \.self) { item in
                            ChallengeDetailView(challenge: item)
                                .frame(width: 62, height: 120)
                        }
                    }
                    .tag(pageIndex)
                    
                }
            }
            .frame(height: 380)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

        }
    }
    
    private var pageControl: some View {
        HStack(spacing: 10) {
            ForEach(0..<(allChallenge.count / 12), id: \.self) { index in
                if index == currentPage {
                    Circle()
                        .frame(width: 9, height: 9)
                        .foregroundColor(.theme.mainPurpleColor)
                } else {
                    Circle()
                        .frame(width: 9, height: 9)
                        .foregroundColor(.init(hex: "D9D9D9"))
                }
            }
        }
        .padding(.bottom, 24)
    }
}
