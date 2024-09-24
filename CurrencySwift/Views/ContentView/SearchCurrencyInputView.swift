//
//  SearchCurrencyInputView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

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
        .padding(.horizontal, 30)
    }
}


#Preview {
    SearchCurrencyInputView(viewModel: CurrencyViewModel())
}
