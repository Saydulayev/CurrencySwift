//
//  CurrencyViewModel.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import Foundation
import Combine


class CurrencyViewModel: ObservableObject {
    @Published var currencyRates: [CurrencyRate] = []
    @Published var filteredCurrencyRates: [CurrencyRate] = []
    @Published var errorMessage: String?
    @Published var favorites: [String] = [] {
        didSet {
            if favorites.count > 5 {
                favorites.removeLast()
            }
            UserDefaults.standard.set(favorites, forKey: "favorites")
            sortCurrencyRates()
        }
    }
    @Published var searchText: String = "" {
        didSet {
            filterCurrencies()
        }
    }
    @Published var baseCurrency: String {
        didSet {
            UserDefaults.standard.set(baseCurrency, forKey: "baseCurrency")
            filterBaseCurrency()
        }
    }
    @Published var filteredBaseCurrencies: [String] = []
    @Published var isShowingBaseCurrencySheet: Bool = false
    @Published var amount: Double = 1.0
    
    private let currencyService: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    let allCurrencies: [String: String] = [
        
        "USD": "United States",
        "AED": "United Arab Emirates",
        "AFN": "Afghanistan",
        "ALL": "Albania",
        "AMD": "Armenia",
        "ANG": "Netherlands Antilles",
        "AOA": "Angola",
        "ARS": "Argentina",
        "AUD": "Australia",
        "AWG": "Aruba",
        "AZN": "Azerbaijan",
        "BAM": "Bosnia and Herzegovina",
        "BBD": "Barbados",
        "BDT": "Bangladesh",
        "BGN": "Bulgaria",
        "BHD": "Bahrain",
        "BIF": "Burundi",
        "BMD": "Bermuda",
        "BND": "Brunei",
        "BOB": "Bolivia",
        "BRL": "Brazil",
        "BSD": "Bahamas",
        "BTN": "Bhutan",
        "BWP": "Botswana",
        "BYN": "Belarus",
        "BZD": "Belize",
        "CAD": "Canada",
        "CDF": "Democratic Republic of the Congo",
        "CHF": "Switzerland",
        "CLP": "Chile",
        "CNY": "China",
        "COP": "Colombia",
        "CRC": "Costa Rica",
        "CUP": "Cuba",
        "CVE": "Cape Verde",
        "CZK": "Czech Republic",
        "DJF": "Djibouti",
        "DKK": "Denmark",
        "DOP": "Dominican Republic",
        "DZD": "Algeria",
        "EGP": "Egypt",
        "ERN": "Eritrea",
        "ETB": "Ethiopia",
        "EUR": "Eurozone",
        "FJD": "Fiji",
        "FKP": "Falkland Islands",
        "FOK": "Faroe Islands",
        "GBP": "United Kingdom",
        "GEL": "Georgia",
        "GGP": "Guernsey",
        "GHS": "Ghana",
        "GIP": "Gibraltar",
        "GMD": "Gambia",
        "GNF": "Guinea",
        "GTQ": "Guatemala",
        "GYD": "Guyana",
        "HKD": "Hong Kong",
        "HNL": "Honduras",
        "HRK": "Croatia",
        "HTG": "Haiti",
        "HUF": "Hungary",
        "IDR": "Indonesia",
        "ILS": "Israel",
        "IMP": "Isle of Man",
        "INR": "India",
        "IQD": "Iraq",
        "IRR": "Iran",
        "ISK": "Iceland",
        "JEP": "Jersey",
        "JMD": "Jamaica",
        "JOD": "Jordan",
        "JPY": "Japan",
        "KES": "Kenya",
        "KGS": "Kyrgyzstan",
        "KHR": "Cambodia",
        "KID": "Kiribati",
        "KMF": "Comoros",
        "KRW": "South Korea",
        "KWD": "Kuwait",
        "KYD": "Cayman Islands",
        "KZT": "Kazakhstan",
        "LAK": "Laos",
        "LBP": "Lebanon",
        "LKR": "Sri Lanka",
        "LRD": "Liberia",
        "LSL": "Lesotho",
        "LYD": "Libya",
        "MAD": "Morocco",
        "MDL": "Moldova",
        "MGA": "Madagascar",
        "MKD": "North Macedonia",
        "MMK": "Myanmar",
        "MNT": "Mongolia",
        "MOP": "Macau",
        "MRU": "Mauritania",
        "MUR": "Mauritius",
        "MVR": "Maldives",
        "MWK": "Malawi",
        "MXN": "Mexico",
        "MYR": "Malaysia",
        "MZN": "Mozambique",
        "NAD": "Namibia",
        "NGN": "Nigeria",
        "NIO": "Nicaragua",
        "NOK": "Norway",
        "NPR": "Nepal",
        "NZD": "New Zealand",
        "OMR": "Oman",
        "PAB": "Panama",
        "PEN": "Peru",
        "PGK": "Papua New Guinea",
        "PHP": "Philippines",
        "PKR": "Pakistan",
        "PLN": "Poland",
        "PYG": "Paraguay",
        "QAR": "Qatar",
        "RON": "Romania",
        "RSD": "Serbia",
        "RUB": "Russia",
        "RWF": "Rwanda",
        "SAR": "Saudi Arabia",
        "SBD": "Solomon Islands",
        "SCR": "Seychelles",
        "SDG": "Sudan",
        "SEK": "Sweden",
        "SGD": "Singapore",
        "SHP": "Saint Helena",
        "SLE": "Sierra Leone",
        "SLL": "Sierra Leone",
        "SOS": "Somalia",
        "SRD": "Suriname",
        "SSP": "South Sudan",
        "STN": "Sao Tome and Principe",
        "SYP": "Syria",
        "SZL": "Eswatini",
        "THB": "Thailand",
        "TJS": "Tajikistan",
        "TMT": "Turkmenistan",
        "TND": "Tunisia",
        "TOP": "Tonga",
        "TRY": "Turkey",
        "TTD": "Trinidad and Tobago",
        "TVD": "Tuvalu",
        "TWD": "Taiwan",
        "TZS": "Tanzania",
        "UAH": "Ukraine",
        "UGX": "Uganda",
        "UYU": "Uruguay",
        "UZS": "Uzbekistan",
        "VES": "Venezuela",
        "VND": "Vietnam",
        "VUV": "Vanuatu",
        "WST": "Samoa",
        "XAF": "Central African CFA franc",
        "XCD": "East Caribbean dollar",
        "XDR": "International Monetary Fund",
        "XOF": "West African CFA franc",
        "XPF": "CFP franc",
        "YER": "Yemen",
        "ZAR": "South Africa",
        "ZMW": "Zambia",
        "ZWL": "Zimbabwe"
    ]
    
    
    
    init(currencyService: CurrencyServiceProtocol) {
        self.currencyService = currencyService
        self.baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency") ?? "USD"
        self.favorites = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        self.filteredBaseCurrencies = Array(allCurrencies.keys).sorted()
    }
    
    func fetchRates(for base: String) {
        guard !base.isEmpty else {
            self.errorMessage = "Base currency cannot be empty"
            return
        }
        
        currencyService.fetchRates(base: base)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                self.errorMessage = nil // Сброс ошибки при успешном получении данных
                self.currencyRates = data.conversionRates.map { (key, value) in
                    let country = self.allCurrencies[key] ?? "Unknown"
                    return CurrencyRate(code: key, rate: value, isFavorite: self.favorites.contains(key), country: country)
                }
                self.sortCurrencyRates()
                self.filterCurrencies()
            }
            .store(in: &cancellables)
    }
    
    func toggleFavorite(for currencyCode: String) {
        if let index = currencyRates.firstIndex(where: { $0.code == currencyCode }) {
            currencyRates[index].isFavorite.toggle()
            if currencyRates[index].isFavorite {
                favorites.append(currencyCode)
            } else {
                favorites.removeAll { $0 == currencyCode }
            }
            sortCurrencyRates()
            filterCurrencies()
        }
    }
    
    private func sortCurrencyRates() {
        currencyRates.sort {
            if $0.isFavorite == $1.isFavorite {
                return $0.code < $1.code
            }
            return $0.isFavorite && !$1.isFavorite
        }
    }
    
    private func filterCurrencies() {
        if searchText.isEmpty {
            filteredCurrencyRates = currencyRates
        } else {
            filteredCurrencyRates = currencyRates.filter { $0.code.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func filterBaseCurrency() {
        if baseCurrency.isEmpty {
            filteredBaseCurrencies = Array(allCurrencies.keys).sorted()
        } else {
            filteredBaseCurrencies = allCurrencies.keys.filter { $0.lowercased().contains(baseCurrency.lowercased()) }.sorted()
        }
    }
}





/*
 private let allCurrencies: [String: String] = [
     
     "USD": "United States",
     "AED": "United Arab Emirates",
     "AFN": "Afghanistan",
     "ALL": "Albania",
     "AMD": "Armenia",
     "ANG": "Netherlands Antilles",
     "AOA": "Angola",
     "ARS": "Argentina",
     "AUD": "Australia",
     "AWG": "Aruba",
     "AZN": "Azerbaijan",
     "BAM": "Bosnia and Herzegovina",
     "BBD": "Barbados",
     "BDT": "Bangladesh",
     "BGN": "Bulgaria",
     "BHD": "Bahrain",
     "BIF": "Burundi",
     "BMD": "Bermuda",
     "BND": "Brunei",
     "BOB": "Bolivia",
     "BRL": "Brazil",
     "BSD": "Bahamas",
     "BTN": "Bhutan",
     "BWP": "Botswana",
     "BYN": "Belarus",
     "BZD": "Belize",
     "CAD": "Canada",
     "CDF": "Democratic Republic of the Congo",
     "CHF": "Switzerland",
     "CLP": "Chile",
     "CNY": "China",
     "COP": "Colombia",
     "CRC": "Costa Rica",
     "CUP": "Cuba",
     "CVE": "Cape Verde",
     "CZK": "Czech Republic",
     "DJF": "Djibouti",
     "DKK": "Denmark",
     "DOP": "Dominican Republic",
     "DZD": "Algeria",
     "EGP": "Egypt",
     "ERN": "Eritrea",
     "ETB": "Ethiopia",
     "EUR": "Eurozone",
     "FJD": "Fiji",
     "FKP": "Falkland Islands",
     "FOK": "Faroe Islands",
     "GBP": "United Kingdom",
     "GEL": "Georgia",
     "GGP": "Guernsey",
     "GHS": "Ghana",
     "GIP": "Gibraltar",
     "GMD": "Gambia",
     "GNF": "Guinea",
     "GTQ": "Guatemala",
     "GYD": "Guyana",
     "HKD": "Hong Kong",
     "HNL": "Honduras",
     "HRK": "Croatia",
     "HTG": "Haiti",
     "HUF": "Hungary",
     "IDR": "Indonesia",
     "ILS": "Israel",
     "IMP": "Isle of Man",
     "INR": "India",
     "IQD": "Iraq",
     "IRR": "Iran",
     "ISK": "Iceland",
     "JEP": "Jersey",
     "JMD": "Jamaica",
     "JOD": "Jordan",
     "JPY": "Japan",
     "KES": "Kenya",
     "KGS": "Kyrgyzstan",
     "KHR": "Cambodia",
     "KID": "Kiribati",
     "KMF": "Comoros",
     "KRW": "South Korea",
     "KWD": "Kuwait",
     "KYD": "Cayman Islands",
     "KZT": "Kazakhstan",
     "LAK": "Laos",
     "LBP": "Lebanon",
     "LKR": "Sri Lanka",
     "LRD": "Liberia",
     "LSL": "Lesotho",
     "LYD": "Libya",
     "MAD": "Morocco",
     "MDL": "Moldova",
     "MGA": "Madagascar",
     "MKD": "North Macedonia",
     "MMK": "Myanmar",
     "MNT": "Mongolia",
     "MOP": "Macau",
     "MRU": "Mauritania",
     "MUR": "Mauritius",
     "MVR": "Maldives",
     "MWK": "Malawi",
     "MXN": "Mexico",
     "MYR": "Malaysia",
     "MZN": "Mozambique",
     "NAD": "Namibia",
     "NGN": "Nigeria",
     "NIO": "Nicaragua",
     "NOK": "Norway",
     "NPR": "Nepal",
     "NZD": "New Zealand",
     "OMR": "Oman",
     "PAB": "Panama",
     "PEN": "Peru",
     "PGK": "Papua New Guinea",
     "PHP": "Philippines",
     "PKR": "Pakistan",
     "PLN": "Poland",
     "PYG": "Paraguay",
     "QAR": "Qatar",
     "RON": "Romania",
     "RSD": "Serbia",
     "RUB": "Russia",
     "RWF": "Rwanda",
     "SAR": "Saudi Arabia",
     "SBD": "Solomon Islands",
     "SCR": "Seychelles",
     "SDG": "Sudan",
     "SEK": "Sweden",
     "SGD": "Singapore",
     "SHP": "Saint Helena",
     "SLE": "Sierra Leone",
     "SLL": "Sierra Leone",
     "SOS": "Somalia",
     "SRD": "Suriname",
     "SSP": "South Sudan",
     "STN": "Sao Tome and Principe",
     "SYP": "Syria",
     "SZL": "Eswatini",
     "THB": "Thailand",
     "TJS": "Tajikistan",
     "TMT": "Turkmenistan",
     "TND": "Tunisia",
     "TOP": "Tonga",
     "TRY": "Turkey",
     "TTD": "Trinidad and Tobago",
     "TVD": "Tuvalu",
     "TWD": "Taiwan",
     "TZS": "Tanzania",
     "UAH": "Ukraine",
     "UGX": "Uganda",
     "UYU": "Uruguay",
     "UZS": "Uzbekistan",
     "VES": "Venezuela",
     "VND": "Vietnam",
     "VUV": "Vanuatu",
     "WST": "Samoa",
     "XAF": "Central African CFA franc",
     "XCD": "East Caribbean dollar",
     "XDR": "International Monetary Fund",
     "XOF": "West African CFA franc",
     "XPF": "CFP franc",
     "YER": "Yemen",
     "ZAR": "South Africa",
     "ZMW": "Zambia",
     "ZWL": "Zimbabwe"
 ]

 */
