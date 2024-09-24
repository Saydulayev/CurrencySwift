//
//  CurrencyRatesListView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

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
                    .frame(height: 10)
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

//#Preview {
//    CurrencyRatesListView()
//}
