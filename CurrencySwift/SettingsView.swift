//
//  CurrencyTabView.swift
//  CurrencySwift
//
//  Created by Akhmed on 12.06.24.
//

import SwiftUI
import MessageUI

// id1673683355



// Протокол команды
protocol Command {
    func execute()
}

// Команда для отправки отзыва
struct SendFeedbackCommand: Command {
    @Binding var isShowingMailView: Bool
    @Binding var isShowingMailAlert: Bool
    
    func execute() {
        if MFMailComposeViewController.canSendMail() {
            isShowingMailView = true
        } else {
            isShowingMailAlert = true
        }
    }
}

// Команда для оценки приложения
struct RateAppCommand: Command {
    func execute() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1673683355?action=write-review") else { return }
        if UIApplication.shared.canOpenURL(writeReviewURL) {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}

struct SettingsView: View {
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    @State private var isShowingMailAlert = false
    @State private var isShowingActivityView = false
    
    var body: some View {
        Form {
            FeedbackSection(isShowingMailView: $isShowingMailView, isShowingMailAlert: $isShowingMailAlert, result: $result)
            RateAppSection()
            ShareAppSection(isShowingActivityView: $isShowingActivityView)
        }
        .navigationTitle("Settings")
    }
}

struct FeedbackSection: View {
    @Binding var isShowingMailView: Bool
    @Binding var isShowingMailAlert: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    var body: some View {
        Section(header: Text("Feedback")) {
            Button(action: {
                let command = SendFeedbackCommand(isShowingMailView: $isShowingMailView, isShowingMailAlert: $isShowingMailAlert)
                command.execute()
            }) {
                HStack {
                    Image(systemName: "envelope")
                    Text("Send Feedback")
                    Spacer()
                }
                .foregroundStyle(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: $result, recipients: ["saydulayev.wien@gmail.com"], subject: "Feedback for CurrencySwift")
        }
        .alert(isPresented: $isShowingMailAlert) {
            Alert(
                title: Text("Cannot Send Mail"),
                message: Text("Your device is not configured to send mail. Please set up a mail account in order to send feedback."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct RateAppSection: View {
    var body: some View {
        Section(header: Text("Rate Us")) {
            Button(action: {
                let command = RateAppCommand()
                command.execute()
            }) {
                HStack {
                    Image(systemName: "star")
                    Text("Rate this App")
                    Spacer()
                }
                .foregroundStyle(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

struct ShareAppSection: View {
    @Binding var isShowingActivityView: Bool

    var body: some View {
        Section(header: Text("Share App")) {
            Button(action: {
                isShowingActivityView = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share this App")
                    Spacer()
                }
                .foregroundStyle(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sheet(isPresented: $isShowingActivityView) {
            ActivityView(activityItems: ["Check out this amazing CurrencySwift app! https://apps.apple.com/app/id1673683355"])
        }
    }
}








//#Preview {
//    SettingsView()
//}
