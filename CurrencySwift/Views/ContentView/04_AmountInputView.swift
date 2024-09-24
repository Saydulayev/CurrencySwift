//
//  AmountInputView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

struct AmountInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    @FocusState.Binding var isFocused: Bool

    @State private var amountString: String = ""

    var body: some View {
        HStack {
            TextField("Amount", text: $amountString)
                .foregroundColor(.blue)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .shadow(color: .primary, radius: 2)
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
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color.accentColor)
                .cornerRadius(15)
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
                .background(.gray.opacity(0.3))
                .cornerRadius(15)
            }
        }
        .padding()
        .onAppear {
            amountString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: viewModel.amount)) ?? ""
        }
    }
}


//#Preview {
//    AmountInputView()
//}
