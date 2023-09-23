# QRKit

<img src="https://github.com/FlorianHubl/QRKit/blob/main/Logo.png" width="173" height="173">

Create and scan QRCodes quick in SwiftUI.

## Creating QR Code

```swift
import SwiftUI
import QRKit

struct ContentView: View {
    var body: some View {
        QRCode(data: "QRCodes are fun :D")
            .padding()
    }
}
```

## Scanning QR Code

Make sure that you enable the camera in the settings.

```swift
import SwiftUI
import QRKit

struct ContentView: View {
    var body: some View {
            QRScannerView(refreshRate: 1) { qr in
                print(qr)
            }
        .ignoresSafeArea()
    }
}
```
