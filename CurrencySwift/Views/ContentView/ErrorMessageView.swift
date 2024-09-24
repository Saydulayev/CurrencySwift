//
//  ErrorMessageView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

struct ErrorMessageView: View {
    var errorMessage: String
    
    var body: some View {
        Text("Error: \(errorMessage)")
            .foregroundColor(.red)
            .padding()
            .transition(.slide)
    }
}



