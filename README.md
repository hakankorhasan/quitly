# Quit Alcohol 💧

Alkol bırakma sürecini takip etmek için geliştirilmiş bir iOS uygulaması.

## Amaç

Kullanıcıların alkol bırakma yolculuğunu kolaylaştırmak; streak takibi, sağlık kilometre taşları, tasarruf hesabı ve motivasyon araçlarıyla süreci desteklemek.

## Özellikler

- **Streak Takibi** — Bırakma tarihinden itibaren gün/saat/dakika sayacı
- **Sağlık Kilometre Taşları** — Vücudun iyileşme sürecini gösteren bilimsel veriler
- **Tasarruf Hesabı** — Alkole harcanan parayı biriktirme ve ödül hedefleri
- **Günlük Mood Check-in** — Ruh hali takibi ve motivasyon alıntıları
- **Geçmiş Denemeler** — Önceki bırakma girişimlerini görüntüleme
- **Widget Desteği** — Ana ekran widget'ı
- **Premium (Pro)** — RevenueCat üzerinden yönetilen abonelik sistemi

## Teknik Stack

- **SwiftUI** + **SwiftData** (yerel veri depolama)
- **Firebase Analytics** — Anonim kullanım analitikleri
- **Firebase Remote Config** — Uzaktan yapılandırma
- **Firebase Hosting** — Privacy Policy & Terms of Use sayfaları
- **RevenueCat** — In-app subscription yönetimi
- **Localization** — 10+ dil desteği (EN, TR, AR, DE, FR, JA, KO, RU, ZH, PT-BR)

## Yasal Sayfalar

Privacy Policy ve Terms of Use, Firebase Hosting üzerinde sunulmakta:

- https://quitalcohol-c13cd.web.app/privacy-policy.html
- https://quitalcohol-c13cd.web.app/terms-of-use.html

## Yapılan Önemli Çalışmalar

- Quit Smoking uygulamasından Quit Alcohol uygulamasına tam dönüşüm
- UI/UX yeniden tasarımı (ateş/duman temasından su/berraklık temasına)
- Localization string'leri ve motivasyonel alıntıların alkol teması için güncellenmesi
- RevenueCat entegrasyonu ve paywall implementasyonu
- Insights, Home, Settings ve Onboarding ekranlarının responsive hale getirilmesi
- Firebase Hosting'e yasal sayfaların deploy edilmesi
