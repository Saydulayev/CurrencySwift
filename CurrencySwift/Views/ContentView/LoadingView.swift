//
//  LoadingView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.black).opacity(0.3)
                .ignoresSafeArea()
            VStack {
                ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
    }
}


#Preview {
    LoadingView()
}
