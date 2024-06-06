//
//  ContentView.swift
//  CurrencySwift
//
//  Created by Akhmed on 06.06.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: CurrencyViewModel
    
    init(viewModel: CurrencyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Base Currency", text: $viewModel.baseCurrency)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onTapGesture {
                            viewModel.isShowingBaseCurrencySheet = true
                        }
                    
                    Button("Fetch Rates") {
                        viewModel.fetchRates(for: viewModel.baseCurrency)
                    }
                    .padding()
                }
                
                ZStack(alignment: .trailing) {
                    TextField("Search...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.leading, .trailing])
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .padding([.leading, .trailing])
                
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewModel.filteredCurrencyRates) { currencyRate in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(currencyRate.code) - \(currencyRate.country)")
                                .font(.headline)
                            Text(String(format: "%.2f", currencyRate.rate))
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.toggleFavorite(for: currencyRate.code)
                        }) {
                            Image(systemName: currencyRate.isFavorite ? "star.fill" : "star")
                                .foregroundColor(currencyRate.isFavorite ? .yellow : .gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Exchange Rates")
            .sheet(isPresented: $viewModel.isShowingBaseCurrencySheet) {
                VStack {
                    HStack {
                        TextField("Search Currency...", text: $viewModel.baseCurrency)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .onChange(of: viewModel.baseCurrency) { newValue in
                                viewModel.filterBaseCurrency()
                            }
                        
                        Button("Cancel") {
                            viewModel.baseCurrency = ""
                            viewModel.filteredBaseCurrencies = Array(viewModel.allCurrencies.keys).sorted()
                            viewModel.isShowingBaseCurrencySheet = false
                        }
                        .padding()
                    }
                    
                    List(viewModel.filteredBaseCurrencies, id: \.self) { currency in
                        Text(currency)
                            .onTapGesture {
                                viewModel.baseCurrency = currency
                                viewModel.isShowingBaseCurrencySheet = false
                            }
                    }
                }
                .padding()
            }
        }
    }
}








#Preview {
    ContentView(viewModel: CurrencyViewModel(currencyService: CurrencyService()))
}
