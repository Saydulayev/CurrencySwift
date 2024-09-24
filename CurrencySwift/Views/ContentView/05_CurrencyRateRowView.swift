//
//  CurrencyRateRowView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

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
        .shadow(color: .primary, radius: 1)
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


//#Preview {
//    CurrencyRateRowView()
//}
