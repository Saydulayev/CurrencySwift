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
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: .primary, radius: 2)
                    .padding()
                    
                    if viewModel.isConverted {
                        SearchCurrencyInputView(viewModel: viewModel)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        ErrorMessageView(errorMessage: errorMessage)
                    }
                    
                    CurrencyRatesListView(viewModel: viewModel, showTopBorder: $showTopBorder)
                }
                .navigationTitle("Quick Convert 💱")
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



