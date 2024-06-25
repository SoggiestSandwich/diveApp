//
//  CoachEntryQRCodeView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/16/23.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct CoachEntryQRCodeView: View {
    let context = CIContext() //initializes a CIContext
    let filter = CIFilter.qrCodeGenerator() //initializes a CIFilter
    var code: String //the code being turned into a qr code
    
    var body: some View {
        VStack {
            Text("Dive Event")
                .font(.largeTitle.bold())
            //qr image
            Image(uiImage: generateQRCodeImage(code)).interpolation(.none).resizable().frame(width: 300, height: 300, alignment: .center)
            Spacer()
        }
    }
    //takes in a string and returns a qr image for that string
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

struct CoachEntryQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CoachEntryQRCodeView(code: "https://youtu.be/dQw4w9WgXcQ")
    }
}
