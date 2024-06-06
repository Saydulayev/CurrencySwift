//
//  Model.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import Foundation

struct CurrencyData: Codable {
    let baseCode: String
    let conversionRates: [String: Double]
    let timeLastUpdateUTC: String

    enum CodingKeys: String, CodingKey {
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
        case timeLastUpdateUTC = "time_last_update_utc"
    }
}


struct CurrencyRate: Identifiable {
    let id = UUID()
    let code: String
    let rate: Double
    var isFavorite: Bool
    let country: String
}

