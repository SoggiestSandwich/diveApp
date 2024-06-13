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
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var url: String
    
    var body: some View {
        VStack {
            Text("Show to Announcer")
                .font(.largeTitle.bold())
            
            Image(uiImage: generateQRCodeImage(url)).interpolation(.none).resizable().frame(width: 300, height: 300, alignment: .center)
            Spacer()
        }
    }
    
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
