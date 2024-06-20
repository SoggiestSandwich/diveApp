//
//  LoginScreenView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI

struct LoginScreenView: View {
    
    @Environment(\.colorScheme) var colorScheme //detects whether the device is in dark mode
    
    @EnvironmentObject var settingsStore: SettingsStore //accesses the setting's persistant data
    
    @State var path: [String] = [] //the path array that brings us back to the login screen when = []
    
    var body: some View {
        VStack {
            //starts the stack of views using path to easily come back to this view
            NavigationStack(path: $path) {
                //entire view is built on a list which in this case acts as a formatted Vstack
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
                    
                    Text("") //empty row
                    HStack {
                        Text("Your Name")
                        TextField("Enter Name", text: $settingsStore.settingsList.name)
                            .onChange(of: settingsStore.settingsList.name) { _ in
                                //when the name is changed it is saved to settings persistant data
                                settingsStore.saveSetting()
                            }
                            .multilineTextAlignment(.trailing) //move textfield to the trailing side
                    }
                    HStack {
                        Text("Your School")
                        TextField("Enter School", text: $settingsStore.settingsList.school)
                            .onChange(of: settingsStore.settingsList.school) { _ in
                                //when the school is changed it is saved to settings persistant data
                                settingsStore.saveSetting()
                            }
                            .multilineTextAlignment(.trailing) //move textfield to the trailing side
                    }
                    Button {
                        path.append("") //basically tells the navigation stack that we are stacking on a new view
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .disabled(settingsStore.settingsList.role == 0 ? true : settingsStore.settingsList.role == 1 ? settingsStore.settingsList.name != "" && settingsStore.settingsList.school != "" ? false : true : false) //disables the button if any necessary fields are blank
                    .bold()
                    .padding(5)
                    //.shadow(color: .black.opacity(1),radius: 1, x: 3, y: 3)
                    .border(.foreground, width: 2)
                }
                .navigationDestination(for: String.self) { _ in
                    getDestination() //determines what view the app will send you
                }
            }
            .navigationBarBackButtonHidden(true) //removes the back button since there is nowhere to go back to
        }
        .task {
            //when the app opens it will read the persistant data and go to the view that was last selected
            if settingsStore.settingsList.role == 1 && settingsStore.settingsList.name != "" && settingsStore.settingsList.school != "" {
                path.append("")
            }
            else if settingsStore.settingsList.role == 2 {
                path.append("")
            }
            else if settingsStore.settingsList.role == 3 {
                path.append("")
            }
            else if settingsStore.settingsList.role == 4 {
                path.append("")
            }
        }
    }
    
    @ViewBuilder
    //returns the view that corresponds to the selected role or defaults to an empty view
    func getDestination() -> some View {
        switch settingsStore.settingsList.role {
        case 1: DiverHomeView(username: settingsStore.settingsList.name, userSchool: settingsStore.settingsList.school)
        case 2: CoachEventSelectionView(name: settingsStore.settingsList.name, team: settingsStore.settingsList.school, path: $path)
        case 3: EventSelectionView(path: $path)
        case 4: AnnouncerDiveEventLineupView(path: $path).environmentObject(AnnouncerEventStore())
            
        default: EmptyView() //should be impossible to happen since the button would be disabled
        }
    }
    
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
            .environmentObject(SettingsStore())
    }
}
