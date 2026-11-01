# CoTab — Yol Haritası

Nov 1, 2026 · @Enes

## Özet ve takvim

Hedef: 22 Kasım'a kadar iki cihazda çalışan bir çekirdek sürüm, 25 Aralık'ta özellik dondurma, 14. haftadaki son derste final sunumu. Dönem 14 ders haftası ve aradaki 2 haftalık vize döneminden oluşuyor; aşağıdaki hafta numaralarına vize dahil değil.

| Hafta | Tarih | Ne oluyor |
| --- | --- | --- |
| 1.–7. hafta | 14 Eylül–30 Ekim | Konu seçimi, kapsam ve iş planı dokümanı, GitHub deposu |
| Vize dönemi | 2–13 Kasım | Çekirdek geliştirme, hafif tempo |
| 8. hafta | 16–20 Kasım | İlk tur sunumu (5–10 dk) |
| 8.–11. hafta | 16 Kasım–11 Aralık | Çekirdek sürümün bitişi (22 Kasım) ve ek modüller |
| 12.–13. hafta | 14–25 Aralık | Entegrasyon, test, özellik dondurma (25 Aralık) |
| 14. hafta | 28 Aralık–1 Ocak | Final sunumu, demo videosu, proje raporu |

Bu tarihler ekip içi takip içindir. Hocaya giden dokümanda aşamalar yalnızca "vize öncesi", "vize sonrası" ve "final öncesi" olarak yazılıdır.

## Ürün kapsamı

Ürün üç katmanda büyür: önce grup ve harcama çekirdeği çalışır, sonra fiş tarama, nöbet ve alışveriş listesi eklenir, en son modüller birbirine bağlanır. Her katman tek başına sunulabilir durumda olmalı.

**Hedef kitle:** öğrenci evinde yaşayan 2–6 kişilik gruplar (birincil), birlikte seyahat eden arkadaş grupları (ikincil). İkisi de aynı "grup" kavramını kullandığı için ayrı mimari gerekmez.

| Katman | Özellikler | Hedef |
| --- | --- | --- |
| Çekirdek sürüm (MVP) | Kayıt/giriş; grup oluşturma ve davet kodu/QR ile katılma; manuel harcama ekleme; eşit, yüzde ve tutar bazlı bölüştürme; kişi bakiyeleri; harcama geçmişi; SQLite'ta offline kayıt + sunucuya senkron | 22 Kasım |
| Genişletilmiş sürüm | Fiş tarama (OCR) ve kalem bazlı bölüştürme; borç sadeleştirme ve "ödeme yaptım" kaydı; nöbet çizelgesi (rotasyon + hatırlatma bildirimi); ortak alışveriş listesi (gerçek zamanlı); alınan ürünün tek dokunuşla harcamaya dönüşmesi; Türkçe dil seçeneği | 25 Aralık |
| Opsiyonel | Aylık harcama grafikleri ve kategori istatistikleri; seyahat için döviz desteği; tekrarlayan harcamalar (kira, internet); karanlık mod; Play Store kapalı test yayını | Zaman kalırsa |

**Splitwise'tan farkımız (sunumda öne çıkarılacak):**

- **Kalem bazlı fiş bölüştürme:** fiş taranır, her ürün bir veya birkaç kişiye atanır.
- **Türk fişlerine özel ayrıştırma:** market adı, tarih, TOPLAM ve KDV satırları otomatik bulunur; kullanıcı onay ekranında düzeltir.
- **Ev yönetimi tek yerde:** harcama, nöbet ve alışveriş listesi birbirine bağlı. Listeden alınan ürün harcamaya, harcama bakiyeye dönüşür.

**Kapsam dışı:** gerçek para transferi veya ödeme entegrasyonu, web sürümü, sohbet/mesajlaşma.

## Teknik mimari

Önerilen yapı offline-first: uygulama her zaman yerel SQLite veritabanından okur ve yazar, bir senkron servisi değişiklikleri arka planda sunucuya taşır. Böylece 6. maddedeki SQLite ve uzak sunucu şartlarının ikisi de gerçek bir ihtiyaçla karşılanır.

| Katman | Flutter paketi / araç |
| --- | --- |
| Arayüz | Flutter + Material 3 |
| Durum yönetimi | flutter\_riverpod |
| Navigasyon | go\_router |
| Yerel veritabanı | drift (SQLite üzerine, tip güvenli sorgular ve migration) |
| Uzak sunucu | firebase\_auth, cloud\_firestore, firebase\_storage |
| Fiş okuma | google\_mlkit\_text\_recognition (cihaz üstünde, internetsiz) |
| Kamera ve kırpma | camera veya image\_picker + image\_cropper |
| Bildirim | firebase\_messaging + flutter\_local\_notifications |
| Ağ durumu | connectivity\_plus (bağlantı gelince senkronu tetikler) |
| QR ile davet | qr\_flutter (üretme) + mobile\_scanner (okuma) |
| Grafikler (opsiyonel) | fl\_chart |
| Test | flutter\_test, mocktail |

Proje Flutter (Dart) ile geliştirilecek; tek kod tabanından Android ve iOS çıkar. Firestore'un kendi offline önbelleği olsa da veri kaynağı drift (SQLite) olarak kalmalı; 6. madde böylece açıkça karşılanır. Final sunumunda kaynak koddan soru geleceği için her üye kendi modülündeki paketlerin nasıl çalıştığını açıklayabilmeli.

**Veri modeli (SQLite tabloları):**

| Tablo | Temel alanlar |
| --- | --- |
| users | id, ad, e-posta, avatar |
| groups | id, ad, tür (ev/seyahat), para birimi, davet kodu |
| group\_members | group\_id, user\_id, rol, katılma tarihi |
| expenses | id, group\_id, ödeyen, tutar, kategori, tarih, fiş görseli, bölüştürme tipi |
| expense\_items | id, expense\_id, ürün adı, tutar (fişten gelen kalemler) |
| expense\_shares | expense\_id veya item\_id, user\_id, pay tutarı |
| settlements | id, group\_id, ödeyen, alan, tutar, tarih |
| chores | id, group\_id, ad, tekrar sıklığı, rotasyon sırası |
| chore\_assignments | chore\_id, user\_id, tarih, tamamlandı mı |
| shopping\_items | id, group\_id, ad, ekleyen, alındı mı, bağlı harcama |
| sync\_queue | tablo, kayıt id, işlem tipi, zaman damgası (yalnızca yerelde) |

**Kilit algoritmalar:**

- **Borç sadeleştirme:** herkesin net bakiyesini hesapla, en çok borçlu olanla en çok alacaklı olanı eşleştir, biri sıfırlanana kadar tekrarla. n kişide en fazla n−1 ödeme çıkar. Birim testi yazın; sunumda gösterilecek parça bu.
- **Fiş ayrıştırma:** OCR metnini satırlara böl, "TOPLAM", "KDV", tarih ve fiyat desenlerini düzenli ifadelerle yakala, sonucu düzenlenebilir bir onay ekranında göster.
- **Senkron çakışması:** harcamalar ekleme-ağırlıklı olduğu için "son yazan kazanır" ve silmede yumuşak silme (deleted\_at) yeterli.

## Ekip organizasyonu

Her üye bir yönetim rolü ve bir kod modülü üstlenir; böylece herkesin kod katkısı %5'in çok üstünde kalır ve performans raporu modül bazında tutulabilir.

| Üye | Yönetim rolü | Kod modülü | Destek verdiği alan |
| --- | --- | --- | --- |
| Enes Çelik | Proje yöneticisi (yürütücü) | Grup ve harcama modülü, veri modeli ve SQLite, bölüştürme ve borç sadeleştirme algoritması | Haftalık rapor, sprint planı, performans kaydı |
| Enes Yahya Bodur | Teknik lider (QA) | Flutter proje yapısı; fiş tarama: kamera, OCR, ayrıştırma, onay ekranı, kalem bazlı paylaşım | Kod incelemesi, test, sürüm (APK) çıkarma |
| Ahmet Anıl Çay | Halkla ilişkiler sorumlusu | Backend ve senkron: Firebase, auth, bildirimler; nöbet ve alışveriş listesi | Blog, YouTube, LinkedIn paylaşımları |

**Performans kaydı:** PM her hafta GitHub Issues üzerinden her üyenin aldığı ve kapattığı görevleri, PR sayısını ve gecikmeleri bir tabloya işler. Dönem sonunda GitHub Insights (Contributors) ekran görüntüsüyle birlikte rapora eklenir.

&#91;embedded content: organizasyon şeması · 3 üye\]

Hocaya giden dokümandaki organizasyon şemasıyla aynı dağılım.

## Faz faz yol haritası

Beş faz ve üç kapı var: çekirdek sürüm (22 Kasım), özellik dondurma (25 Aralık) ve final teslimi. Bir kapıdan geçmeden sonraki faza yeni özellik eklenmez.

&#91;embedded content: yol haritası · 5 faz, 3 kapı\]

Çekirdek sürüm ilk ve en kritik kapı: vize döneminde tempo düşük olacağı için 8. haftadaki ilk tur sunumuna kadar en azından grup ve harcama ekranları çalışır durumda olmalı.

### Faz 0 — Kuruluş (20 Ekim–1 Kasım)

- [x] Kapsam ve iş planı dokümanı, organizasyon şeması (Enes Çelik)
- [x] Proje adı: CoTab; public GitHub deposu (enescelik00/CoTab) ve README
- [x] Teknoloji kararı: Flutter + Dart
- [ ] Enes Yahya ve Ahmet Anıl'ın collaborator olarak eklenmesi
- [ ] Flutter proje iskeleti, katmanlı klasör yapısı (features/ altında modül bazlı), flutter\_lints ayarları (Enes Yahya Bodur)
- [ ] Firebase projesi, Auth ve Firestore kurulumu (Ahmet Anıl Çay)
- [ ] Figma'da 8–10 ekranlık tel kafes: giriş, grup listesi, grup detayı, harcama ekle, fiş tara, bakiyeler, nöbet, alışveriş listesi (herkes)

### Faz 1 — Çekirdek MVP (2–22 Kasım, vize dönemi dahil)

- drift (SQLite) şeması ve repository katmanı (Enes Çelik)
- Grup oluşturma, davet kodu ve QR ile katılma (Ahmet Anıl Çay)
- Harcama ekleme, eşit/yüzde/tutar bölüştürme, bakiye ekranı (Enes Çelik)
- Kayıt ve giriş, Firestore'a temel senkron (Ahmet Anıl Çay)
- Kamera ekranı ve ML Kit ile ham metin çıkarma denemesi (Enes Yahya Bodur)
- **İlk tur sunumu (8. hafta, 16–20 Kasım):** amaç, kapsam, ekip, iş planı ve o ana kadarki ekran görüntüleri
- **Kapı 1 (22 Kasım):** iki gerçek telefonda aynı grubu gören, harcama ekleyip bakiye hesaplayan çekirdek sürüm

### Faz 2 — Ek modüller (23 Kasım–11 Aralık)

- Fiş ayrıştırma (toplam, tarih, kalemler) ve düzenlenebilir onay ekranı (Enes Yahya Bodur)
- Kalem bazlı bölüştürme arayüzü (Enes Yahya Bodur + Enes Çelik)
- Borç sadeleştirme algoritması, birim testleri, "ödeme yaptım" akışı (Enes Çelik)
- Nöbet çizelgesi, rotasyon ve hatırlatma bildirimleri (Ahmet Anıl Çay)
- Ortak alışveriş listesi, gerçek zamanlı güncelleme (Ahmet Anıl Çay)
- Türkçe dil desteği (flutter\_localizations + ARB dosyaları) (herkes, kendi ekranları için)

### Faz 3 — Entegrasyon ve cila (14–25 Aralık)

- Alınan ürünün harcamaya dönüşmesi, modüller arası bağlantılar (Enes Çelik + Ahmet Anıl Çay)
- Offline senaryolar ve senkron çakışma testleri (Ahmet Anıl Çay)
- Fiş okuma doğruluğunu 20+ gerçek fişle ölçme ve iyileştirme (Enes Yahya Bodur)
- Boş durum ekranları, hata mesajları, yükleme durumları, karanlık mod (herkes)
- 3–5 kişilik gerçek kullanıcı testi (Enes Yahya Bodur)
- **Kapı 2 (25 Aralık):** özellik dondurma, bundan sonra yalnızca hata düzeltme

### Faz 4 — Teslim (28 Aralık–son ders)

- Son hata düzeltmeleri ve kararlı APK'nın etiketlenmesi (Enes Yahya Bodur)
- Demo videosu çekimi ve kurgusu (Ahmet Anıl Çay)
- Proje raporu: tüm haftalık raporlar, dokümanlar, performans raporu (Enes Çelik)
- Final sunumu provası, kaynak kod sorularına hazırlık (herkes)
- Opsiyonel: Play Store kapalı test yayını
- **Kapı 3:** 14. haftadaki son derste final sunumu; video ve rapor teslimi

## Ders gereksinimleri kontrol listesi

Dokuz maddenin sekizi zorunlu; hepsi yukarıdaki fazlara bağlandı.

| # | Gereksinim | Nasıl karşılanıyor | Durum |
| --- | --- | --- | --- |
| 1 | Başlık, kapsam, iş planı dokümanı | Proje Başlığı, Kapsam ve İş Planı dokümanı (CoTab) | Hazır |
| 2 | Yürütücü ve organizasyon şeması | Dokümanın 7. bölümü: şema ve görev tablosu | Hazır |
| 3 | Public GitHub, herkes katkıcı, kişi başı en az %5 kod | github.com/enescelik00/CoTab; her üye kendi modülünde PR açar | Depo açık, collaborator ve ilk commit'ler bekliyor |
| 4 | Haftalık ilerleme raporu ve sırayla sunum | Haftalık rutin bölümündeki şablon | Her hafta |
| 5 | Halkla ilişkiler sorumlusu ve tanıtım | Ahmet Anıl Çay; blog, YouTube, LinkedIn takvimi | İlk paylaşım ilk tur sunumuyla |
| 6 | SQLite ve/veya uzak sunucu | İkisi birden: drift (SQLite) + Cloud Firestore | Faz 1 |
| 7 | Ara prototip, final sunumu, final videosu | Kapı 1 (çekirdek sürüm) ve Kapı 3 | 22 Kasım, son ders |
| 8 | Proje raporu, süreçteki tüm dosyalar dahil | Tüm dokümanlar repo içinde /docs klasöründe | Faz 4 |
| 9 | (Opsiyonel) Mağazada yayın | Play Store kapalı test | Zaman kalırsa |

Dikkat: ödevde listelenen başlıklar bitirme projesi olarak sunulursa reddediliyor. Bu proje o listede yok, ama yine de bitirme projenizle örtüşmemesine dikkat edin.

## Haftalık rutin

Haftada bir 30 dakikalık toplantı ve sabit bir rapor şablonu, hem ilerleme sunumlarını hem de final raporunu neredeyse kendiliğinden üretir.

**Haftalık döngü:**

1. Pazartesi: 30 dk planlama toplantısı; geçen haftanın Issues'ları kapatılır, yeni görevler atanır.
2. Hafta içi: her görev bir branch ve bir PR; PR'ı en az bir başka üye onaylar.
3. Cuma: PM ilerleme raporunu doldurur, PR sorumlusu o haftanın paylaşımını yapar.

**İlerleme raporu şablonu (1 sayfa / 3–4 slayt):**

- Bu hafta tamamlananlar (kişi bazında, Issue linkleriyle)
- Ekran görüntüleri veya kısa GIF
- Gelecek hafta planı
- Riskler ve engeller
- Tanıtım faaliyetleri (paylaşım linkleri)
- Kişi bazında katkı tablosu (açılan/kapanan görev, PR sayısı)

**GitHub iş akışı:**

- main korumalı; doğrudan push yok, yalnızca PR ile birleştirme
- Branch adı: feature/fis-tarama, fix/bakiye-yuvarlama gibi
- Commit mesajı: feat:, fix:, docs:, test: önekleri
- Her Issue'da sorumlu, etiket (modül) ve hedef faz (milestone)
- Görevler GitHub Projects panosunda: Yapılacak, Devam ediyor, İncelemede, Bitti

**Tanıtım içerik takvimi:**

| Ne zaman | İçerik | Kanal |
| --- | --- | --- |
| İlk tur sunumu (8. hafta) | Proje tanıtımı: problem, fikir, ekip | Blog (Medium) + LinkedIn |
| Kapı 1 sonrası (9. hafta) | 1–2 dk uygulama demosu | YouTube |
| Faz 2 ortası (10. hafta) | "Fişi tara, hesabı böl" kısa video | YouTube Shorts / LinkedIn |
| Faz 3 (12. hafta) | Teknik yazı: offline-first senkron veya borç sadeleştirme algoritması | Blog |
| Kapı 3 (14. hafta) | Final tanıtım videosu (ders teslimi ile aynı video) | YouTube |

## Riskler ve önlemler

En büyük iki risk kapsamın şişmesi ve fiş okumanın beklenenden zayıf çıkması; ikisinin de geri dönüş planı hazır.

| Risk | Etki | Önlem |
| --- | --- | --- |
| Kapsam şişmesi, üç uygulamayı birden yetiştirememek | Yüksek | Katman sırası sabit: MVP bitmeden v1'e geçilmez; opsiyoneller yalnızca Kapı 2'den önce boş zaman varsa |
| Buruşuk/soluk termal fişte OCR kalemleri yanlış eşleştiriyor | Yüksek | Önce yalnızca TOPLAM ve tarih otomatik; kalemler onay ekranında düzeltilebilir; kırpma ve kontrast ön işleme |
| Senkron çakışmaları ve veri kaybı | Orta | sync\_queue, yumuşak silme, son yazan kazanır; Faz 3'te uçak modu testleri |
| Üyelerin zamanı kısıtlı (iş, staj, diğer dersler) | Orta | Haftalık küçük görevler; tıkanan görev 3 gün içinde PM'e bildirilir ve yeniden dağıtılır |
| Bir üyenin kod katkısının %5'in altında kalması | Orta | Modül sahipliği; PM her hafta GitHub Insights'ı kontrol eder |
| Firebase ücretsiz kota veya yapılandırma sorunları | Düşük | Spark planı bu ölçek için yeterli; okuma sayısını azaltmak için yerel önbellek zaten SQLite |
| Demo günü canlı hata | Orta | Kapı 2 sonrası kararlı APK etiketlenir; demo için hazır test grubu ve örnek fişler; yedek ekran kaydı |

## Sıradaki adımlar (vize dönemi, 2–13 Kasım)

Vize döneminde tempo düşük olacak; amaç 8. haftadaki ilk tur sunumuna depoyu dolu ve birkaç ekranı çalışır halde götürmek.

- [ ] Kapsam ve iş planı dokümanını hocaya gönder (Enes Çelik)
- [ ] Enes Yahya ve Ahmet Anıl'ı GitHub'da collaborator olarak ekle; README'yi depoya yükle (Enes Çelik)
- [ ] Üç kişide aynı Flutter sürümüyle kurulum; flutter create ile iskeleti main'e gönder (Enes Yahya Bodur)
- [ ] Firebase projesini aç, FlutterFire ile bağla; config dosyalarını .gitignore'a ekle (Ahmet Anıl Çay)
- [ ] drift şeması: users, groups, group\_members, expenses, expense\_shares (Enes Çelik)
- [ ] GitHub Projects panosunu aç, Faz 1 görevlerini Issue olarak gir (Enes Çelik)
- [ ] Figma'da en az 4 ana ekranın tel kafesi: grup detayı, harcama ekle, fiş tara, bakiyeler (herkes)
- [ ] İlk tur sunumu slaytları: problem, çözüm, Splitwise'tan farkı, kapsam, ekip, iş planı, ekran görüntüleri (8. hafta öncesi)
- [ ] İlk blog/LinkedIn yazısının taslağı (Ahmet Anıl Çay)
