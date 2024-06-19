//
//  ExercisesViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/04/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

// ViewModel for managing exercises data:
class ExercisesViewModel: ObservableObject{
    
    // Empty list array that is defined in 'Exercises' Model file:
    @Published var list = [Exercises]()
    
    // Function that fetches data items from Firestore to store in empty list array:
    func getData(){
        
        // Get database reference:
        let db = Firestore.firestore()
        
        // Read documents from database:
        db.collection("exercises").getDocuments { snapshot, error in
            
            // Check for errors:
            if error == nil {
                // No error:
                if let snapshot = snapshot {
                    
                    // Update the list property in main thread:
                    DispatchQueue.main.async {
                        // Get all documents and create exercises list:
                        self.list = snapshot.documents.map { d in
                            
                            // Create an Exercise item for each document returned from Firestore:
                            return Exercises(
                                id: d.documentID,
                                Name: d["Name"] as? String ?? "",
                                PrimaryMuscle: d["PrimaryMuscle"] as? String ?? "",
                                SecondaryMuscle: d["SecondaryMuscle"] as? String ?? "",
                                Compound: (d["Compound"] as? Bool ?? false),
                                Description: d["Description"] as? String ?? "",
                                gifURL: d["gifURL"] as? String ?? "" // Fetch the gifURL field:
                            )
                        }
                    }
                }
            } else {
                // Handle error:
                print("Error fetching documents: \(String(describing: error))")
            }
        }
    }
}
