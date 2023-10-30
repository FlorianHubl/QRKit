import SwiftUI
import VisionKit

public enum ScanType {
    case qr
    case text
}

#if os(iOS)

@available(iOS 16.0, *)
public struct QRScannerView: UIViewControllerRepresentable {
    
    @StateObject private var delegate: ScannerDelegate
    
    let type: ScanType
    
    public init(refreshRate: Double, result: @escaping (String) -> Void) {
        self._delegate = StateObject(wrappedValue: ScannerDelegate(result: result, refreshRate: refreshRate))
        self.type = .qr
    }
    
    public init(result: @escaping (String) -> Void) {
        self._delegate = StateObject(wrappedValue: ScannerDelegate(result: result))
        self.type = .qr
    }
    
    public init(type: ScanType, result: @escaping (String) -> Void) {
        self._delegate = StateObject(wrappedValue: ScannerDelegate(result: result))
        self.type = type
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [type == .qr ? .barcode(symbologies: [.qr]) : .text()],
            qualityLevel: .fast,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true)
        viewController.delegate = delegate
        try? viewController.startScanning()
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    class ScannerDelegate: DataScannerViewControllerDelegate, ObservableObject {
        
        let result: (String) -> ()
        
        let refreshRate: Double?
        
        var scannable = true
        
        init(result: @escaping (String) -> (), refreshRate: Double) {
            self.result = result
            self.refreshRate = refreshRate
        }
        
        init(result: @escaping (String) -> ()) {
            self.result = result
            self.refreshRate = nil
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            switch updatedItems.first {
            case .barcode(let qrCode):
                if refreshRate != nil {
                    guard scannable else {return}
                    scannable = false
                }
                result((qrCode.payloadStringValue == nil ? "" : qrCode.payloadStringValue)!)
                if let refreshRate = refreshRate {
                    Timer.scheduledTimer(withTimeInterval: refreshRate, repeats: false) { _ in
                        self.scannable = true
                    }
                }
            case .text(let text):
                result((text.transcript))
            case .none:
                break
            case .some(_):
                break
            }
        }
    }
}

#endif
