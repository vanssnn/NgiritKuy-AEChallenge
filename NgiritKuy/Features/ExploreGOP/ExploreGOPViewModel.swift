//
//  ExploreGOPViewModel.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 18/05/25.
//


import Foundation
import SwiftUI
import CoreLocation
import MapKit

enum LoadFromJsonError: Error, LocalizedError {
    case fileNotFound
    case decodingError(errorMessage: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Data file not found"
        case .decodingError(let errorMessage):
            return "Failed to decode the response: \(errorMessage)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}


enum ExploreGOPState {
    case loading
    case loaded(Area)
    case error(LoadFromJsonError)
}

final class ExploreGOPViewModel: ObservableObject {
    
    @Published private(set) var state: ExploreGOPState = .loading

    func onAppear() {
        updateState(.loading)

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
                updateState(.error(.fileNotFound))
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let rootArea = try decoder.decode(Area.self, from: data)
                updateState(.loaded(rootArea))
            } catch {
                updateState(.error(.decodingError(errorMessage: error.localizedDescription)))
            }
        }
    }
    
    func openDirectionInMap(name: String, latitude: Double, longitude: Double) {
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let sourceMapItem = MKMapItem.forCurrentLocation()
        
        let destinationPlacemark = MKPlacemark(coordinate: location)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = name
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        
        MKMapItem.openMaps(
            with: [sourceMapItem, destinationMapItem],
            launchOptions: launchOptions
        )
    }
    
    static func loadAllStallsWithSubAreaName() throws -> [(Stall, String)] {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            throw LoadFromJsonError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let root = try decoder.decode(Area.self, from: data)
        
        // 3. Build tuple array in one pass
        var result: [(Stall, String)] = []
        result.reserveCapacity(root.subAreas.reduce(0) { $0 + $1.stalls.count })
                
        for subArea in root.subAreas {
            for stall in subArea.stalls {
                result.append((stall, subArea.name))
            }
        }
                
        return result
    }
}

private extension ExploreGOPViewModel {
    func updateState(_ state: ExploreGOPState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}
