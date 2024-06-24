//
//  CurrencyViewModel.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case light, dark, system
    
    var id: String { self.rawValue }
}

enum FilterOption {
    case all
    case favorites
}


class CurrencyViewModel: ObservableObject {
    
    @Published var currencyRates: [CurrencyRate] = []
    @Published var filteredCurrencyRates: [CurrencyRate] = []
    @Published var errorMessage: String?
    
//    @AppStorage("baseCurrency") var baseCurrency: String = "USD" {
//        didSet {
//            filterBaseCurrency()
//        }
//    }
//    
//    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .system {
//        didSet {
//            applyTheme(selectedTheme)
//        }
//    }
    @Published var favorites: [String] = [] {
        didSet {
            saveFavorites()
            sortCurrencyRates()
        }
    }
    @Published var baseCurrency: String {
        didSet {
            UserDefaults.standard.set(baseCurrency, forKey: "baseCurrency")
            filterBaseCurrency()
        }
    }
    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
            applyTheme(selectedTheme)
        }
    }
    @Published var filterOption: FilterOption = .all {
        didSet {
            filterCurrencies()
        }
    }
    @Published var searchText: String = "" {
        didSet {
            filterCurrencies()
        }
    }
    
    
    @Published var filteredBaseCurrencies: [String] = []
    @Published var isShowingBaseCurrencySheet: Bool = false
    @Published var amount: Double = 1.0
    @Published var isConverted: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    
    @Published var exchangeRates: [String: Double] = [:]
    @Published var selectedDate: Date = Date()
    @Published var selectedBaseCurrency: String = "EUR"
    @Published var selectedTargetCurrency: String = "RUB"
    @Published var percentageChange: Double? = nil
    
    private let currencyService: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var sortingStrategy: SortingStrategy
    
    // A dictionary containing currency codes and their corresponding full names
    
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
        self.baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency") ?? "USD" //
        self.favorites = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        self.filteredBaseCurrencies = Array(allCurrencies.keys).sorted()
        self.sortingStrategy = sortingStrategy
        self.selectedTheme = AppTheme(rawValue: UserDefaults.standard.string(forKey: "selectedTheme") ?? "system") ?? .system //
        applyTheme(self.selectedTheme)
        sortCurrencyRates()
    }
    
    // Fetches exchange rates for a given base currency
    func fetchRates(for base: String) {
        guard !base.isEmpty else {
            self.errorMessage = "Base currency cannot be empty"
            return
        }
        
        self.isLoading = true
        self.showErrorAlert = false
        
        currencyService.fetchRates(base: base)
            .timeout(.seconds(10), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                self.isLoading = false
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
    
    // Fetches historical exchange rates for a selected date
    func fetchHistoricalRates() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let year = components.year, let month = components.month, let day = components.day else { return }
        
        self.isLoading = true
        self.showErrorAlert = false
        
        currencyService.fetchHistoricalRates(base: selectedBaseCurrency, year: year, month: month, day: day)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.exchangeRates = response.conversion_rates
                self.calculatePercentageChange(apiKey: Secrets.apiKey, year: year, month: month, day: day)
            }
            .store(in: &cancellables)
    }
    
    // Calculates percentage change in exchange rate between today and a previous date
    private func calculatePercentageChange(apiKey: String, year: Int, month: Int, day: Int) {
        guard let targetRateToday = self.exchangeRates[self.selectedTargetCurrency] else {
            self.percentageChange = nil
            return
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day - 1
        
        guard let previousDate = Calendar.current.date(from: dateComponents) else {
            self.percentageChange = nil
            return
        }
        
        let previousDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: previousDate)
        guard let prevYear = previousDateComponents.year, let prevMonth = previousDateComponents.month, let prevDay = previousDateComponents.day else {
            self.percentageChange = nil
            return
        }
        
        let urlString = "https://v6.exchangerate-api.com/v6/\(apiKey)/history/\(selectedBaseCurrency)/\(prevYear)/\(prevMonth)/\(prevDay)"
        guard let url = URL(string: urlString) else {
            self.percentageChange = nil
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.percentageChange = nil
                }
                return
            }
            do {
                let previousResponse = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
                if previousResponse.result == "success", let targetRateYesterday = previousResponse.conversion_rates[self.selectedTargetCurrency] {
                    DispatchQueue.main.async {
                        self.percentageChange = ((targetRateToday - targetRateYesterday) / targetRateYesterday) * 100
                    }
                } else {
                    DispatchQueue.main.async {
                        self.percentageChange = nil
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.percentageChange = nil
                }
            }
        }.resume()
    }
    
    // Toggles the favorite status for a given currency
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
    
    // Sorts the currency rates using the specified sorting strategy
    private func sortCurrencyRates() {
        currencyRates = sortingStrategy.sort(currencyRates)
    }
    
    // Filters the list of currencies based on the current search text and filter option
    private func filterCurrencies() {
        switch filterOption {
        case .all:
            if searchText.isEmpty {
                filteredCurrencyRates = currencyRates
            } else {
                filteredCurrencyRates = currencyRates.filter { $0.code.lowercased().contains(searchText.lowercased()) }
            }
        case .favorites:
            if searchText.isEmpty {
                filteredCurrencyRates = currencyRates.filter { $0.isFavorite }
            } else {
                filteredCurrencyRates = currencyRates.filter { $0.isFavorite && $0.code.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
    
    // Filters the base currencies based on the current base currency text
    func filterBaseCurrency() {
        if baseCurrency.isEmpty {
            filteredBaseCurrencies = Array(allCurrencies.keys).sorted()
        } else {
            filteredBaseCurrencies = allCurrencies.keys.filter { $0.lowercased().contains(baseCurrency.lowercased()) }.sorted()
        }
    }
    
    // Saves the list of favorite currencies to UserDefaults
    private func saveFavorites() {
        UserDefaults.standard.set(favorites, forKey: "favorites")
    }
    
    // Applies the selected theme to the app
    public func applyTheme(_ theme: AppTheme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        switch theme {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
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



//.delay(for: .seconds(2), scheduler: DispatchQueue.main) // добавлена задержка для отображения индикатора загрузки




// let allCurrencies: [String: String] = [
//     "AED": "United Arab Emirates Dirham",
//     "AFN": "Afghan Afghani",
//     "ALL": "Albanian Lek",
//     "AMD": "Armenian Dram",
//     "ANG": "Netherlands Antillean Guilder",
//     "AOA": "Angolan Kwanza",
//     "ARS": "Argentine Peso",
//     "AUD": "Australian Dollar",
//     "AWG": "Aruban Florin",
//     "AZN": "Azerbaijani Manat",
//     "BAM": "Bosnia-Herzegovina Convertible Mark",
//     "BBD": "Barbadian Dollar",
//     "BDT": "Bangladeshi Taka",
//     "BGN": "Bulgarian Lev",
//     "BHD": "Bahraini Dinar",
//     "BIF": "Burundian Franc",
//     "BMD": "Bermudan Dollar",
//     "BND": "Brunei Dollar",
//     "BOB": "Bolivian Boliviano",
//     "BRL": "Brazilian Real",
//     "BSD": "Bahamian Dollar",
//     "BTC": "Bitcoin",
//     "BTN": "Bhutanese Ngultrum",
//     "BWP": "Botswanan Pula",
//     "BYR": "Belarusian Ruble",
//     "BZD": "Belize Dollar",
//     "CAD": "Canadian Dollar",
//     "CDF": "Congolese Franc",
//     "CHF": "Swiss Franc",
//     "CLF": "Chilean Unit of Account (UF)",
//     "CLP": "Chilean Peso",
//     "CNY": "Chinese Yuan",
//     "COP": "Colombian Peso",
//     "CRC": "Costa Rican Colón",
//     "CUC": "Cuban Convertible Peso",
//     "CUP": "Cuban Peso",
//     "CVE": "Cape Verdean Escudo",
//     "CZK": "Czech Republic Koruna",
//     "DJF": "Djiboutian Franc",
//     "DKK": "Danish Krone",
//     "DOP": "Dominican Peso",
//     "DZD": "Algerian Dinar",
//     "EGP": "Egyptian Pound",
//     "ERN": "Eritrean Nakfa",
//     "ETB": "Ethiopian Birr",
//     "EUR": "Euro",
//     "FJD": "Fijian Dollar",
//     "FKP": "Falkland Islands Pound",
//     "GBP": "British Pound Sterling",
//     "GEL": "Georgian Lari",
//     "GGP": "Guernsey Pound",
//     "GHS": "Ghanaian Cedi",
//     "GIP": "Gibraltar Pound",
//     "GMD": "Gambian Dalasi",
//     "GNF": "Guinean Franc",
//     "GTQ": "Guatemalan Quetzal",
//     "GYD": "Guyanaese Dollar",
//     "HKD": "Hong Kong Dollar",
//     "HNL": "Honduran Lempira",
//     "HRK": "Croatian Kuna",
//     "HTG": "Haitian Gourde",
//     "HUF": "Hungarian Forint",
//     "IDR": "Indonesian Rupiah",
//     "ILS": "Israeli New Sheqel",
//     "IMP": "Manx Pound",
//     "INR": "Indian Rupee",
//     "IQD": "Iraqi Dinar",
//     "IRR": "Iranian Rial",
//     "ISK": "Icelandic Króna",
//     "JEP": "Jersey Pound",
//     "JMD": "Jamaican Dollar",
//     "JOD": "Jordanian Dinar",
//     "JPY": "Japanese Yen",
//     "KES": "Kenyan Shilling",
//     "KGS": "Kyrgystani Som",
//     "KHR": "Cambodian Riel",
//     "KMF": "Comorian Franc",
//     "KPW": "North Korean Won",
//     "KRW": "South Korean Won",
//     "KWD": "Kuwaiti Dinar",
//     "KYD": "Cayman Islands Dollar",
//     "KZT": "Kazakhstani Tenge",
//     "LAK": "Laotian Kip",
//     "LBP": "Lebanese Pound",
//     "LKR": "Sri Lankan Rupee",
//     "LRD": "Liberian Dollar",
//     "LSL": "Lesotho Loti",
//     "LTL": "Lithuanian Litas",
//     "LVL": "Latvian Lats",
//     "LYD": "Libyan Dinar",
//     "MAD": "Moroccan Dirham",
//     "MDL": "Moldovan Leu",
//     "MGA": "Malagasy Ariary",
//     "MKD": "Macedonian Denar",
//     "MMK": "Myanma Kyat",
//     "MNT": "Mongolian Tugrik",
//     "MOP": "Macanese Pataca",
//     "MRO": "Mauritanian Ouguiya",
//     "MUR": "Mauritian Rupee",
//     "MVR": "Maldivian Rufiyaa",
//     "MWK": "Malawian Kwacha",
//     "MXN": "Mexican Peso",
//     "MYR": "Malaysian Ringgit",
//     "MZN": "Mozambican Metical",
//     "NAD": "Namibian Dollar",
//     "NGN": "Nigerian Naira",
//     "NIO": "Nicaraguan Córdoba",
//     "NOK": "Norwegian Krone",
//     "NPR": "Nepalese Rupee",
//     "NZD": "New Zealand Dollar",
//     "OMR": "Omani Rial",
//     "PAB": "Panamanian Balboa",
//     "PEN": "Peruvian Nuevo Sol",
//     "PGK": "Papua New Guinean Kina",
//     "PHP": "Philippine Peso",
//     "PKR": "Pakistani Rupee",
//     "PLN": "Polish Zloty",
//     "PYG": "Paraguayan Guarani",
//     "QAR": "Qatari Rial",
//     "RON": "Romanian Leu",
//     "RSD": "Serbian Dinar",
//     "RUB": "Russian Ruble",
//     "RWF": "Rwandan Franc",
//     "SAR": "Saudi Riyal",
//     "SBD": "Solomon Islands Dollar",
//     "SCR": "Seychellois Rupee",
//     "SDG": "Sudanese Pound",
//     "SEK": "Swedish Krona",
//     "SGD": "Singapore Dollar",
//     "SHP": "Saint Helena Pound",
//     "SLL": "Sierra Leonean Leone",
//     "SOS": "Somali Shilling",
//     "SRD": "Surinamese Dollar",
//     "STD": "São Tomé and Príncipe Dobra",
//     "SVC": "Salvadoran Colón",
//     "SYP": "Syrian Pound",
//     "SZL": "Swazi Lilangeni",
//     "THB": "Thai Baht",
//     "TJS": "Tajikistani Somoni",
//     "TMT": "Turkmenistani Manat",
//     "TND": "Tunisian Dinar",
//     "TOP": "Tongan Paʻanga",
//     "TRY": "Turkish Lira",
//     "TTD": "Trinidad and Tobago Dollar",
//     "TWD": "New Taiwan Dollar",
//     "TZS": "Tanzanian Shilling",
//     "UAH": "Ukrainian Hryvnia",
//     "UGX": "Ugandan Shilling",
//     "USD": "United States Dollar",
//     "UYU": "Uruguayan Peso",
//     "UZS": "Uzbekistan Som",
//     "VEF": "Venezuelan Bolívar Fuerte",
//     "VND": "Vietnamese Dong",
//     "VUV": "Vanuatu Vatu",
//     "WST": "Samoan Tala",
//     "XAF": "CFA Franc BEAC",
//     "XAG": "Silver (troy ounce)",
//     "XAU": "Gold (troy ounce)",
//     "XCD": "East Caribbean Dollar",
//     "XDR": "Special Drawing Rights",
//     "XOF": "CFA Franc BCEAO",
//     "XPF": "CFP Franc",
//     "YER": "Yemeni Rial",
//     "ZAR": "South African Rand",
//     "ZMK": "Zambian Kwacha (pre-2013)",
//     "ZMW": "Zambian Kwacha",
//     "ZWL": "Zimbabwean Dollar"
// ]

