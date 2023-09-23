import SwiftUI
import VisionKit


@available(iOS 16.0, *)
public struct QRScannerView: UIViewControllerRepresentable {
    
    @StateObject private var delegate: ScannerDelegate
    
    init(refreshRate: Double, result: @escaping (String) -> Void) {
        self._delegate = StateObject(wrappedValue: ScannerDelegate(result: result, refreshRate: refreshRate))
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
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
        
        let refreshRate: Double
        
        var scannable = true
        
        init(result: @escaping (String) -> (), refreshRate: Double) {
            self.result = result
            self.refreshRate = refreshRate
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            switch updatedItems.first {
            case .barcode(let qrCode):
                guard scannable else {return}
                scannable = false
                result((qrCode.payloadStringValue == nil ? "" : qrCode.payloadStringValue)!)
                Timer.scheduledTimer(withTimeInterval: refreshRate, repeats: false) { _ in
                    self.scannable = true
                }
            case .none:
                break
            case .some(_):
                break
            }
        }
    }
}

