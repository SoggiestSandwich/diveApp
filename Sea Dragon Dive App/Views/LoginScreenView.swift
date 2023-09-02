//
//  LoginScreenView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI

struct LoginScreenView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var settingsStore: SettingsStore
    
    @State var backToRoot: Bool = false
    @State var path: [String] = []
    
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                List {
                    Text("Settings")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    //displays the roles and allows you to click them to toggle checkmarks
                    Text("Your role:")
                    HStack {
                        Image(systemName: settingsStore.settingsList.role == 1 ? "checkmark.circle" : "circle")
                        
                        Text("Diving Competitor")
                            .bold()
                            .onTapGesture {
                                settingsStore.settingsList.role = 1
                                settingsStore.saveSetting()
                            }
                    }
                    HStack {
                        Image(systemName: settingsStore.settingsList.role == 2 ? "checkmark.circle" : "circle")
                        Text("Coach")
                            .bold()
                            .onTapGesture {
                                settingsStore.settingsList.role = 2
                                settingsStore.saveSetting()
                            }
                    }
                    
                    HStack {
                        Image(systemName: settingsStore.settingsList.role == 3 ? "checkmark.circle" : "circle")
                        Text("Score Keeper")
                            .bold()
                            .onTapGesture {
                                settingsStore.settingsList.role = 3
                                settingsStore.saveSetting()
                            }
                    }
                    
                    HStack {
                        Image(systemName: settingsStore.settingsList.role == 4 ? "checkmark.circle" : "circle")
                        Text("Announcer")
                            .bold()
                            .onTapGesture {
                                settingsStore.settingsList.role = 4
                                settingsStore.saveSetting()
                            }
                    }
                    
                    Text("")
                    HStack {
                        Text("Your Name")
                        TextField("Enter Name", text: $settingsStore.settingsList.name)
                            .onChange(of: settingsStore.settingsList.name) { _ in
                                settingsStore.saveSetting()
                            }
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Your School")
                        TextField("Enter School", text: $settingsStore.settingsList.school)
                            .onChange(of: settingsStore.settingsList.school) { _ in
                                settingsStore.saveSetting()
                            }
                            .multilineTextAlignment(.trailing)
                    }
                    Button {
                        path.append("")
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .disabled(settingsStore.settingsList.role == 0 ? true : settingsStore.settingsList.role == 1 ? settingsStore.settingsList.name != "" && settingsStore.settingsList.school != "" ? false : true : false)
                    .bold()
                    .padding(5)
                    //.shadow(color: .black.opacity(1),radius: 1, x: 3, y: 3)
                    .border(.foreground, width: 2)
                }
                .navigationDestination(for: String.self) { _ in
                    getDestination()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .task {
            if settingsStore.settingsList.role == 1 && settingsStore.settingsList.name != "" && settingsStore.settingsList.school != "" {
                path.append("")
            }
            else if settingsStore.settingsList.role == 2 {
                path.append("")
            }
            else if settingsStore.settingsList.role == 3 {
                path.append("")
            }
        }
    }
    
    @ViewBuilder
    func getDestination() -> some View {
        switch settingsStore.settingsList.role {
        case 1: DiverHomeView(username: settingsStore.settingsList.name, userSchool: settingsStore.settingsList.school)
        case 2: CoachEventSelectionView(name: settingsStore.settingsList.name, team: settingsStore.settingsList.school, path: $path)
        case 3: EventSelectionView(path: $path)
                .onDisappear {
                    backToRoot = false
                }
            
        default: EmptyView()
        }
    }
    
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
            .environmentObject(SettingsStore())
    }
}
