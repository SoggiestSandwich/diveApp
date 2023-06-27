//
//  LoginScreenView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI

struct LoginScreenView: View {
    @State var username: String = ""
    @State var userSchool: String = ""
    @State var selection: Int = 0
    
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    Text("Settings")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    //displays the roles and allows you to click them to toggle checkmarks
                    Text("Your role:")
                    HStack {
                        Image(systemName: selection == 1 ? "checkmark.circle" : "circle")
                        
                        Text("Diving Competitor")
                            .bold()
                            .onTapGesture {
                                selection = 1
                            }
                    }
                    HStack {
                        Image(systemName: selection == 2 ? "checkmark.circle" : "circle")
                        Text("Coach")
                            .bold()
                            .onTapGesture {
                                selection = 2
                            }
                    }
                    
                    HStack {
                        Image(systemName: selection == 3 ? "checkmark.circle" : "circle")
                        Text("Score Keeper")
                            .bold()
                            .onTapGesture {
                                selection = 3
                            }
                    }
                    
                    HStack {
                        Image(systemName: selection == 4 ? "checkmark.circle" : "circle")
                        Text("Announcer")
                            .bold()
                            .onTapGesture {
                                selection = 4
                            }
                    }
                    
                    Text("")
                    HStack {
                        Text("Your Name")
                        TextField("Enter Name", text: $username)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Your School")
                        TextField("Enter School", text: $userSchool)
                            .multilineTextAlignment(.trailing)
                    }
                    NavigationLink(destination: getDestination()) {
                        Text("Done")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .bold()
                    .padding(5)
                    //.shadow(color: .black.opacity(1),radius: 1, x: 3, y: 3)
                    .border(.foreground, width: 2)
                }
            }
        }
    }
    
    @ViewBuilder
    func getDestination() -> some View {
        switch selection {
        case 3: AddDiversView()
        default: EmptyView()
        }
    }
    
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}
