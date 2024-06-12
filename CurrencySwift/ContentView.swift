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
                    BaseCurrencyInputView(viewModel: viewModel)
                    
                    AmountInputView(viewModel: viewModel)
                    
                    DividerView()
                    
                    SearchCurrencyInputView(viewModel: viewModel)
                    
                    if let errorMessage = viewModel.errorMessage {
                        ErrorMessageView(errorMessage: errorMessage)
                    }
                    
                    CurrencyRatesListView(viewModel: viewModel)
                }
                .navigationTitle("Currency Converter 💱")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
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




struct BaseCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Enter Base Currency...", text: $viewModel.baseCurrency)
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
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(15)
            })
        }
        .padding()
        .background(.blue.opacity(0.5))
    }
}

struct AmountInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Amount", value: $viewModel.amount, formatter: NumberFormatter())
                .foregroundColor(.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .keyboardType(.decimalPad)
            
            Button("Done") {
                hideKeyboard()
            }
            .font(.title2)
            .foregroundColor(.primary)
            .padding(14)
            .padding(.horizontal, 2)
            .background(Color.blue.opacity(0.5))
            .cornerRadius(15)
        }
        .padding()
    }
}

struct DividerView: View {
    var body: some View {
        Rectangle()
            .frame(height: 0.3)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color(UIColor.separator))
    }
}

struct SearchCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Search Currency...", text: $viewModel.searchText)
                .foregroundColor(.primary)
                .padding(7)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
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








#Preview {
    ContentView(viewModel: CurrencyViewModel(currencyService: CurrencyService()))
}


/*
 import SwiftUI

 struct ContentView: View {
     @StateObject private var viewModel: CurrencyViewModel
     
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
                     ZStack(alignment: .trailing) {
                         TextField("Enter Base Currency...", text: $viewModel.baseCurrency)
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
                                 .background(Color.blue.opacity(0.5))
                                 .cornerRadius(15)
                         })
                     }
                     .padding()
                     
                     ZStack(alignment: .trailing) {
                         TextField("Amount", value: $viewModel.amount, formatter: NumberFormatter())
                             .foregroundColor(.primary)
                             .padding()
                             .background(Color(UIColor.secondarySystemBackground))
                             .cornerRadius(15)
                             .shadow(radius: 5)
                             .keyboardType(.decimalPad)
                         
                         Button("Done") {
                             hideKeyboard()
                         }
                         .font(.title2)
                         .foregroundColor(.primary)
                         .padding(14)
                         .padding(.horizontal, 0)
                         .background(Color.blue.opacity(0.5))
                         .cornerRadius(15)
                     }
                     .padding()
                     
                     Rectangle()
                         .frame(height: 0.3)
                         .frame(maxWidth: .infinity)
                         .foregroundColor(Color(UIColor.separator))
                     
                     ZStack(alignment: .trailing) {
                         TextField("Search Currency...", text: $viewModel.searchText)
                             .foregroundColor(.primary)
                             .padding(7)
                             .background(Color(UIColor.secondarySystemBackground))
                             .cornerRadius(10)
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
                     
                     if let errorMessage = viewModel.errorMessage {
                         Text("Error: \(errorMessage)")
                             .foregroundColor(.red)
                             .padding()
                             .transition(.slide)
                     }
                     
                     ScrollView {
                         LazyVStack {
                             ForEach(viewModel.filteredCurrencyRates) { currencyRate in
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
                     }
                 }
                 .navigationTitle("Currency Converter 💱")
                 .navigationBarTitleDisplayMode(.inline)
                 .sheet(isPresented: $viewModel.isShowingBaseCurrencySheet) {
                     VStack {
                         HStack {
                             TextField("Search Base Currency...", text: $viewModel.baseCurrency)
                                 .padding()
                                 .foregroundColor(.primary)
                                 .background(Color(UIColor.secondarySystemBackground))
                                 .cornerRadius(15)
                                 .shadow(radius: 5)
                                 .onChange(of: viewModel.baseCurrency) { newValue in
                                     viewModel.filterBaseCurrency()
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
                                             .background(Color(UIColor.secondarySystemBackground))
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
                     }
                 }
             }
         }
     }
 }

 extension View {
     func hideKeyboard() {
         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }
 }

 */
