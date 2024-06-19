//
//  FoodViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 14/05/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FoodViewModel: ObservableObject {
    // Published property to hold the list of foods:
    @Published var foods: [Food] = []
    
    // Initializer for the view model:
    init() {
        // Fetch foods when the view model is initialized:
        fetchFoods()
    }
    
    // Function to fetch food data from Firestore:
    func fetchFoods() {
        let db = Firestore.firestore()
        db.collection("food").getDocuments { (snapshot, error) in
            if let error = error {
                // Handle error if there is an issue fetching the data:
                print("Error fetching foods: \(error)")
                return
            }
            
            // Ensure there are documents in the snapshot:
            guard let documents = snapshot?.documents else {
                print("No foods found")
                return
            }
            
            // Decode the documents into Food objects and assign to the foods array:
            self.foods = documents.compactMap { try? $0.data(as: Food.self) }
            // Debug print to verify the fetched foods:
            print("Fetched foods: \(self.foods.map { $0.name })")
        }
    }
}
