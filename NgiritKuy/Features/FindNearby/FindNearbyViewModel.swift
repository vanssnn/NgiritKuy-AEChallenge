//
//  FindNearbyViewModel.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 15/05/25.
//

import SwiftUI
import Foundation

import GooglePlacesSwift
import CoreLocation
import MapKit

import Combine

enum FindNearbyViewState {
    case loading
    case loaded([NearbyStall])
    case error(PlacesError)
}

@MainActor
class FindNearbyViewModel: ObservableObject {
    
    private let placesClient = PlacesClient.shared
    private let locationManager = LocationManager.shared
    
    @Published var searchText: String = ""
    @Published var selectedRadiusInKm: Double = 1.0
    
    /// The currently-running search task; cancel it when inputs change.
    private var searchTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Text changes: 500 ms debounce
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] newText in
                guard let self = self else { return }
                self.performSearch(text: newText, radius: self.selectedRadiusInKm)
            }
            .store(in: &cancellables)

        
        $selectedRadiusInKm
            .removeDuplicates()
//            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] newRadius in
                guard let self = self else { return }
                self.performSearch(text: self.searchText, radius: newRadius)
            }
            .store(in: &cancellables)
    }
    
    @Published private(set) var state: FindNearbyViewState = .loading
    
    func onAppear() {
        locationManager.checkLocationAuthorization()
        performSearch(text: searchText, radius: selectedRadiusInKm)
    }
    
    func openDirectionInMap(displayName: String, location: CLLocationCoordinate2D) {
        let sourceMapItem = MKMapItem.forCurrentLocation()
        
        let destinationPlacemark = MKPlacemark(coordinate: location)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = displayName
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        
        MKMapItem.openMaps(
            with: [sourceMapItem, destinationMapItem],
            launchOptions: launchOptions
        )
    }
}

private extension FindNearbyViewModel {
    
    private func performSearch(text: String, radius: Double) {
        // cancel any ongoing work
        searchTask?.cancel()
            
        // start a new search Task
        searchTask = Task {
            await fetchPlaces(using: text, radius: radius)
        }
    }
    
    private func fetchPlaces(using text: String, radius: Double) async {
        state = .loading
        
        guard let center = locationManager.lastKnownLocation else {
            state = .error(.location("Location permission not granted"))
            return
        }
        
        let region = CircularCoordinateRegion(
            center: center,
            radius: Double(radius * 1_000)
        )
        
        // Choose request type
        let result: Result<[Place], PlacesError> = await {
            if text.isEmpty {
                let req = SearchNearbyRequest(
                    locationRestriction: region,
                    placeProperties: [.placeID, .displayName, .coordinate, .photos, .priceLevel],
                    includedTypes: [.restaurant, .cafe],
                    maxResultCount: 10
                )
                return await placesClient.searchNearby(with: req)
            } else {
                let req = SearchByTextRequest(
                    textQuery: text,
                    placeProperties: [.placeID, .displayName, .coordinate, .photos, .priceLevel],
                    locationBias: region,
                    includedType: .restaurant,
                    maxResultCount: 10,
                    isOpenNow: true
                )
                return await placesClient.searchByText(with: req)
            }
        }()
        
        switch result {
        case .failure(let error):
            state = .error(error)
        case .success(let places):
            // Filter out-of-range immediately, then fetch photos in parallel
            let inRange = places.filter { place in
                let loc = place.location
                let dist = CLLocation(latitude: loc.latitude, longitude: loc.longitude).distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))/1_000
                    
                return dist <= Double(radius)
            }
            
            // Now fetch images in parallel
            var stalls: [NearbyStall] = []
            
            for place in inRange {
                async let image: UIImage? = fetchFirstPlacePhotos(from: place)
                let dist = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude).distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude)) / 1_000
                
                let priceLevelString: String? = {
                    switch place.priceLevel {
                    case .unspecified, .free:        
                        return nil
                    case .inexpensive:
                        return "$"
                    case .moderate:                  
                        return "$$"
                    case .expensive:                 
                        return "$$$"
                    case .veryExpensive:             
                        return "$$$$"
                    @unknown default:               
                        return nil
                    }
                }()
                
                // Await the image after kicking off the fetch
                let stall = NearbyStall(
                    id: place.placeID ?? UUID().uuidString,
                    displayName: place.displayName ?? "Unknown",
                    location: place.location,
                    distanceInKm: dist,
                    image: await image,
                    priceLevelString: priceLevelString
                )
                
                stalls.append(stall)
            }
                    
            state = .loaded(stalls)
        }
        
    }
    
    func fetchFirstPlacePhotos(from place: Place) async -> UIImage? {
        guard let photo = place.photos?.first else { return nil }
        
        let request = FetchPhotoRequest(photo: photo, maxSize: CGSizeMake(512, 512))
        
        switch await placesClient.fetchPhoto(with: request) {
        case .success(let uiImage):
            return uiImage
        case .failure(let placesError):
            print("Error Fetching Photo: \(placesError)")
            return nil
        }
        
    }
}

