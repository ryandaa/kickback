import SwiftUI
import UIKit

struct CameraCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var capturedImages: [UIImage]
    @State private var showCamera = false
    @State private var tempImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(capturedImages.enumerated()), id: \.offset) { idx, img in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(12)
                                Button(action: {
                                    capturedImages.remove(at: idx)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                        if capturedImages.count < 10 {
                            Button(action: { showCamera = true }) {
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 80, height: 80)
                                .background(Color(hex: "#E3E7DF"))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
                Button(action: {
                    // Next: for now, just print
                    print("Posting images: \(capturedImages.count)")
                    dismiss()
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(Color(hex: "#7B8C6A"))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#F5F7F2"))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationBarTitle("Add Photos", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera) { img in
                    if capturedImages.count < 10 {
                        capturedImages.append(img)
                    }
                    showCamera = false
                }
            }
        }
    }
}

// MARK: - ImagePicker Wrapper

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .camera
    var completion: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
} 