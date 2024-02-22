//
//  MediaPicker.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/2/2024.
//

import SwiftUI
import PhotosUI

struct MediaPicker<Label: View>: View {

    @ViewBuilder let label: Label

    var image: Binding<UIImage?>
    @State private var isConfirmationDialogPresented = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: SourceType = .camera

    init(image: Binding<UIImage?>, @ViewBuilder label: () -> Label) {
        self.image = image
        self.label = label()
    }

    enum SourceType {
        case camera
        case photoLibrary
    }

    var body: some View {
        Button {
            isConfirmationDialogPresented = true
        } label: {
            label
        }
        .confirmationDialog("Choose an option", isPresented: $isConfirmationDialogPresented) {
            Button("Camera") {
                sourceType = .camera
                isImagePickerPresented = true
            }
            Button("Photo Library") {
                sourceType = .photoLibrary
                isImagePickerPresented = true
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            switch sourceType {
            case .camera:
                ImagePicker(isPresented: $isImagePickerPresented, image: image, sourceType: .camera)
            case .photoLibrary:
                PhotoPicker(selectedImage: image)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first {
                result .itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = uiImage
                        }
                    }

                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }

    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        var configuration = PHPickerConfiguration()

        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}

struct MediaPicker_Previews: PreviewProvider {
    static var previews: some View {
        MediaPicker(image: .constant(nil)) {
            EmptyView()
        }
    }
}
