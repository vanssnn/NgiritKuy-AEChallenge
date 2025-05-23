//
//  FindNearByView.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 15/05/25.
//

import SwiftUI

import GooglePlacesSwift
import CoreLocation

struct FindNearbyView: View {
    
    @StateObject var viewModel = FindNearbyViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("Show results less than ")
                    Picker("Show results less than", selection: $viewModel.selectedRadiusInKm) {
                        Text("1 km").tag(1.0)
                        Text("2 km").tag(2.0)
                        Text("3 km").tag(3.0)
                        Text("5 km").tag(5.0)
                        Text("10 km").tag(10.0)
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .padding(.horizontal, -14)
                    .accentColor(.orange)
                    Text("away")
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                
                
                switch(viewModel.state){
                    
                case .loading:
                    Spacer(minLength: 250)
                    ProgressView("🔍 Searching...")
                        .padding(.horizontal, 20)
                    
                case .loaded(let stalls):
                    if stalls.count == 0 {
                        Spacer(minLength: 250)
                        Text("😭 No stalls found nearby")
                            .padding(.horizontal, 20)
                    }
                    
                    LazyVStack(spacing: 20) {
                        ForEach(stalls, id:\.id) {stall in
                            NearbyStallCard(
                                viewModel: viewModel,
                                image: stall.image,
                                priceLevelString: stall.priceLevelString,
                                displayName: stall.displayName,
                                distanceInKm: stall.distanceInKm,
                                
                                location: stall.location
                            )

                        }
                    }
                    .scrollTargetLayout()
                    
                    
                case .error(let placesError):
                    Spacer(minLength: 250)
                    Text("🛑 \(placesError.localizedDescription)")
                        .padding(.horizontal, 20)
                }
                Spacer()
            }
            .navigationTitle("Find Nearby Stalls")
            .scrollTargetBehavior(.viewAligned)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "What do you want to eat?"
        )
    }
    
}
    

#Preview {
    FindNearbyView()
}

struct NearbyStallCard: View {
    
    @ObservedObject var viewModel: FindNearbyViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    let image: UIImage?
    let priceLevelString: String?
    let displayName: String
    let distanceInKm: Double
    
    let location: CLLocationCoordinate2D
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 360, height: 380)
                    .clipped()
                    .allowsHitTesting(false)
            }
            
            VStack(alignment: .leading) {
                if let price = priceLevelString {
                    HStack(spacing: 0) {
                        Text(price)
                            .font(.title.bold())
                            
                        Text(String(repeating: "$", count: 4 - price.count))
                            .font(.title.bold())
                            .foregroundColor(.gray)
                            
                    }
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text(displayName)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String(format: "%.1f km away from you", distanceInKm))
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    viewModel.openDirectionInMap(displayName: displayName, location: location)
                    
                } label: {
                    Label("Locate Me", systemImage: "location.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
                
            }
            
            .padding(.horizontal, 12)
            .padding(.vertical, 20)
            
            .background(.thinMaterial)
        }
        .frame(width: 360)
        .background(colorScheme == .dark ? Color.black.gradient : Color.white.gradient)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        
    }
}
