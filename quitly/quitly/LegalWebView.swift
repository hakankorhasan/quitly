//
//  LegalWebView.swift
//  quitly
//
//  Firebase Hosting'den Privacy Policy ve Terms of Use yükler.
//

import SwiftUI
import WebKit

// MARK: - Firebase Hosting URLs
enum LegalURL {
    static let privacyPolicy = "https://quitalcohol-c13cd.web.app/privacy-policy.html"
    static let termsOfUse   = "https://quitalcohol-c13cd.web.app/terms-of-use.html"
}

// MARK: - WKWebView Wrapper
struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.10, alpha: 1)
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> Coordinator { Coordinator(isLoading: $isLoading) }

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        init(isLoading: Binding<Bool>) { _isLoading = isLoading }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            isLoading = false
        }
        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            isLoading = false
        }
    }
}

// MARK: - Legal Sheet View
struct LegalWebView: View {
    let title: String
    let urlString: String
    @Environment(\.dismiss) private var dismiss

    @State private var isLoading = true

    var body: some View {
        ZStack(alignment: .top) {
            AppGradient.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Navigation Bar ─────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    // Safari'de aç
                    Button {
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "safari")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    Color.white.opacity(0.04)
                        .overlay(alignment: .bottom) {
                            Divider().background(Color.white.opacity(0.06))
                        }
                )

                // ── Content ────────────────────────────────────
                ZStack {
                    WebView(urlString: urlString, isLoading: $isLoading)

                    if isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .tint(Color.fireOrange)
                                .scaleEffect(1.3)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
