//
//  RemoteConfigManager.swift
//  quitly
//
//  Firebase Remote Config'ten app_version ve app_store_url değerlerini çeker.
//  Güncel uygulama versiyonuyla karşılaştırıp güncelleme popup'ı gösterip göstermemeye karar verir.
//

import Foundation
import FirebaseRemoteConfig

@Observable
final class RemoteConfigManager {

    // MARK: - State
    var shouldShowUpdate = false
    var appStoreURL: String = ""
    var latestVersion: String = ""

    // MARK: - Keys
    private let kAppVersion  = "app_version"
    private let kAppStoreURL = "app_store_url"

    // MARK: - Dismiss tracking
    /// Kullanıcı popup'ı kapattıysa bu versiyonu bir daha gösterme
    private var dismissedVersion: String? {
        get { UserDefaults.standard.string(forKey: "dismissed_update_version") }
        set { UserDefaults.standard.set(newValue, forKey: "dismissed_update_version") }
    }

    // MARK: - Fetch & Evaluate

    @MainActor
    func checkForUpdate() async {
        let rc = RemoteConfig.remoteConfig()

        // Minimum fetch interval (development'ta 0, production'da 3600 yap)
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 saat
        rc.configSettings = settings

        // Defaults
        rc.setDefaults([
            kAppVersion:  NSString(string: "1.0"),
            kAppStoreURL: NSString(string: "")
        ])

        do {
            let status = try await rc.fetchAndActivate()
            print("[RemoteConfig] Status: \(status)")

            let remoteVersion = rc.configValue(forKey: kAppVersion).stringValue ?? "1.0"
            let storeURL      = rc.configValue(forKey: kAppStoreURL).stringValue ?? ""

            latestVersion = remoteVersion
            appStoreURL   = storeURL

            // Mevcut uygulama versiyonu
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

            print("[RemoteConfig] Current: \(currentVersion) | Remote: \(remoteVersion) | URL: \(storeURL)")

            // Versiyon karşılaştırması
            if isVersion(remoteVersion, greaterThan: currentVersion) {
                // Kullanıcı bu versiyonu daha önce dismiss ettiyse tekrar gösterme
                if dismissedVersion != remoteVersion {
                    shouldShowUpdate = true
                }
            }
        } catch {
            print("[RemoteConfig] Error: \(error.localizedDescription)")
        }
    }

    /// Kullanıcı "Sonra" dediğinde çağır
    func dismissUpdate() {
        dismissedVersion = latestVersion
        shouldShowUpdate = false
    }

    // MARK: - Version Comparison
    /// "1.2.0" > "1.1.0" → true
    private func isVersion(_ v1: String, greaterThan v2: String) -> Bool {
        let parts1 = v1.split(separator: ".").compactMap { Int($0) }
        let parts2 = v2.split(separator: ".").compactMap { Int($0) }

        let maxLen = max(parts1.count, parts2.count)
        for i in 0..<maxLen {
            let a = i < parts1.count ? parts1[i] : 0
            let b = i < parts2.count ? parts2[i] : 0
            if a > b { return true }
            if a < b { return false }
        }
        return false
    }
}
