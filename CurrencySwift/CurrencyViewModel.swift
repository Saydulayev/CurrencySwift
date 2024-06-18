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
    @Published var isConverted: Bool = false
    
    private let currencyService: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var sortingStrategy: SortingStrategy
    
    
    let allCurrencies: [String: String] = [
        "AED": "United Arab Emirates Dirham",
        "AFN": "Afghan Afghani",
        "ALL": "Albanian Lek",
        "AMD": "Armenian Dram",
        "ANG": "Netherlands Antillean Guilder",
        "AOA": "Angolan Kwanza",
        "ARS": "Argentine Peso",
        "AUD": "Australian Dollar",
        "AWG": "Aruban Florin",
        "AZN": "Azerbaijani Manat",
        "BAM": "Bosnia-Herzegovina Convertible Mark",
        "BBD": "Barbadian Dollar",
        "BDT": "Bangladeshi Taka",
        "BGN": "Bulgarian Lev",
        "BHD": "Bahraini Dinar",
        "BIF": "Burundian Franc",
        "BMD": "Bermudan Dollar",
        "BND": "Brunei Dollar",
        "BOB": "Bolivian Boliviano",
        "BRL": "Brazilian Real",
        "BSD": "Bahamian Dollar",
        "BTC": "Bitcoin",
        "BTN": "Bhutanese Ngultrum",
        "BWP": "Botswanan Pula",
        "BYR": "Belarusian Ruble",
        "BZD": "Belize Dollar",
        "CAD": "Canadian Dollar",
        "CDF": "Congolese Franc",
        "CHF": "Swiss Franc",
        "CLF": "Chilean Unit of Account (UF)",
        "CLP": "Chilean Peso",
        "CNY": "Chinese Yuan",
        "COP": "Colombian Peso",
        "CRC": "Costa Rican Colón",
        "CUC": "Cuban Convertible Peso",
        "CUP": "Cuban Peso",
        "CVE": "Cape Verdean Escudo",
        "CZK": "Czech Republic Koruna",
        "DJF": "Djiboutian Franc",
        "DKK": "Danish Krone",
        "DOP": "Dominican Peso",
        "DZD": "Algerian Dinar",
        "EGP": "Egyptian Pound",
        "ERN": "Eritrean Nakfa",
        "ETB": "Ethiopian Birr",
        "EUR": "Euro",
        "FJD": "Fijian Dollar",
        "FKP": "Falkland Islands Pound",
        "GBP": "British Pound Sterling",
        "GEL": "Georgian Lari",
        "GGP": "Guernsey Pound",
        "GHS": "Ghanaian Cedi",
        "GIP": "Gibraltar Pound",
        "GMD": "Gambian Dalasi",
        "GNF": "Guinean Franc",
        "GTQ": "Guatemalan Quetzal",
        "GYD": "Guyanaese Dollar",
        "HKD": "Hong Kong Dollar",
        "HNL": "Honduran Lempira",
        "HRK": "Croatian Kuna",
        "HTG": "Haitian Gourde",
        "HUF": "Hungarian Forint",
        "IDR": "Indonesian Rupiah",
        "ILS": "Israeli New Sheqel",
        "IMP": "Manx Pound",
        "INR": "Indian Rupee",
        "IQD": "Iraqi Dinar",
        "IRR": "Iranian Rial",
        "ISK": "Icelandic Króna",
        "JEP": "Jersey Pound",
        "JMD": "Jamaican Dollar",
        "JOD": "Jordanian Dinar",
        "JPY": "Japanese Yen",
        "KES": "Kenyan Shilling",
        "KGS": "Kyrgystani Som",
        "KHR": "Cambodian Riel",
        "KMF": "Comorian Franc",
        "KPW": "North Korean Won",
        "KRW": "South Korean Won",
        "KWD": "Kuwaiti Dinar",
        "KYD": "Cayman Islands Dollar",
        "KZT": "Kazakhstani Tenge",
        "LAK": "Laotian Kip",
        "LBP": "Lebanese Pound",
        "LKR": "Sri Lankan Rupee",
        "LRD": "Liberian Dollar",
        "LSL": "Lesotho Loti",
        "LTL": "Lithuanian Litas",
        "LVL": "Latvian Lats",
        "LYD": "Libyan Dinar",
        "MAD": "Moroccan Dirham",
        "MDL": "Moldovan Leu",
        "MGA": "Malagasy Ariary",
        "MKD": "Macedonian Denar",
        "MMK": "Myanma Kyat",
        "MNT": "Mongolian Tugrik",
        "MOP": "Macanese Pataca",
        "MRO": "Mauritanian Ouguiya",
        "MUR": "Mauritian Rupee",
        "MVR": "Maldivian Rufiyaa",
        "MWK": "Malawian Kwacha",
        "MXN": "Mexican Peso",
        "MYR": "Malaysian Ringgit",
        "MZN": "Mozambican Metical",
        "NAD": "Namibian Dollar",
        "NGN": "Nigerian Naira",
        "NIO": "Nicaraguan Córdoba",
        "NOK": "Norwegian Krone",
        "NPR": "Nepalese Rupee",
        "NZD": "New Zealand Dollar",
        "OMR": "Omani Rial",
        "PAB": "Panamanian Balboa",
        "PEN": "Peruvian Nuevo Sol",
        "PGK": "Papua New Guinean Kina",
        "PHP": "Philippine Peso",
        "PKR": "Pakistani Rupee",
        "PLN": "Polish Zloty",
        "PYG": "Paraguayan Guarani",
        "QAR": "Qatari Rial",
        "RON": "Romanian Leu",
        "RSD": "Serbian Dinar",
        "RUB": "Russian Ruble",
        "RWF": "Rwandan Franc",
        "SAR": "Saudi Riyal",
        "SBD": "Solomon Islands Dollar",
        "SCR": "Seychellois Rupee",
        "SDG": "Sudanese Pound",
        "SEK": "Swedish Krona",
        "SGD": "Singapore Dollar",
        "SHP": "Saint Helena Pound",
        "SLL": "Sierra Leonean Leone",
        "SOS": "Somali Shilling",
        "SRD": "Surinamese Dollar",
        "STD": "São Tomé and Príncipe Dobra",
        "SVC": "Salvadoran Colón",
        "SYP": "Syrian Pound",
        "SZL": "Swazi Lilangeni",
        "THB": "Thai Baht",
        "TJS": "Tajikistani Somoni",
        "TMT": "Turkmenistani Manat",
        "TND": "Tunisian Dinar",
        "TOP": "Tongan Paʻanga",
        "TRY": "Turkish Lira",
        "TTD": "Trinidad and Tobago Dollar",
        "TWD": "New Taiwan Dollar",
        "TZS": "Tanzanian Shilling",
        "UAH": "Ukrainian Hryvnia",
        "UGX": "Ugandan Shilling",
        "USD": "United States Dollar",
        "UYU": "Uruguayan Peso",
        "UZS": "Uzbekistan Som",
        "VEF": "Venezuelan Bolívar Fuerte",
        "VND": "Vietnamese Dong",
        "VUV": "Vanuatu Vatu",
        "WST": "Samoan Tala",
        "XAF": "CFA Franc BEAC",
        "XAG": "Silver (troy ounce)",
        "XAU": "Gold (troy ounce)",
        "XCD": "East Caribbean Dollar",
        "XDR": "Special Drawing Rights",
        "XOF": "CFA Franc BCEAO",
        "XPF": "CFP Franc",
        "YER": "Yemeni Rial",
        "ZAR": "South African Rand",
        "ZMK": "Zambian Kwacha (pre-2013)",
        "ZMW": "Zambian Kwacha",
        "ZWL": "Zimbabwean Dollar"
    ]


    
    init(currencyService: CurrencyServiceProtocol = CurrencyService.shared, sortingStrategy: SortingStrategy = FavoriteFirstSortingStrategy()) {
        self.currencyService = currencyService
        self.baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency") ?? "USD"
        self.favorites = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        self.filteredBaseCurrencies = Array(allCurrencies.keys).sorted()
        self.sortingStrategy = sortingStrategy
        sortCurrencyRates()
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
                self.errorMessage = nil
                self.currencyRates = data.conversionRates.map { (key, value) in
                    let country = self.allCurrencies[key] ?? "Unknown"
                    return CurrencyRate(code: key, rate: value, isFavorite: self.favorites.contains(key), country: country)
                }
                self.sortCurrencyRates()
                self.filterCurrencies()
                self.isConverted = true
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
        currencyRates = sortingStrategy.sort(currencyRates)
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


protocol SortingStrategy {
    func sort(_ rates: [CurrencyRate]) -> [CurrencyRate]
}

class AlphabeticalSortingStrategy: SortingStrategy {
    func sort(_ rates: [CurrencyRate]) -> [CurrencyRate] {
        return rates.sorted { $0.code < $1.code }
    }
}

class FavoriteFirstSortingStrategy: SortingStrategy {
    func sort(_ rates: [CurrencyRate]) -> [CurrencyRate] {
        let favorites = rates.filter { $0.isFavorite }
        let nonFavorites = rates.filter { !$0.isFavorite }
        return favorites.sorted { $0.code < $1.code } + nonFavorites.sorted { $0.code < $1.code }
    }
}





/*
 let allCurrencies: [String: String] = [
     "AED": "United Arab Emirates Dirham",
     "AFN": "Afghan Afghani",
     "ALL": "Albanian Lek",
     "AMD": "Armenian Dram",
     "ANG": "Netherlands Antillean Guilder",
     "AOA": "Angolan Kwanza",
     "ARS": "Argentine Peso",
     "AUD": "Australian Dollar",
     "AWG": "Aruban Florin",
     "AZN": "Azerbaijani Manat",
     "BAM": "Bosnia-Herzegovina Convertible Mark",
     "BBD": "Barbadian Dollar",
     "BDT": "Bangladeshi Taka",
     "BGN": "Bulgarian Lev",
     "BHD": "Bahraini Dinar",
     "BIF": "Burundian Franc",
     "BMD": "Bermudan Dollar",
     "BND": "Brunei Dollar",
     "BOB": "Bolivian Boliviano",
     "BRL": "Brazilian Real",
     "BSD": "Bahamian Dollar",
     "BTC": "Bitcoin",
     "BTN": "Bhutanese Ngultrum",
     "BWP": "Botswanan Pula",
     "BYR": "Belarusian Ruble",
     "BZD": "Belize Dollar",
     "CAD": "Canadian Dollar",
     "CDF": "Congolese Franc",
     "CHF": "Swiss Franc",
     "CLF": "Chilean Unit of Account (UF)",
     "CLP": "Chilean Peso",
     "CNY": "Chinese Yuan",
     "COP": "Colombian Peso",
     "CRC": "Costa Rican Colón",
     "CUC": "Cuban Convertible Peso",
     "CUP": "Cuban Peso",
     "CVE": "Cape Verdean Escudo",
     "CZK": "Czech Republic Koruna",
     "DJF": "Djiboutian Franc",
     "DKK": "Danish Krone",
     "DOP": "Dominican Peso",
     "DZD": "Algerian Dinar",
     "EGP": "Egyptian Pound",
     "ERN": "Eritrean Nakfa",
     "ETB": "Ethiopian Birr",
     "EUR": "Euro",
     "FJD": "Fijian Dollar",
     "FKP": "Falkland Islands Pound",
     "GBP": "British Pound Sterling",
     "GEL": "Georgian Lari",
     "GGP": "Guernsey Pound",
     "GHS": "Ghanaian Cedi",
     "GIP": "Gibraltar Pound",
     "GMD": "Gambian Dalasi",
     "GNF": "Guinean Franc",
     "GTQ": "Guatemalan Quetzal",
     "GYD": "Guyanaese Dollar",
     "HKD": "Hong Kong Dollar",
     "HNL": "Honduran Lempira",
     "HRK": "Croatian Kuna",
     "HTG": "Haitian Gourde",
     "HUF": "Hungarian Forint",
     "IDR": "Indonesian Rupiah",
     "ILS": "Israeli New Sheqel",
     "IMP": "Manx Pound",
     "INR": "Indian Rupee",
     "IQD": "Iraqi Dinar",
     "IRR": "Iranian Rial",
     "ISK": "Icelandic Króna",
     "JEP": "Jersey Pound",
     "JMD": "Jamaican Dollar",
     "JOD": "Jordanian Dinar",
     "JPY": "Japanese Yen",
     "KES": "Kenyan Shilling",
     "KGS": "Kyrgystani Som",
     "KHR": "Cambodian Riel",
     "KMF": "Comorian Franc",
     "KPW": "North Korean Won",
     "KRW": "South Korean Won",
     "KWD": "Kuwaiti Dinar",
     "KYD": "Cayman Islands Dollar",
     "KZT": "Kazakhstani Tenge",
     "LAK": "Laotian Kip",
     "LBP": "Lebanese Pound",
     "LKR": "Sri Lankan Rupee",
     "LRD": "Liberian Dollar",
     "LSL": "Lesotho Loti",
     "LTL": "Lithuanian Litas",
     "LVL": "Latvian Lats",
     "LYD": "Libyan Dinar",
     "MAD": "Moroccan Dirham",
     "MDL": "Moldovan Leu",
     "MGA": "Malagasy Ariary",
     "MKD": "Macedonian Denar",
     "MMK": "Myanma Kyat",
     "MNT": "Mongolian Tugrik",
     "MOP": "Macanese Pataca",
     "MRO": "Mauritanian Ouguiya",
     "MUR": "Mauritian Rupee",
     "MVR": "Maldivian Rufiyaa",
     "MWK": "Malawian Kwacha",
     "MXN": "Mexican Peso",
     "MYR": "Malaysian Ringgit",
     "MZN": "Mozambican Metical",
     "NAD": "Namibian Dollar",
     "NGN": "Nigerian Naira",
     "NIO": "Nicaraguan Córdoba",
     "NOK": "Norwegian Krone",
     "NPR": "Nepalese Rupee",
     "NZD": "New Zealand Dollar",
     "OMR": "Omani Rial",
     "PAB": "Panamanian Balboa",
     "PEN": "Peruvian Nuevo Sol",
     "PGK": "Papua New Guinean Kina",
     "PHP": "Philippine Peso",
     "PKR": "Pakistani Rupee",
     "PLN": "Polish Zloty",
     "PYG": "Paraguayan Guarani",
     "QAR": "Qatari Rial",
     "RON": "Romanian Leu",
     "RSD": "Serbian Dinar",
     "RUB": "Russian Ruble",
     "RWF": "Rwandan Franc",
     "SAR": "Saudi Riyal",
     "SBD": "Solomon Islands Dollar",
     "SCR": "Seychellois Rupee",
     "SDG": "Sudanese Pound",
     "SEK": "Swedish Krona",
     "SGD": "Singapore Dollar",
     "SHP": "Saint Helena Pound",
     "SLL": "Sierra Leonean Leone",
     "SOS": "Somali Shilling",
     "SRD": "Surinamese Dollar",
     "STD": "São Tomé and Príncipe Dobra",
     "SVC": "Salvadoran Colón",
     "SYP": "Syrian Pound",
     "SZL": "Swazi Lilangeni",
     "THB": "Thai Baht",
     "TJS": "Tajikistani Somoni",
     "TMT": "Turkmenistani Manat",
     "TND": "Tunisian Dinar",
     "TOP": "Tongan Paʻanga",
     "TRY": "Turkish Lira",
     "TTD": "Trinidad and Tobago Dollar",
     "TWD": "New Taiwan Dollar",
     "TZS": "Tanzanian Shilling",
     "UAH": "Ukrainian Hryvnia",
     "UGX": "Ugandan Shilling",
     "USD": "United States Dollar",
     "UYU": "Uruguayan Peso",
     "UZS": "Uzbekistan Som",
     "VEF": "Venezuelan Bolívar Fuerte",
     "VND": "Vietnamese Dong",
     "VUV": "Vanuatu Vatu",
     "WST": "Samoan Tala",
     "XAF": "CFA Franc BEAC",
     "XAG": "Silver (troy ounce)",
     "XAU": "Gold (troy ounce)",
     "XCD": "East Caribbean Dollar",
     "XDR": "Special Drawing Rights",
     "XOF": "CFA Franc BCEAO",
     "XPF": "CFP Franc",
     "YER": "Yemeni Rial",
     "ZAR": "South African Rand",
     "ZMK": "Zambian Kwacha (pre-2013)",
     "ZMW": "Zambian Kwacha",
     "ZWL": "Zimbabwean Dollar"
 ]

 */
