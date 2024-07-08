//
//  AnnouncersQRCodeView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct AnnouncerQRCodeView: View {
    let context = CIContext() //sets the CI context
    let filter = CIFilter.qrCodeGenerator() //sets the CI filter
    var url: String //the string being encoded
    
    var body: some View {
        VStack {
            Text("Show to Announcer")
                .font(.largeTitle.bold())
            //qr image
            Image(uiImage: generateQRCodeImage(url)).interpolation(.none).resizable().frame(width: 300, height: 300, alignment: .center)
            Spacer()
        }
    }
    //generates the qr image from a string and returns it
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

struct AnnouncerQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncerQRCodeView(url: "")
    }
}
