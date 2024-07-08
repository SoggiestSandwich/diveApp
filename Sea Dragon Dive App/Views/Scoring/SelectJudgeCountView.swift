//
//  SelectJudgeCountView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/25/23.
//

import SwiftUI

struct SelectJudgeCountView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.verticalSizeClass) var verticalSizeClass //detects if the device is in a verticle orientation
    
    @Binding var judgeCount: Int //the number of judges for the event
    @Binding var diveCount: Int //the number of dives for the event
    @Binding var isShowing: Bool //used to close the sheet
    @Binding var confirmed: Bool //used to verify that judge and dive count have been selected
    
    var body: some View {
        VStack {
            Spacer()
            //judge count
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
            //dive count
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
            //confirm
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
                    //checks that a judge and dive count have been selected and if they have confirms and closes the sheet
                    if judgeCount != 0 && diveCount != 0 {
                        confirmed = true
                        isShowing = false
                    }
                }
        }
        .onAppear {
            //resets the judge and dive count to 0 when the sheet is opened
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
