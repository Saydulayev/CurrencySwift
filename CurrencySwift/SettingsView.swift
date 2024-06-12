//
//  CurrencyTabView.swift
//  CurrencySwift
//
//  Created by Akhmed on 12.06.24.
//

import SwiftUI
import MessageUI

// id1673683355


struct SettingsView: View {
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    @State private var isShowingActivityView = false
    @State private var isShowingMailAlert = false
    
    var body: some View {
        Form {
            // Feedback Section
            Section(header: Text("Feedback")) {
                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        self.isShowingMailView = true
                    } else {
                        self.isShowingMailAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Send Feedback")
                        Spacer()
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .alert(isPresented: $isShowingMailAlert) {
                Alert(
                    title: Text("Cannot Send Mail"),
                    message: Text("Your device is not configured to send mail. Please set up a mail account in order to send feedback."),
                    dismissButton: .default(Text("OK"))
                )
            }

            // Rate App Section
            Section(header: Text("Rate Us")) {
                Button(action: {
                    rateApp()
                }) {
                    HStack {
                        Image(systemName: "star")
                        Text("Rate this App")
                        Spacer()
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            // Share App Section
            Section(header: Text("Share App")) {
                Button(action: {
                    self.isShowingActivityView = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share this App")
                        Spacer()
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: self.$result, recipients: ["saydulayev.wien@gmail.com"], subject: "Feedback")
                .onDisappear {
                    self.isShowingMailView = false
                }
        }
        .sheet(isPresented: $isShowingActivityView) {
            ActivityView(activityItems: ["Check out this amazing CurrencySwift app! https://apps.apple.com/app/id1673683355"])
                .onDisappear {
                    self.isShowingActivityView = false
                }
        }
    }
    
    private func rateApp() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1673683355?action=write-review") else { return }
        if UIApplication.shared.canOpenURL(writeReviewURL) {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}








//#Preview {
//    SettingsView()
//}
