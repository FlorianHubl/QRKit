import SwiftUI
import CoreImage.CIFilterBuiltins

@available(iOS 15.0.0, *)
public struct QRCode: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var qrCode: Image?
    
    @State private var copyed = false
    
    @State private var doneCreating = false
    
    let copyable: Bool
    
    let animate: Bool
    
    let data: Data
    
    public init(data: Data, copyable: Bool? = nil, animate: Bool? = nil) {
        self.copyable = copyable ?? false
        self.data = data
        self.animate = animate ?? false
    }
    
    public init(data: String, copyable: Bool? = nil, animate: Bool? = nil) {
        self.copyable = copyable ?? false
        self.data = data.data(using: .utf8)!
        self.animate = animate ?? false
    }
    
    public var body: some View {
        VStack {
            if doneCreating {
                if let qrCode = qrCode {
                    qrCode
                        .resizable()
                        .scaledToFit()
                        .transition(animate ? .opacity : .identity)
                        .opacity(copyed ? 0.7 : 1)
                        .overlay {
                            RoundedRectangle(cornerRadius: 17)
                                .foregroundColor(.white)
                                .overlay {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20)
                                            .foregroundColor(colorScheme == .light ? .black : .black)
                                        Text("copyed")
                                            .foregroundColor(colorScheme == .light ? .black : .black)
                                    }
                                }
                                .opacity(copyed ? 1 : 0)
                                .scaleEffect(copyed ? 1 : 0.7)
                                .frame(height: 100)
                                .padding(.horizontal, 50)
                                .shadow(radius: 1)
                        }
                        .animation(.spring(), value: copyed)
                        .onTapGesture {
                            if copyable {
                                UIPasteboard.general.string = String(data: data, encoding: .utf8)
                                copyed = true
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                                    copyed = false
                                }
                            }
                        }
                }else {
                    Text("Error while creating QR Code")
                        .font(.title)
                }
            }
        }
        .task {
            do {
                try qrCode = createQRCode(from: data)
            }catch {
                print("Error while creating QR Code")
            }
            doneCreating = true
        }
        .onChange(of: data) { newValue in
            do {
                try qrCode = createQRCode(from: newValue)
            }catch {
                print("Error while creating QR Code")
            }
        }
        .animation(.easeInOut(duration: animate ? 0.7 : 0.0), value: qrCode)
    }
}

public enum QRKitError: Error {
    case error(String)
}

@available(iOS 13.0, *)
func createQRCode(from data: Data) throws -> Image {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.setValue(data, forKey: "inputMessage")
    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return Image(uiImage: UIImage(cgImage: cgimg)).interpolation(.none)
        }else {
            print("One")
        }
    }else {
        print("Here")
    }
    throw QRKitError.error("Error in creating QRCode")
}

