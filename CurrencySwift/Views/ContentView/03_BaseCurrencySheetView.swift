//
//  BaseCurrencySheetView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

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


//#Preview {
//    BaseCurrencySheetView()
//}
