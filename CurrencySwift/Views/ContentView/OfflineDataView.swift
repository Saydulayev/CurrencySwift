//
//  OfflineDataView.swift
//  CurrencySwift
//
//  Created by Saydulayev on 24.09.24.
//

import SwiftUI

struct OfflineDataView: View {
    var lastUpdateTime: Date?
    
    var body: some View {
        if let lastUpdateTime = lastUpdateTime {
            let formatter = RelativeDateTimeFormatter()
            let timeString = formatter.localizedString(for: lastUpdateTime, relativeTo: Date())
            
            VStack {
                Text("You are viewing offline data.")
                    .foregroundColor(.red)
                    .bold()
                Text("Last update: \(timeString) ago")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)
        } else {
            Text("You are viewing offline data. Last update time is not available.")
                .foregroundColor(.red)
                .bold()
                .padding()
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}


#Preview {
    OfflineDataView()
}
