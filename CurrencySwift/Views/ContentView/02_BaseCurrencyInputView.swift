//
//  BaseCurrencyInputView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

struct BaseCurrencyInputView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    @Binding var showTopBorder: Bool
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack {
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
                        HStack {
                            Text(viewModel.baseCurrency)
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: .primary, radius: 2)
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
                    .background(.gray.opacity(0.3))
                    .cornerRadius(15)
            })
        }
        .padding()
    }
}


//#Preview {
//    BaseCurrencyInputView()
//}
