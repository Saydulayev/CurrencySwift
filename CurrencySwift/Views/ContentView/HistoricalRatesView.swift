//
//  HistoricalRatesView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

struct HistoricalRatesView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            ScrollView {
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
                                Text("Base")
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
                                Text("Target")
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
                        .clipShape(RoundedRectangle(cornerRadius: 15))
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
//                                Divider()
//                                if let change = viewModel.percentageChange {
//                                    HStack {
//                                        Text("Change:")
//                                        Spacer()
//                                        Text("\(change >= 0 ? "+" : "-")\(abs(change), specifier: "%.2f")%")
//                                            .foregroundColor(change >= 0 ? .green : .red)
//                                    }
//                                }
                            }
                            .foregroundColor(.primary)
                            .padding()

                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
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
            }

            
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}


#Preview {
    HistoricalRatesView(viewModel: CurrencyViewModel())
}
