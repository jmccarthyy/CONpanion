//
//  ProgressView.swift
//  CONpanion
//
//  Created by jake mccarthy on 11/05/2024.
//

import Firebase
import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

struct ProgressView: View {
    @EnvironmentObject var viewModel: ProgressViewModel
    @State private var showingAddProgress = false
    @State private var inputImage: UIImage?
    @State private var currentWeight: String = ""

    var body: some View {
        VStack {
            // Display the date navigation controls at the top:
            DateNavigation(viewModel: viewModel)
            
            Spacer() // Add a spacer to push the rest of the content down

            // Check if there are any progress records for the selected date:
            if viewModel.progressRecords.isEmpty {
                // If there are no records for today, show the add button:
                if viewModel.isToday() {
                    Button(action: {
                        showingAddProgress = true
                    }) {
                        Text("Add Today's Weight")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                } else {
                    // Show a message for past days with no data:
                    Text("There is no data for this day.")
                        .padding()
                }
            } else if let progress = viewModel.progressRecords.first {
                // If there are records, display the details for the first record:
                ProgressDetailsView(progress: progress, date: viewModel.currentDate, isToday: viewModel.isToday())
            }

            Spacer() // Add another spacer for better layout
        }
        .sheet(isPresented: $showingAddProgress) {
            // Show the AddProgressView sheet when showingAddProgress is true:
            AddProgressView(inputImage: $inputImage, currentWeight: $currentWeight)
                .environmentObject(viewModel)
        }
        .onAppear {
            // Fetch progress records for the current user when the view appears:
            viewModel.fetchProgress(for: Auth.auth().currentUser?.uid ?? "", date: viewModel.currentDate)
        }
        .onChange(of: viewModel.progressRecords) { _ in
            // Trigger a view update when progressRecords changes:
        }
        .onChange(of: viewModel.currentDate) { newDate in
            // Fetch new data when the currentDate changes:
            viewModel.fetchProgress(for: Auth.auth().currentUser?.uid ?? "", date: newDate)
        }
    }
}

struct DateNavigation: View {
    @ObservedObject var viewModel: ProgressViewModel

    var body: some View {
        HStack {
            // Button to navigate to the previous day:
            Button(action: { viewModel.moveDate(by: -1) }) {
                Image(systemName: "arrow.left")
            }
            Spacer()
            // Display the current date:
            Text("\(viewModel.currentDate, formatter: DateFormatter.dateOnly)")
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            // Button to navigate to the next day (disabled if it's today):
            Button(action: {
                if !viewModel.isToday() {
                    viewModel.moveDate(by: 1)
                }
            }) {
                Image(systemName: "arrow.right")
            }
            .disabled(viewModel.isToday()) // Disable future dates
        }
        .padding()
    }
}

struct ProgressDetailsView: View {
    var progress: Progress
    var date: Date
    var isToday: Bool

    var body: some View {
        VStack {
            // Display the progress picture for today or a specific date:
            Text(isToday ? "Today's progress picture:" : "Progress Picture from \(date.formattedWithOrdinal()):")
            WebImage(url: URL(string: progress.pictureURL))
                .resizable()
                .scaledToFit()
            // Display the weight for today or a specific date:
            Text(isToday ? "Today's weight:" : "Weight on the \(date.formattedWithOrdinal()):")
            Text(progress.currentWeight)
        }
    }
}

extension Date {
    func formattedWithOrdinal() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        let day = Int(formatter.string(from: self)) ?? 0
        
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: self)
        
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: self)
        
        return "\(day)\(suffix) \(month) \(year)"
    }
}

extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

struct AddProgressView: View {
    @Binding var inputImage: UIImage?
    @Binding var currentWeight: String
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: ProgressViewModel
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = inputImage {
                    // Display the selected image:
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    // Show button to select an image:
                    Button("Select Picture") {
                        showingImagePicker = true
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // TextField to enter the current weight:
                TextField("Enter your weight", text: $currentWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Button to upload the picture and weight:
                Button("Upload Picture and Weight") {
                    guard let image = inputImage else {
                        print("No image selected")
                        return
                    }
                    viewModel.uploadImage(image) { url in
                        if let imageUrl = url {
                            viewModel.saveProgressAndUserWeight(pictureURL: imageUrl, weight: currentWeight, date: Date()) {
                                // Dismiss the view after uploading:
                                DispatchQueue.main.async {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } else {
                            print("Failed to upload image")
                        }
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .navigationTitle("Add Progress")
            .toolbar {
                // Cancel button to dismiss the view:
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                PhotoPicker(image: $inputImage)
            }
        }
    }
    
    // Load and resize the selected image:
    func loadImage() {
        guard let image = inputImage else {
            print("No image is selected.")
            return
        }
        
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 800, height: 800))
        inputImage = resizedImage
        print("Image is resized and loaded successfully.")
    }
    
    // Resize an image to the specified target size:
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

