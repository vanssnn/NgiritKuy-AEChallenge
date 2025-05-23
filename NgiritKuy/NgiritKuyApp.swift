//
//  NgiritKuy2App.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 14/05/25.
//

import SwiftUI
import GooglePlacesSwift

@main
struct NgiritKuyApp: App {
    init() {
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else {
            fatalError("Info.plist not found")
        }
        guard let apiKey: String = infoDictionary["API_KEY"] as? String else {
            // To use GooglePlacesDemos, please register an API Key for your application. Your API Key
            // should be kept private and not be checked in.
            //
            // Create an xcconfig file for your API key. By default the file should be named
            // "GooglePlacesDemos.xcconfig" and be located at the same directory level as the demo
            // application's "Info.plist" file. The contents of this file should contain at least a line
            // like `API_KEY = <insert your API key here>`.
            //
            // See documentation on getting an API Key for your API Project here:
            // https://developers.google.com/places/ios-sdk/start#get-key
            fatalError("API_KEY not set in Info.plist")
        }
        let _ = PlacesClient.provideAPIKey(apiKey)
        
        // Log the required open source licenses! Yes, just NSLog-ing them is not enough but is good
        // for a demo.
        print("Google Places Swift open source licenses:\n%@", PlacesClient.openSourceLicenseInfo)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
