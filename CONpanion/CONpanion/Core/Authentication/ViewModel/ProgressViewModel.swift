//
//  ProgressViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 11/05/2024.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import Combine

class ProgressViewModel: ObservableObject {
    @Published var progressRecords = [Progress]()
    @Published var showAddToday = true
    @Published var currentDate = Date()
    
    private var db = Firestore.firestore()
    
    // Fetch progress records for a specific user and date:
    func fetchProgress(for userId: String, date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        print("Fetching progress from \(startOfDay) to \(endOfDay) for user \(userId)")

        db.collection("progress")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("timestamp", isLessThan: endOfDay)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching progress records: \(error.localizedDescription)")
                    self.progressRecords.removeAll()
                    self.showAddToday = self.isToday()
                } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    self.progressRecords = snapshot.documents.compactMap { document in
                        try? document.data(as: Progress.self)
                    }
                    print("Found \(self.progressRecords.count) records")
                    self.showAddToday = false
                } else {
                    print("No records found")
                    self.progressRecords.removeAll()
                    self.showAddToday = self.isToday()
                }
            }
    }

    // Update the weight for a specific progress record:
    func updateWeight(for progressId: String, newWeight: String) {
        db.collection("progress").document(progressId).updateData(["currentWeight": newWeight]) { error in
            if let error = error {
                print("Error updating weight: \(error.localizedDescription)")
            } else {
                self.fetchProgress(for: Auth.auth().currentUser?.uid ?? "", date: self.currentDate)
            }
        }
    }

    // Move the current date by a specified number of days:
    func moveDate(by days: Int) {
        currentDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? Date()
        fetchProgress(for: Auth.auth().currentUser?.uid ?? "", date: currentDate)
    }

    /// Upload an image to Firebase Storage and return the URL.
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            completion(nil)
            return
        }

        print("User is authenticated with UID: \(user.uid)")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child("progressPictures/\(UUID().uuidString).jpg")

        imgRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Failed to upload image: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }

            imgRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Download URL not found")
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }

    // Save a new progress record to Firestore:
    func saveProgress(pictureURL: String, weight: String, date: Date) {
        let userId = Auth.auth().currentUser?.uid ?? ""
        let newProgress = Progress(pictureURL: pictureURL, currentWeight: weight, timestamp: date, userId: userId)
        
        do {
            let _ = try db.collection("progress").addDocument(from: newProgress)
        } catch {
            print("Error saving progress: \(error.localizedDescription)")
        }
    }

    // Fetch the most recent weight record before a specific date for a user:
    func fetchMostRecentWeight(before date: Date, userId: String, completion: @escaping (Progress?) -> Void) {
        db.collection("progress")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isLessThan: date)
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    let progress = try? document.data(as: Progress.self)
                    completion(progress)
                } else {
                    completion(nil)
                }
            }
    }

    // Check if the current date is today:
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(currentDate)
    }

    // Update the user's weight in Firestore:
    func updateCurrentUserWeight(weight: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let userRef = db.collection("users").document(userId)
        userRef.updateData(["weightKG": weight]) { error in
            if let error = error {
                print("Error updating user weight: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // Save progress and update the user's weight in Firestore:
    func saveProgressAndUserWeight(pictureURL: String, weight: String, date: Date, completion: @escaping () -> Void) {
        let newProgress = Progress(pictureURL: pictureURL, currentWeight: weight, timestamp: date, userId: Auth.auth().currentUser?.uid ?? "")
        
        do {
            let _ = try db.collection("progress").addDocument(from: newProgress) { error in
                if let error = error {
                    print("Error saving progress: \(error.localizedDescription)")
                } else {
                    self.fetchProgress(for: Auth.auth().currentUser?.uid ?? "", date: date)
                    completion()
                }
            }
        } catch {
            print("Error preparing to save progress: \(error.localizedDescription)")
        }
    }
}

