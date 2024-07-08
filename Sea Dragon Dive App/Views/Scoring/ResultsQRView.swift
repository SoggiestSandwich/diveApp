//
//  ResultsQRView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/20/23.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct ResultsQRView: View {
    let team: String //selected team
    
    let context = CIContext() //sets a CI context
    let filter = CIFilter.qrCodeGenerator() //sets a CI filter
    var code: String //the code that is encoded into qr code
    
    var body: some View {
        VStack {
            Text(team)
                .font(.largeTitle.bold())
            //qr code image
            Image(uiImage: generateQRCodeImage(code)).interpolation(.none).resizable().frame(width: 300, height: 300, alignment: .center)
            Spacer()
        }
    }
    //returns the qr code image
    func generateQRCodeImage(_ url: String) -> UIImage {
        let data = Data(url.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let qrCodeImage = filter.outputImage {
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        return UIImage(systemName: "xmark") ?? UIImage()
    }
}

struct ResultsQRView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsQRView(team: "Team", code: "")
    }
}
