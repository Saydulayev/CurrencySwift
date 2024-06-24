//
//  CurrencySwiftApp.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import SwiftUI

@main
struct CurrencySwiftApp: App {
    @StateObject private var viewModel = CurrencyViewModel(
        currencyService: CurrencyService.shared,
        sortingStrategy: FavoriteFirstSortingStrategy()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onAppear {
                    if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
                       let appTheme = AppTheme(rawValue: savedTheme) {
                        viewModel.applyTheme(appTheme)
                    }
                }
        }
    }
}

