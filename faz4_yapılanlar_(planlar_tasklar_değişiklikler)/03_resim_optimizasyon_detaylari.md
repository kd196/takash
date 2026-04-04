# Faz 4: Resim Sınırlama ve Optimizasyon Detayları

## 📸 Optimizasyon Stratejisi
Maliyetleri ve depolama kullanımını kontrol altında tutmak için şu kurallar uygulanacaktır:

1. **Resize:** Kullanıcı hangi çözünürlükte yüklerse yüklesin, resim `1024x1024` piksel içine sığdırılacaktır.
2. **Compression:** JPEG formatında %70 kalite oranı kullanılacaktır (Ortalama 200-300 KB hedef).
3. **Limit:** Her bireysel sohbet (`chatId`) için maksimum **3 resim** yükleme hakkı tanınacaktır.

## 💎 Premium Hazırlık (Gelecek Vizyonu)
- Ücretsiz kullanıcılar: 3 resim / sohbet.
- Premium kullanıcılar: Sınırsız resim ve yüksek kaliteli (2048px) yükleme.

## 🛠️ Teknik Takip
`chats/{chatId}` dökümanındaki `imageCount` alanı, her resim mesajında atomik olarak artırılacaktır. Gönderim öncesi bu alan kontrol edilerek kullanıcıya gerekirse uyarı gösterilecektir.
