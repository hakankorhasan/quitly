# Quitly → Alkol Bırakma Uygulamasına Dönüştürme

Mevcut Quitly (sigara bırakma) uygulamasını `feat/alcohol` branch'inde alkol bırakma uygulamasına dönüştürme planı.

## Mevcut Durum

- ✅ `feat/alcohol` branch'i zaten oluşturulmuş ve aktif
- Bundle ID: `com.hakankorhasan.quitsmoke`
- RevenueCat API Key: `appl_YryQlEiaGhnFelbkFestplYqJky`
- Firebase Project: `quitsmoking-2f3c7`
- Entitlement: `"Quit Smoking Pro"`

## User Review Required

> [!IMPORTANT]
> **Uygulama İsmi**: Uygulamanın yeni ismini belirlemen gerekiyor. Öneriler:
> - **Soberli** — "Sober" + "-ly" suffix, Quitly'ye benzer naming pattern
> - **Drinkless** — Açıklayıcı ve direkt
> - **SoberTrack** — Takip odaklı
> - **QuitDrink** — Quitly ile paralel

> [!IMPORTANT]
> **Bundle ID**: Yeni bundle ID ne olacak? Örnek: `com.hakankorhasan.quitdrink`

> [!WARNING]
> **3. Parti Servisler** — Aşağıdakiler için **yeni hesap/proje** oluşturman gerekiyor:
> 1. **Firebase** — Yeni bir Firebase projesi oluştur → yeni `GoogleService-Info.plist` indir
> 2. **RevenueCat** — Yeni bir uygulama ekle → yeni API key al, yeni entitlement & offering oluştur
> 3. **App Store Connect** — Yeni bir App ID oluştur (yeni bundle ID ile)
>
> Bu adımları sen yapıp bilgileri bana verirsen, ben koda entegre ederim.

## Proposed Changes

Değişiklikler 7 ana kategoriye ayrılıyor:

---

### 1. Proje Yapılandırması (Bundle ID & Naming)

#### [MODIFY] [project.pbxproj](file:///Users/hakan/Desktop/quitly/quitly/quitly.xcodeproj/project.pbxproj)
- `PRODUCT_BUNDLE_IDENTIFIER` → yeni bundle ID
- `PRODUCT_NAME` → yeni uygulama ismi
- Display name güncelleme

#### [MODIFY] [quitlyApp.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/quitlyApp.swift)
- Struct adı: `quitlyApp` → yeni isim (ör: `soberliApp`)
- RevenueCat API key → yeni key (senden alınacak)

#### [MODIFY] [GoogleService-Info.plist](file:///Users/hakan/Desktop/quitly/quitly/quitly/GoogleService-Info.plist)
- Tüm Firebase config → yeni proje bilgileri (senden alınacak)

#### [MODIFY] [quitly.entitlements](file:///Users/hakan/Desktop/quitly/quitly/quitly/quitly.entitlements)
- App group identifier güncelleme

---

### 2. Sağlık Kilometre Taşları (Alkole Özel)

#### [MODIFY] [HealthMilestone.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/HealthMilestone.swift)

Sigara milestone'ları tamamen alkol bırakma milestone'larıyla değiştirilecek:

| Süre | Alkol Bırakma Etkisi |
|------|---------------------|
| 6 saat | Kan şekeri normalleşmeye başlar |
| 12 saat | Vücut alkolü metabolize etmeye başlar |
| 24 saat | Kan basıncı düşmeye başlar, beyin bulanıklığı azalır |
| 48 saat | Tüm alkol vücuttan atılır, uyku kalitesi iyileşir |
| 72 saat | Karaciğer yağlanması azalmaya başlar |
| 1 hafta | Cilt hidrasyonu artar, enerji seviyeleri yükselir |
| 2 hafta | Mide asidi normalleşir, sindirim düzelir |
| 3 hafta | Kan basıncı normal seviyelere ulaşır |
| 1 ay | Karaciğer fonksiyonları belirgin şekilde iyileşir |
| 6 hafta | Kolesterol seviyeleri düşer |
| 2 ay | Bağışıklık sistemi güçlenir |
| 3 ay | Karaciğer yağlanması önemli ölçüde azalır |
| 6 ay | Cilt görünümü dramatik şekilde iyileşir |
| 9 ay | Mental berraklık ve hafıza iyileşir |
| 1 yıl | Karaciğer hasarı önemli ölçüde iyileşir |
| 2 yıl | Kalp hastalığı riski ciddi oranda düşer |

- İkonlar alkole uygun değişecek (akciğer ikonları → karaciğer, beyin, kalp ikonları)
- Custom icon'lar (`lungs`, `heart_attack`, `oxygen_block` vb.) → alkol temalı custom ikonlar

---

### 3. Design System (Renk ve Tema)

#### [MODIFY] [DesignSystem.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/DesignSystem.swift)

Renk paletini alkol temasına uygun değiştirme önerisi:

| Mevcut (Sigara) | Yeni (Alkol) | Açıklama |
|-----------------|-------------|----------|
| `fireOrange` (#FF6B35) | `soberBlue` (#3B82F6) veya `aquaTeal` (#06B6D4) | Ana vurgu rengi: ateş→su/berraklık |
| `purpleAccent` (#A855F7) | `amberGold` (#F59E0B) veya aynı kalabilir | İkincil vurgu |
| `greenClean` (#10B981) | Aynı kalır | Sağlık/ilerleme rengi |
| `goldAccent` (#F59E0B) | `roseAccent` (#F43F5E) veya aynı kalır | Premium/başarı rengi |

> [!NOTE]
> Renk değişikliği opsiyonel — eğer aynı renk paletini kullanmak istiyorsan, sadece "fire" isimlendirmesini değiştirebiliriz. Ama farklılaştırmak markalaşma için daha iyi olur.

Gradient'ler de buna göre güncellenecek (`AppGradient.fire` → `AppGradient.primary` vb.)

---

### 4. UI Değişiklikleri

#### [MODIFY] [SplashView.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/SplashView.swift)
- `SmokeEffectView` (duman partikül efekti) → **kaldırılacak** veya su damlası/kabarcık efektiyle değiştirilecek
- Splash icon → yeni uygulama ikonu (`splash_page` asset)

#### [MODIFY] [OnboardingView.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/OnboardingView.swift)
- `"burning_fire"` ikonu → yeni uygulama ikonu (ör: su damlası, kalkan, vb.)
- Flame pulse animasyonu → uygun yeni animasyon

#### [MODIFY] [HabitSetupView.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/HabitSetupView.swift)
- `smokingEmoji = "wind"` → `alcoholEmoji = "drop.fill"` veya `"wineglass"`
- `smokingName = "Smoking"` → `alcoholName = "Drinking"` veya `"Alcohol"`
- `"burning_fire"` ikonu → yeni ikon

#### [MODIFY] [HomeView.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/HomeView.swift)
- Fire-related referanslar → yeni tema referansları

#### [MODIFY] [PaywallView.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/PaywallView.swift)
- `"burning_fire"` → yeni ikon
- Feature list'teki başlıklar alkol bırakmaya uygun olacak

#### [MODIFY] [StreakHeroView.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/StreakHeroView.swift)
- Fire gradient/renk referansları → yeni tema

#### Tüm View dosyaları
- `FireButtonStyle` → `PrimaryButtonStyle` (veya yeni isim)
- `burning_fire` image referansları → yeni ikon

---

### 5. Premium & Monetization

#### [MODIFY] [PremiumManager.swift](file:///Users/hakan/Desktop/quitly/quitly/quitly/PremiumManager.swift)
- `kEntitlement = "Quit Smoking Pro"` → yeni entitlement adı (ör: `"Quit Drinking Pro"`)
- `kOffering` ve `kPackage` → RevenueCat'te yeni tanımlanacak değerler

---

### 6. Motivasyon Alıntıları

#### [MODIFY] [Localizable.xcstrings](file:///Users/hakan/Desktop/quitly/quitly/quitly/Localizable.xcstrings)
- 200 motivasyon alıntısı (`mq_quote_0` → `mq_quote_199`) → alkol bırakma odaklı alıntılar
- Tüm UI string'leri alkol bırakma bağlamına uygun güncelleme:
  - `"app_name"` → Yeni uygulama adı
  - `"onboarding_tagline"` → Alkol bırakma tagline
  - Milestone başlıkları ve açıklamaları
  - Paywall metinleri
- Tüm dillerde (TR, EN, AR, DE, FR, JA, KO, PT, RU, ZH) çeviriler

---

### 7. Asset Değişiklikleri

#### [MODIFY] Assets.xcassets
- App Icon → yeni uygulama ikonu (generate_image ile oluşturulacak)
- `burning_fire` → yeni ana ikon (ör: su damlası, kalkan)
- `splash_page` → yeni splash görseli
- Sigara-spesifik custom ikonlar (`lungs`, `heart_attack`, `oxygen_block`, `energy_flash`) → alkol-spesifik ikonlar

#### [MODIFY] Widget Assets
- Widget ikonları ve görselleri güncelleme

---

### 8. Legal Dokümanlar

#### [MODIFY] [privacy-policy.html](file:///Users/hakan/Desktop/quitly/quitly/quitly/privacy-policy.html)
- Uygulama adı ve açıklama güncelleme

#### [MODIFY] [terms-of-use.html](file:///Users/hakan/Desktop/quitly/quitly/quitly/terms-of-use.html)
- Uygulama adı ve açıklama güncelleme

---

## Uygulama Sırası

1. **Önce sen yapacakların** (ben beklerim):
   - [ ] Uygulama ismini belirle
   - [ ] Bundle ID belirle
   - [ ] Firebase'de yeni proje oluştur → `GoogleService-Info.plist` indir
   - [ ] RevenueCat'te yeni app oluştur → API key, entitlement adı, offering adı ver
   - [ ] App Store Connect'te yeni App ID oluştur

2. **Ben yapacaklarım** (senin bilgilerin gelince):
   - [ ] Proje yapılandırması güncelleme
   - [ ] HealthMilestone → alkol milestone'ları
   - [ ] Design system renk/tema değişiklikleri
   - [ ] UI güncellemeleri (splash, onboarding, home, paywall)
   - [ ] Yeni ikonlar ve görseller oluşturma
   - [ ] Localization güncelleme (200 quote + tüm UI strings)
   - [ ] Legal doküman güncelleme

## Open Questions

> [!IMPORTANT]
> 1. **Uygulama adı** ne olsun? (Soberli, Drinkless, SoberTrack, QuitDrink veya başka bir isim?)
> 2. **Renk paleti** değişsin mi? Yoksa aynı turuncu-mor temasını mı koruyalım?
> 3. **Splash animasyonu**: Duman efekti yerine ne koyalım? (Su damlası/kabarcık efekti, temiz bir fade-in, veya tamamen kaldıralım?)
> 4. **Ana ikon/maskot**: `burning_fire` yerine ne kullanacağız? (Su damlası 💧, kalkan 🛡️, yaprak 🍃, veya custom bir ikon?)

## Verification Plan

### Automated Tests
- Xcode build test: `xcodebuild -scheme <yeniScheme> build`
- Tüm localization key'lerinin doğruluğu

### Manual Verification
- Splash → Onboarding → Setup flow'unun çalıştığını doğrulama
- Health milestone'larının doğru sırada görüntülendiğini kontrol
- Widget'ın çalıştığını doğrulama
- Paywall ve premium flow'un çalıştığını doğrulama
