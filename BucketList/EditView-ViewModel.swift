//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Maximilian Berndt on 2023/04/15.
//

import SwiftUI

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        enum LoadingState {
            case loading
            case loaded
            case failed
        }
        
        @Published var name: String
        @Published var description: String
        
        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()
        
        var location: Location
        
        init(location: Location) {
            self.location = location
            self.name = location.name
            self.description = location.description
        }
        
        func updatedLocation() -> Location {
            var newLocation = self.location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description

            return newLocation
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

            guard let url = URL(string: urlString) else {
                fatalError("Bad url string")
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(Result.self, from: data)
                Task { @MainActor in
                        pages = result.query.pages.values.sorted()
                        loadingState = .loaded
                }
            } catch {
                Task { @MainActor in
                    loadingState = .failed
                }
            }
            
        }
    }
}
