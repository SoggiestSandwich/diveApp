//
//  CoachEditSigningView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/21/23.
//

import SwiftUI

struct CoachEditSigningView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used for custom back button
    
    @State private var currentLine = Line() //the line being currently drawn
    @State private var lines: [Line] = [] //array of all lines that were drawn
    
    @Binding var selectedCoachEntryIndex: Int //index of the coach entry that being confirmed
    @Binding var selectedDiverEntryIndex: Int //index of the diver entry being confirmed
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore //coach entry persistant data
    
    var body: some View {
            NavigationStack {
                //closes this sheet
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Dismiss")
                }
                .padding()
                Text("Diver Must Signs Their Dive Entry")
                    .font(.title2.bold())
                    .padding(.top)
                Text("I agree that I can perform these dives")
                
                ZStack {
                    //canvas for writing on
                    Canvas { context, size in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path, with: .color(colorScheme == .dark ? .white : .black), lineWidth: line.lineWidth)
                        }
                        
                    }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            //adds points to the line
                            let newPoint = value.location
                            currentLine.points.append(newPoint)
                            self.lines.append(currentLine)
                        })
                            .onEnded({ value in
                                //adds the current line to the line list and sets the current line to a new line
                                self.lines.append(currentLine)
                                self.currentLine = Line(points: [])
                            })
                    )
                    VStack {
                        Text("Sign Here")
                            .font(.title)
                            .foregroundColor(self.lines.isEmpty ? .gray : .clear)
                        Text("X _________________")
                            .font(.largeTitle)
                    }
                }
                
                HStack {
                    //clears all lines from the line array
                    Button {
                        self.lines.removeAll()
                    } label: {
                        HStack {
                            Image(systemName: "eraser.line.dashed.fill")
                            Text("Clear")
                        }
                        .padding()
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    //if there is writing generate a qr code otherwise do nothing
                    if self.lines.isEmpty {
                        Text("Done")
                            .padding()
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .background(
                                Rectangle()
                                    .stroke(lineWidth: 2)
                            )
                            .foregroundColor(.gray)
                    }
                    else {
                        Button {
                            coachEntryStore.coachesList[selectedCoachEntryIndex].diverEntries[selectedDiverEntryIndex].finishedEntry = true
                            //validateEntry()
                            coachEntryStore.saveDiverEntry()
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                                Text("Done")
                                    .padding()
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                    .background(
                                        Rectangle()
                                            .stroke(lineWidth: 2)
                                    )
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
    }
}

struct CoachEditSigningView_Previews: PreviewProvider {
    static var previews: some View {
        CoachEditSigningView(selectedCoachEntryIndex: .constant(0), selectedDiverEntryIndex: .constant(0))
    }
}
