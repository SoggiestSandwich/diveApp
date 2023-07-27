//
//  SelectJudgeCountView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/25/23.
//

import SwiftUI

struct SelectJudgeCountView: View {
    @Binding var judgeCount: Int
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
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
                    .onTapGesture {
                        judgeCount = 3
                        isShowing = false
                    }
                Text("5")
                    .font(.title)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .onTapGesture {
                        judgeCount = 5
                        isShowing = false
                    }
                Text("7")
                    .font(.title)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .onTapGesture {
                        judgeCount = 7
                        isShowing = false
                    }
            }
        }
        .onAppear { judgeCount = 0 }
    }
}

struct SelectJudgeCountView_Previews: PreviewProvider {
    static var previews: some View {
        SelectJudgeCountView(judgeCount: .constant(0), isShowing: .constant(true))
    }
}
