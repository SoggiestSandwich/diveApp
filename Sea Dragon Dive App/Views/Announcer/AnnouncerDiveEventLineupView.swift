//
//  AnnouncerDiveEventLineupView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import SwiftUI
import CodeScanner

struct AnnouncerDiveEventLineupView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var announcerEventStore: AnnouncerEventStore
    
    @State var failedScanAlert: Bool = false
    @State private var scannedCode: String = ""
    @State var isPresentingScanner = false
    
    @Binding var path: [String]

    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    
    var ScannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    
                    let tempCodes = Codes(name: code.string)
                    if tempCodes.name != "" {
                        let  base64Data = tempCodes.name.data(using: .utf8)
                        let data = Data(base64Encoded: base64Data!)
                        //let result = String(data: data!, encoding: .utf8)
                        let compressedJsonCode = data
                        //uncompress data
                        let jsonCode: Data
                        if compressedJsonCode!.isGzipped {
                            jsonCode = try! compressedJsonCode!.gunzipped()
                        }
                        else {
                            jsonCode = compressedJsonCode!
                        }
                        let decoder = JSONDecoder()
                        let entries = try? decoder.decode(announcerEvent.self, from: jsonCode)
                        if entries != nil {
                            announcerEventStore.event = entries!
                            announcerEventStore.saveEvent()
                            
                            self.isPresentingScanner = false
                        }
                        else {
                            //popup saying invalid qr code was scanned
                            failedScanAlert = true
                        }
                    }
                }
            }
        )
        .alert("Ivalid QR Code", isPresented: $failedScanAlert) {
            Button("OK", role: .cancel) {
                self.isPresentingScanner = false
            }
        } message: {
            Text("Could not find the needed data in the scanned QR Code")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    path = []
                } label: {
                    Image(systemName: "gearshape.fill")
                        .interpolation(.none).resizable().frame(width: UIScreen.main.bounds.size.height * 0.03, height: UIScreen.main.bounds.size.height * 0.03)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.2) : Color(red: 0, green: 0, blue: 0, opacity: 0.1))
            .padding(5)
            Spacer()
            List {
                ForEach(Array(zip(announcerEventStore.event.diver.indices, announcerEventStore.event.diver)), id: \.0) { index, diver in
                    VStack(alignment: .leading) {
                        Text("\(index + 1). \(diver.name)")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text("\(diver.school)")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            Spacer()
            Button {
                //opens qr scanner to scan in divers
                self.isPresentingScanner = true
            } label: {
                Text("Import New Dive Event")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .bold()
                    .padding(15)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                    )
            }
            Button {
                //starts event
            } label: {
                Text("Start Event")
                    .foregroundColor(announcerEventStore.event.diver.isEmpty ? .gray : colorScheme == .dark ? .white : .black)
                    .bold()
                    .padding(15)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(announcerEventStore.event.diver.isEmpty ? .gray : colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                    )
            }
            
        }
        .onAppear {
            if announcerEventStore.event.diver.isEmpty {
                self.isPresentingScanner = true
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            self.ScannerSheet
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AnnouncerDiveEventLineupView(path: .constant([]))
        .environmentObject(AnnouncerEventStore())
}
