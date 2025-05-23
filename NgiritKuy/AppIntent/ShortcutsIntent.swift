//
//  CoffeeType.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 17/05/25.
//

import SwiftUI
import AppIntents


public struct ValidationError: LocalizedError {
    public let localizedDescription: String
    public init(_ description: String) { self.localizedDescription = description }
}


// MARK: -- Step 2: Make Your App Intent Accessible in Your Device Here
struct AppIntentShortcutProvider: AppShortcutsProvider {
    
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: PickAStallIntent(),
                    phrases: ["Pick a stall in \(.applicationName)"],
                    shortTitle: "Pick a stall", systemImageName: "dice.fill")
    }
    
}


// MARK: -- Step 1: Create Your App Intent Here
struct PickAStallIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Pick a stall"
    static var description = IntentDescription("Automatically pick a stall for you")
    
    
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        
        let allStalls = try ExploreGOPViewModel.loadAllStallsWithSubAreaName()
        
        guard let chosen = allStalls.randomElement() else {
            throw ValidationError("No available stalls.")
        }
        
        return .result(
            view: ExploreGOPDetailSnippetView(stall: chosen.0, subAreaName: chosen.1)
        )
    }
    

}
