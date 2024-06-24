//
//  CurrencyServiceProtocol.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import Combine

protocol CurrencyServiceProtocol {
    func fetchRates(base: String) -> AnyPublisher<CurrencyData, Error>
    func fetchHistoricalRates(base: String, year: Int, month: Int, day: Int) -> AnyPublisher<ExchangeRatesResponse, Error>
}

