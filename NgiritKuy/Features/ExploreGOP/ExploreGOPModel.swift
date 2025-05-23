//
//  ExploreGOPModel.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 17/05/25.
//

import Foundation
import SwiftUI

enum StallTag: String, CaseIterable, Codable {
    case indonesian = "Indonesian"
    case western = "Western"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case korean = "Korean"
    case javanese = "Javanese"
    case sundanese = "Sundanese"
}

enum StallPriceLevelString: String, CaseIterable, Codable {
    case inexpensive = "$"
    case moderate = "$$"
    case expensive = "$$$"
    case veryExpensive = "$$$$"
}

struct Area: Identifiable, Codable{
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var imageName: String?
    var subAreas: [SubArea] = []
    
    private enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, imageName, subAreas
    }
}

struct SubArea: Identifiable, Codable{
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var stalls: [Stall] = []
    
    private enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, stalls
    }
}

struct Stall: Identifiable, Codable{
    var id: UUID = UUID()
    var priceLevelString: StallPriceLevelString
    var name: String
    var description: String
    var imageName: String?
    var items: [StallItem] = []
    
    private enum CodingKeys: String, CodingKey {
        case priceLevelString, name, description, imageName, items
    }
}

struct StallItem: Identifiable, Codable {
    var id: UUID = UUID()
    var priceInK: Double
    var name: String
    var description: String
    var imageName: String?
    
    private enum CodingKeys: String, CodingKey {
        case priceInK, name, description, imageName
    }
}


