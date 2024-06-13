//
//  SelectJudgeCountView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/25/23.
//

import SwiftUI

struct SelectJudgeCountView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Binding var judgeCount: Int
    @Binding var diveCount: Int
    @Binding var isShowing: Bool
    @Binding var confirmed: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("Select the number of judges")
                .font(.title.bold())
            HStack {
                Text("3")
                    .font(.title)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(judgeCount == 3 ? .blue : .clear)
                    )
                    .onTapGesture {
                        judgeCount = 3
                        //isShowing = false
                    }
                Text("5")
                    .font(.title)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(judgeCount == 5 ? .blue : .clear)
                    )
                    .onTapGesture {
                        judgeCount = 5
                        //isShowing = false
                    }
                Text("7")
                    .font(.title)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(judgeCount == 7 ? .blue : .clear)
                    )
                    .onTapGesture {
                        judgeCount = 7
                        //isShowing = false
                    }
            }
                Text("Select the number of dives")
                    .font(.title.bold())
            HStack {
                Text("6")
                    .font(.title)
                    .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.2 : UIScreen.main.bounds.size.width * 0.2, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.07 : UIScreen.main.bounds.size.width * 0.07)                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(diveCount == 6 ? .blue : .clear)
                    )
                    .onTapGesture {
                        diveCount = 6
                        //isShowing = false
                    }
                Text("11")
                    .font(.title)
                    .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.2 : UIScreen.main.bounds.size.width * 0.2, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.07 : UIScreen.main.bounds.size.width * 0.07)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(diveCount == 11 ? .blue : .clear)
                    )
                    .onTapGesture {
                        diveCount = 11
                        //isShowing = false
                    }
            }
            Spacer()
            Text("Confirm")
                .font(.title.bold())
                .foregroundStyle(judgeCount != 0 && diveCount != 0 ? colorScheme == .dark ? .white : .black : .gray)
                .padding()
                .overlay(
                    Rectangle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(judgeCount != 0 && diveCount != 0 ? colorScheme == .dark ? .white : .black : .gray)
                )
                .onTapGesture {
                    if judgeCount != 0 && diveCount != 0 {
                        confirmed = true
                        isShowing = false
                    }
                }
        }
        .onAppear {
            judgeCount = 0
            diveCount = 0
        }
    }
}

struct SelectJudgeCountView_Previews: PreviewProvider {
    static var previews: some View {
        SelectJudgeCountView(judgeCount: .constant(0), diveCount: .constant(0), isShowing: .constant(true), confirmed: .constant(false))
    }
}
