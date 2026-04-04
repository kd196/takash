# 💰 Takaş — Maliyet Analizi

---

## Geliştirme Aşaması (0 Kullanıcı)

| Servis | Plan | Aylık Maliyet |
|---|---|---|
| Firebase (Spark) | Ücretsiz | $0 |
| Mapbox | Ücretsiz tier | $0 |
| Stream Chat | Maker (ücretsiz) | $0 |
| **TOPLAM** | | **$0/ay** |

> Geliştirme süresince hiçbir ödeme yapmıyorsun.

---

## MVP Aşaması (0–1.000 Kullanıcı)

| Servis | Limit | Maliyet |
|---|---|---|
| Firebase Spark | 50k okuma/gün, 20k yazma/gün, 1GB depolama | $0 |
| Mapbox Maps SDK | 25.000 MAU/ay ücretsiz | $0 |
| Stream Chat Maker | Ekip < 5 kişi ve gelir < $10k/ay şartıyla | $0 |
| **TOPLAM** | | **$0/ay** |

> 1.000 kullanıcıya kadar Firebase Spark planı yeterli olur.
> Eğer günlük limit aşılırsa Firebase otomatik ücretlendirmeye geçer,
> bu yüzden Blaze planına geç ve **bütçe alarmı** kur.

---

## Büyüme Aşaması (1.000–10.000 Kullanıcı)

| Servis | Tahmini Kullanım | Aylık Maliyet |
|---|---|---|
| Firebase Blaze | Orta trafik | ~$15–40 |
| Mapbox | Hâlâ 25k MAU altında (ücretsiz) | $0 |
| Stream Chat | Hâlâ Maker planı (gelir < $10k) | $0 |
| **TOPLAM** | | **~$15–40/ay** |

---

## Ölçek Aşaması (10.000+ Kullanıcı)

| Servis | Tahmini Kullanım | Aylık Maliyet |
|---|---|---|
| Firebase Blaze | Yüksek trafik | ~$80–200 |
| Mapbox | 25k MAU aşılırsa ~$0.50/MAU | ~$0–50 |
| Stream Chat | Gelir > $10k → Start planı | $499 |
| **TOPLAM** | | **~$580–750/ay** |

> Bu noktada zaten gelir üretiyorsundur, maliyetleri karşılayabilirsin.

---

## Firebase Blaze Geçişi

Firebase Spark → Blaze geçişi ücretsizdir ve aynı ücretsiz limitleri korur.
Farkı: Limitler aşılınca otomatik ödeme yapar.

**Mutlaka yap:** Firebase konsolunda aylık bütçe alarmı kur ($20, $50, $100 gibi).
Böylece beklenmedik bir faturayla karşılaşmazsın.

---

## Mapbox Ücretsiz Tier Detayı

- **Maps SDK Mobile:** İlk 25.000 MAU/ay ücretsiz
- Aşım: ~$0.50/MAU
- 1.000 aktif kullanıcı = $0 (25k limitin çok altında)
- 30.000 aktif kullanıcı = (30k - 25k) × $0.50 = **$2.50/ay**

Mapbox çok uzun süre ücretsiz kalacak.

---

## Özet

**Geliştirme + MVP:** $0/ay
**İlk büyüme:** $15–40/ay
**Olgunluk:** $580–750/ay (bu noktada gelir var)

Başlangıç için **hiçbir maliyet yok.** Ödeme yapmaya başladığında büyümüşsün demektir.
