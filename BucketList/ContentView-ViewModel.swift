//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Maximilian Berndt on 2023/04/15.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50,longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25)
        )
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        
        @Published var showingError = false
        @Published var errorTitle = ""
        @Published var errorMessage = ""
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newLocation = Location(
                id: UUID(),
                name: "New Location",
                description: "",
                latitude: mapRegion.center.latitude,
                longitude: mapRegion.center.longitude
            )

            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            guard
                let selectedPlace = selectedPlace,
                let index = locations.firstIndex(of: selectedPlace) else { return }
            locations[index] = location
            save()
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reasonString = "Please authenticate yourself to unlock your places."
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, authenticationError in
                    Task { @MainActor in
                        if success {
                            self.isUnlocked = true
                        } else {
                            self.errorTitle = "Failed to authenticate"
                            self.errorMessage = "Couldn't recognise the user of this app"
                            self.showingError = true
                        }
                    }
                }
            } else {
                Task { @MainActor in
                    self.errorTitle = "Failed to authenticate"
                    self.errorMessage = "No biometrics were found to authenticate with this app"
                    self.showingError = true
                }
            }
            
        }
    }
}
