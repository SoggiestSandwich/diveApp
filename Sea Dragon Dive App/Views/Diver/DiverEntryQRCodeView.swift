//
//  DiverEntryQRCodeView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/28/23.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct DiverEntryQRCodeView: View {
    let context = CIContext() //initializes a CIContext
    let filter = CIFilter.qrCodeGenerator() //initializes a CIFilter
    var code: String //the code being turned into a qr code
    
    var body: some View {
        VStack {
            Text("Show this to your coach to scan")
                .font(.title2.bold())
                .padding(.top)
            Spacer()
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

struct DiverEntryQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        //QR code can hold
        //5596 numbers = 1
        //2331 lowercase letters and commas and qoutation marks and square brackets and curly brackets = 2.4
        //3391 periods and capital letters and colon and spaces = 1.65
        DiverEntryQRCodeView(code: "https://youtu.be/dQw4w9WgXcQ?si=poHwJA-FivrKgRrl")
    }
}
