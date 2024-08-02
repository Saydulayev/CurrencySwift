//
//  ContentView.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel: CurrencyViewModel
    @State private var showingSettings = false
    @FocusState private var isFocused: Bool
    @State private var showTopBorder = false

    init(viewModel: CurrencyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFocused = false
                    }
                
                VStack(spacing: 20) {
                    if !viewModel.isConnected {
                        OfflineDataView(lastUpdateTime: viewModel.loadLastUpdateTime())
                    }
                    
                    VStack {
                        BaseCurrencyInputView(viewModel: viewModel, showTopBorder: $showTopBorder)
                        AmountInputView(viewModel: viewModel, isFocused: $isFocused)
                        DividerView()
                    }
                    .background(Color.blue.opacity(0.3))

                    if viewModel.isConverted {
                        SearchCurrencyInputView(viewModel: viewModel)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        ErrorMessageView(errorMessage: errorMessage)
                    }
                    
                    CurrencyRatesListView(viewModel: viewModel, showTopBorder: $showTopBorder)
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
                    BaseCurrencySheetView(viewModel: viewModel, isFocused: $isFocused)
                        .ignoresSafeArea()
                }
            }
        }
    }
}





// MARK: Views
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

struct OfflineDataView: View {
    var lastUpdateTime: Date?
    
    var body: some View {
        if let lastUpdateTime = lastUpdateTime {
            let formatter = RelativeDateTimeFormatter()
            let timeString = formatter.localizedString(for: lastUpdateTime, relativeTo: Date())
            
            VStack {
                Text("You are viewing offline data.")
                    .foregroundColor(.red)
                    .bold()
                Text("Last update: \(timeString) ago")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)
        } else {
            Text("You are viewing offline data. Last update time is not available.")
                .foregroundColor(.red)
                .bold()
                .padding()
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

struct BaseCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    @Binding var showTopBorder: Bool
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: {
                withAnimation {
                    viewModel.isShowingBaseCurrencySheet = true
                }
            }) {
                HStack {
                    if viewModel.baseCurrency.isEmpty {
                        Image(systemName: "hand.tap")
                            .foregroundColor(.gray)
                            .scaleEffect(scale)
                            .animateForever(autoreverses: true) {
                                scale = scale == 1.0 ? 1.1 : 1.0
                            }
                    } else {
                        Text(viewModel.baseCurrency)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
            }
            
            Button(action: {
                withAnimation(.easeInOut) {
                    viewModel.fetchRates(for: viewModel.baseCurrency)
                    showTopBorder = true
                }
            }, label: {
                Image(systemName: "arrow.right.arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(13)
                    .padding(.horizontal, 15)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
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
    @FocusState.Binding var isFocused: Bool

    @State private var amountString: String = ""

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Amount", text: $amountString)
                .foregroundColor(.blue)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .onChange(of: amountString) { newValue in
                    let filtered = newValue.filter { "0123456789.,".contains($0) }
                    if let value = NumberFormatter.currencyFormatter.number(from: filtered)?.doubleValue {
                        viewModel.amount = value
                    }
                    amountString = filtered
                }

            if isFocused {
                Button("Done") {
                    isFocused = false
                }
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.vertical, 14.5)
                .padding(.horizontal, 16)
                .background(.green)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.primary, lineWidth: 1)
                )
            } else {
                Button(action: {
                    isFocused = true
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
        }
        .padding()
        .onAppear {
            amountString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: viewModel.amount)) ?? ""
        }
    }
}

struct SearchCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search...", text: $viewModel.searchText)
                        .padding(.vertical, 7)
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 7)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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

            Picker("Filter", selection: $viewModel.filterOption) {
                Text("All").tag(FilterOption.all)
                Text("Favorites").tag(FilterOption.favorites)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 7)
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
    @Binding var showTopBorder: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.filteredCurrencyRates) { currencyRate in
                        CurrencyRateRowView(currencyRate: currencyRate, viewModel: viewModel)
                    }
                }
                .padding(.top, 10) // Add padding to avoid overlaying on the first item
            }
            
            if viewModel.isLoading {
                LoadingView()
            }

            if showTopBorder {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]), startPoint: .top, endPoint: .bottom))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .zIndex(1)
            }
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
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
                    Text(formattedRate(currencyRate.rate * viewModel.amount))
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
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .transition(.opacity)
    }
    
    private func formattedRate(_ rate: Double) -> String {
        if rate >= 1 {
            return String(format: "%.2f", rate)
        } else if rate >= 0.1 {
            return String(format: "%.4f", rate)
        } else if rate >= 0.01 {
            return String(format: "%.6f", rate)
        } else {
            return String(format: "%.8f", rate)
        }
    }
}

struct BaseCurrencySheetView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    @FocusState.Binding var isFocused: Bool
    
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
                        .focused($isFocused)
                        .onChange(of: viewModel.baseCurrency) { newValue in
                            viewModel.baseCurrency = newValue.uppercased()
                            viewModel.filterBaseCurrency()
                        }
                    Button(action: {
                        withAnimation {
                            viewModel.baseCurrency = ""
                            isFocused = false
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
                        isFocused = false
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
                                        isFocused = false
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

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.black).opacity(0.3)
                .ignoresSafeArea()
            VStack {
                ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
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


// MARK: Extensions
extension View {
    func animateForever(using animation: Animation = .easeInOut(duration: 1), autoreverses: Bool = false, _ action: @escaping () -> Void) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}

extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }
}


#Preview {
    ContentView(viewModel: CurrencyViewModel(currencyService: CurrencyService.shared, sortingStrategy: FavoriteFirstSortingStrategy()))
}



