//
//  BarcodeScannerView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 22/2/2024.
//

import SwiftUI
import VisionKit

@MainActor
struct BarcodeScannerView: UIViewControllerRepresentable {

    let onCodeTap: (String) -> Void
    let simulatedData: String

    init(onCodeTap: @escaping (String) -> Void, simulatedData: String = "") {
        self.onCodeTap = onCodeTap
        self.simulatedData = simulatedData
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        //
    }

    var scannerViewController: DataScannerViewController = DataScannerViewController(
        recognizedDataTypes: [.barcode(symbologies: [.code128])],
        qualityLevel: .accurate,
        recognizesMultipleItems: false,
        isHighFrameRateTrackingEnabled: false,
        isHighlightingEnabled: true
    )

    func makeUIViewController(context: Context) -> DataScannerViewController {
        scannerViewController.delegate = context.coordinator

        do {
            try scannerViewController.startScanning()
        } catch {
            onCodeTap(simulatedData)
        }

        return scannerViewController
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: BarcodeScannerView
        var roundBoxMappings: [UUID: UIView] = [:]

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        // DataScannerViewControllerDelegate - methods starts here
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // ToDo

        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // ToDo
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // ToDo
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let code):
                if let value = code.payloadStringValue {
                    parent.onCodeTap(value)
                }
            case .text(let text):
                parent.onCodeTap(text.transcript)
            @unknown default:
                print("Should not happen")
            }
        }
        // DataScannerViewControllerDelegate - methods ends here
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView(
            onCodeTap: { _ in }
        )
    }
}
