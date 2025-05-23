//
//  FindNearbyModel.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 16/05/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct NearbyStall: Identifiable {
    let id: String
    let displayName: String
    let location: CLLocationCoordinate2D
    let distanceInKm: CLLocationDistance
    let image: UIImage?
    let priceLevelString: String?
}
