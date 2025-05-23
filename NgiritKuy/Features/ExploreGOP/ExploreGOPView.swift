//
//  ExploreGOPView.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 18/05/25.
//

import SwiftUI

struct ExploreGOPView: View {
    
    @StateObject var viewModel = ExploreGOPViewModel()
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                switch viewModel.state {
                
                case .loading:
                    Spacer(minLength: 250)
                    ProgressView("😁 Loading...")
                        .padding(.horizontal, 20)
                case .loaded(let area):
                    LazyVStack(spacing: 20) {
                        ForEach(area.subAreas, id:\.id) {subArea in
                            GOPSubAreaSection(viewModel: viewModel, subArea: subArea)
                        }
                    }
                    
                    
                    
                case .error(let loadFromJsonError):
                    Spacer(minLength: 250)
                    Text("🛑 \(loadFromJsonError.localizedDescription)")
                        .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Explore GOP")
//            .scrollTargetBehavior(.viewAligned)
        }
        .accentColor(.orange)
        .onAppear {
            viewModel.onAppear()
        }
        
    }
}

#Preview {
    ExploreGOPView()
}

struct StallCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let priceLevelString: String
    let name: String
    let imageName: String?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let image = imageName {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 360, height: 220)
                    .clipped()
                    .allowsHitTesting(false)
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(priceLevelString)
                        .font(.title.bold())
                        
                    Text(String(repeating: "$", count: 4 - priceLevelString.count))
                        .font(.title.bold())
                        .foregroundColor(.gray)
                        
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(name)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(.thinMaterial)
        }
        .frame(width: 360)
        .background(colorScheme == .dark ? Color.black.gradient : Color.white.gradient)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

struct GOPSubAreaSection: View {
    
    @ObservedObject var viewModel: ExploreGOPViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    let subArea: SubArea
    
    var body: some View {
        LazyVStack(spacing: 20) {
            
            HStack(alignment: .bottom){
                Label(subArea.name, systemImage: "map.fill")
                    
                Spacer()
                
                Button {
                    viewModel.openDirectionInMap(name: subArea.name, latitude: subArea.latitude, longitude: subArea.longitude)
                   
                    
                } label: {
                    Label("Locate Me", systemImage: "location.fill")
                        .accentColor(.indigo)
                }
                
                
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            
            
            
            ForEach(subArea.stalls, id:\.id) {stall in
                
                NavigationLink {
                    ExploreGOPDetailView(viewModel: viewModel, stall: stall, subAreaName: subArea.name, latitude: subArea.latitude, longitude: subArea.longitude)
                } label: {
                    StallCard(priceLevelString: stall.priceLevelString.rawValue, name: stall.name, imageName: stall.imageName)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Divider()

        }
//        .scrollTargetLayout()
    }
}

struct ExploreGOPDetailView: View {
    
    @ObservedObject var viewModel: ExploreGOPViewModel
    
    var stall: Stall
    var subAreaName: String
    var latitude: Double
    var longitude: Double
    
    var body: some View {
        
        ScrollView {
            if let image = stall.imageName {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .allowsHitTesting(false)
            }
            
            VStack{
                
                HStack(spacing: 0) {
                    Text(stall.priceLevelString.rawValue)
                        .font(.system(size: 46, weight: .bold))
                    
                    Text(String(repeating: "$", count: 4 - stall.priceLevelString.rawValue.count))
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.gray)
                    
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(stall.description)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack{
                    Divider()
                        .padding(.vertical, 10)
                    Label(subAreaName, systemImage: "map.fill")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        viewModel.openDirectionInMap(name: subAreaName, latitude: latitude, longitude: longitude)
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
                    Divider()
                        .padding(.vertical, 10)
                }
                .padding(.vertical, 10)
                
                VStack(spacing: 8) {
                    Text("Menu")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVStack(spacing: 20) {
                        ForEach(stall.items, id:\.id) {item in
                            StallItemCard(priceInK: item.priceInK, name: item.name, description: item.description, imageName: item.imageName)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
        }
        .navigationTitle(stall.name)
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}

struct ExploreGOPDetailSnippetView: View {
    
    var stall: Stall
    var subAreaName: String
    let limit: Int = 10
    
    var body: some View {
        
        VStack {
            if let image = stall.imageName {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .allowsHitTesting(false)
            }
            
            VStack{
                
                HStack(spacing: 0) {
                    Text(stall.priceLevelString.rawValue)
                        .font(.system(size: 46, weight: .bold))
                    
                    Text(String(repeating: "$", count: 4 - stall.priceLevelString.rawValue.count))
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.gray)
                    
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(stall.name)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(stall.description)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack{
                    
                    Label(subAreaName, systemImage: "map.fill")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding(.vertical, 10)
                
                VStack(spacing: 4) {
                    Text("Menu")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVStack(spacing: 14) {
                        ForEach(stall.items.prefix(limit), id:\.id) {item in
                            StallItemCard(priceInK: item.priceInK, name: item.name, description: item.description, imageName: item.imageName)
                        }
                    }
                    
                    if stall.items.count > limit {
                        Text("...and another \(stall.items.count - limit) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            
        }
    }
}

struct StallItemCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let priceInK: Double
    let name: String
    let description: String
    var imageName: String?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 360, height: 400)
                    .clipped()
                    .allowsHitTesting(false)
            }
            
            VStack(alignment: .leading) {
                
                Text("\(priceInK == floor(priceInK) ? String(format: "%.0f", priceInK) : String(format: "%.1f", priceInK))k")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(name)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(.thinMaterial)
        }
        .frame(width: 360)
        .background(colorScheme == .dark ? Color.black.gradient : Color.white.gradient)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

