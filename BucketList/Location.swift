//
//  Location.swift
//  BucketList
//
//  Created by Maximilian Berndt on 2023/04/14.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var description: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
       return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static let example = Location(
        id: UUID(),
        name: "Buckingham Palace",
        description: "Where Queen Elizabeth lived with her dorgis",
        latitude: 51.501,
        longitude: -0.141
    )
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}
