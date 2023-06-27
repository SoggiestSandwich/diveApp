//
//  AddDiversView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/15/23.
//

import SwiftUI
import CodeScanner

struct AddDiversView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isPresentingScanner = false
    @State var code: String = ""
    @State private var value = ""
    @State var scannedCode: String = ""
    
    struct Codes: Identifiable {
        let name: String
        let id = UUID()
    }
    struct dives {
        let name: String
        let degreeOfDiff: Float
    }
    
    struct divers {
        let name: String
        let school: String
        let dives: [dives]
        var diveNum: Int
    }
    
    var ScannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    self.isPresentingScanner = false
                    
                    let tempCodes = Codes(name: code.string)
                    value = tempCodes.name
                    if tempCodes.name != "" {
                        print(scannedCode)
                    }
        }})
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("No Divers Added")
                    .font(.largeTitle.bold())
                Spacer()
                Button {
                    //opens qr scanner to scan in divers
                    self.isPresentingScanner = true
                } label: {
                    Text("Add Divers")
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
                .sheet(isPresented: $isPresentingScanner) {
                    self.ScannerSheet
                }
                //moves to the score view once divers are entered and confirmed that official has verified it(needs to be added later)
                NavigationLink(destination: ScoreInfoView()) {
                    Text("Start Event")
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
            }
        }
    }
    
}

struct AddDiversView_Previews: PreviewProvider {
    static var previews: some View {
        AddDiversView()
    }
}
