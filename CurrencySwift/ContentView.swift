//
//  ContentView.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import SwiftUI



struct HistoricalRatesView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack {
                    DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .foregroundColor(.primary)
                        .padding()
                        .background(.blue.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 1.0)
                        )
                    
                    HStack {
                        Spacer()
                        Divider()
                        VStack(alignment: .center) {
                            Text("Base Currency")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Select Base Currency", selection: $viewModel.selectedBaseCurrency) {
                                ForEach(viewModel.allCurrencies.keys.sorted(), id: \.self) { currencyCode in
                                    Text(currencyCode).tag(currencyCode)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        Divider()
                        VStack(alignment: .center) {
                            Text("Target Currency")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Select Target Currency", selection: $viewModel.selectedTargetCurrency) {
                                ForEach(viewModel.allCurrencies.keys.sorted(), id: \.self) { currencyCode in
                                    Text(currencyCode).tag(currencyCode)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        Divider()
                        Spacer()
                        Spacer()
                        Button(action: {
                            viewModel.fetchHistoricalRates()
                        }) {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundStyle(.secondary)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 5)
                        }
                        Spacer()
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.vertical)
                }
                Divider()
                VStack {
                    if let rate = viewModel.exchangeRates[viewModel.selectedTargetCurrency] {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("\(viewModel.selectedTargetCurrency):")
                                    .font(.headline)
                                Spacer()
                                Text("\(rate, specifier: "%.4f")")
                                    .foregroundColor(viewModel.percentageChange ?? 0 >= 0 ? .green : .red)
                                    .font(.headline)
                            }
                            Divider()
                            if let change = viewModel.percentageChange {
                                HStack {
                                    Text("Change:")
                                    Spacer()
                                    Text("\(change >= 0 ? "+" : "-")\(abs(change), specifier: "%.2f")%")
                                        .foregroundColor(change >= 0 ? .green : .red)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.vertical)
                    } else {
                        Text("No data available for the selected currency")
                            .foregroundColor(.primary)
                            .padding()
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.vertical)
                    }
                    Spacer()
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Historical Exchange Rates")
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}





struct ContentView: View {
    @StateObject private var viewModel: CurrencyViewModel
    @State private var showingSettings = false

    init(viewModel: CurrencyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                VStack(spacing: 20) {
                    VStack {
                        BaseCurrencyInputView(viewModel: viewModel)
                        AmountInputView(viewModel: viewModel)
                        DividerView()
                    }
                    .background(.blue)
                    
                    if viewModel.isConverted {
                        SearchCurrencyInputView(viewModel: viewModel)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        ErrorMessageView(errorMessage: errorMessage)
                    }
                    
                    CurrencyRatesListView(viewModel: viewModel)
                }
                .navigationTitle("Currency Converter 💱")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: HistoricalRatesView(viewModel: viewModel)) {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundColor(.primary)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                            Image(systemName: "circle.grid.2x2.fill")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: $viewModel.isShowingBaseCurrencySheet) {
                    BaseCurrencySheetView(viewModel: viewModel)
                        .ignoresSafeArea()
                }
            }
        }
    }
}
// Индикатор загрузки
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.black).opacity(0.4)
                .ignoresSafeArea()
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .foregroundColor(.white)
        }
    }
}

// MARK: Views
struct BaseCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Select Base Currency...", text: $viewModel.baseCurrency)
                .foregroundColor(.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingBaseCurrencySheet = true
                    }
                }
            
            Button(action: {
                withAnimation(.easeInOut) {
                    viewModel.fetchRates(for: viewModel.baseCurrency)
                }
            }, label: {
                Image(systemName: "arrow.right.arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(13)
                    .padding(.horizontal, 15)
                    .background(.blue)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary, lineWidth: 1)
                    )
            })
        }
        .padding()
    }
}

struct AmountInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Amount", value: $viewModel.amount, formatter: NumberFormatter.currencyFormatter)
                .foregroundColor(.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .keyboardType(.decimalPad)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }
                    }
                }
            Button(action: {
                hideKeyboard()
            }) {
                if viewModel.baseCurrency.isEmpty {
                    Image(systemName: "eurosign.arrow.circlepath")
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        
                } else {
                    Text(viewModel.baseCurrency)
                }
            }
            .font(.title2)
            .foregroundColor(.primary)
            .padding(14)
            .padding(.horizontal, 7)
            .background(.blue)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.primary, lineWidth: 1)
            )
        }
        .padding()
    }
}

struct DividerView: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
    }
}

struct SearchCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search...", text: $viewModel.searchText)
                    }
                    .foregroundColor(.primary)
                    .padding(7)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(radius: 5)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            withAnimation {
                                viewModel.searchText = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.blue)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Picker("Filter", selection: $viewModel.filterOption) {
                Text("All").tag(FilterOption.all)
                Text("Favorites").tag(FilterOption.favorites)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }
}

struct ErrorMessageView: View {
    var errorMessage: String
    
    var body: some View {
        Text("Error: \(errorMessage)")
            .foregroundColor(.red)
            .padding()
            .transition(.slide)
    }
}

struct CurrencyRatesListView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.filteredCurrencyRates) { currencyRate in
                    CurrencyRateRowView(currencyRate: currencyRate, viewModel: viewModel)
                }
            }
        }
    }
}

struct CurrencyRateRowView: View {
    var currencyRate: CurrencyRate
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(currencyRate.code) - \(currencyRate.country)")
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack {
                    Text(String(format: "%.2f", currencyRate.rate * viewModel.amount))
                    Text(currencyRate.code)
                }
                .font(.subheadline).bold()
                .foregroundColor(.blue.opacity(0.5))
            }
            Spacer()
            Button(action: {
                withAnimation {
                    viewModel.toggleFavorite(for: currencyRate.code)
                }
            }) {
                Image(systemName: currencyRate.isFavorite ? "star.fill" : "star")
                    .foregroundColor(currencyRate.isFavorite ? .blue : .primary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .transition(.opacity)
    }
}

struct BaseCurrencySheetView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .trailing) {
                    TextField("Search Base Currency...", text: $viewModel.baseCurrency)
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .onChange(of: viewModel.baseCurrency) { newValue in
                            viewModel.baseCurrency = newValue.uppercased()
                            viewModel.filterBaseCurrency()
                    }
                    Button(action: {
                        withAnimation {
                            viewModel.baseCurrency = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.blue)
                            .padding(.trailing, 10)
                    }
                }
                
                Button("Cancel") {
                    withAnimation {
                        viewModel.baseCurrency = ""
                        viewModel.filteredBaseCurrencies = Array(viewModel.allCurrencies.keys).sorted()
                        viewModel.isShowingBaseCurrencySheet = false
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .padding()
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.filteredBaseCurrencies, id: \.self) { currency in
                        VStack(alignment: .leading) {
                            Text("\(currency) - \(viewModel.allCurrencies[currency] ?? "")")
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.baseCurrency = currency
                                        viewModel.isShowingBaseCurrencySheet = false
                                    }
                                }
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .shadow(color: .secondary, radius: 1)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}


#Preview {
    ContentView(viewModel: CurrencyViewModel(currencyService: CurrencyService.shared, sortingStrategy: FavoriteFirstSortingStrategy()))
}



