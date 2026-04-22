import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, '1. Topladığımız Veriler', '''
Takaş uygulamasını kullanırken aşağıdaki verileri toplayabiliriz:

• **Hesap Bilgileri**: E-posta adresi, gösterilen isim, profil fotoğrafı
• **Konum Verisi**: Kullanıcının konumu (il ilanları ve harita özelliği için)
• **İlan Bilgileri**: Oluşturduğunuz ilanlar, fotoğraflar ve açıklamalar
• **Sohbet Verileri**: Diğer kullanıcılarla olan mesajlaşmalarınız
• **Cihaz Bilgileri**: Bildirimler için cihaz token'ı
          '''),
          _buildSection(context, '2. Verilerin Kullanımı', '''
Topladığımız verileri şu amaçlarla kullanıyoruz:

• Profilinizi oluşturmak ve yönetmek
• İlanlarınızı diğer kullanıcılara göstermek
• Takas tekliflerinizi yönetmek
• Konum tabanlı özellikleri sunmak (yakınındaki ilanlar, harita)
• Bildirimler göndermek (mesajlar, teklifler)
• Uygulama performansını analiz etmek
          '''),
          _buildSection(context, '3. Verilerin Paylaşımı', '''
Kişisel verilerinizi üçüncü taraflarla paylaşmayız. Ancak:

• Takas sürecinde diğer kullanıcılar ilan bilgilerinizi görebilir
• Firebase (Google) altyapısını kullanıyoruz (güvenli sunucular)
• Yasal zorunluluk durumunda yetkililerle paylaşabiliriz
          '''),
          _buildSection(context, '4. Veri Güvenliği', '''
Verilerinizin güvenliği bizim için önemlidir:

• Tüm veriler şifrelenmiş bağlantılar (HTTPS) üzerinden iletilir
• Firebase Güvenlik Kuralları ile veritabanı erişimi kontrol edilir
• Hesabınızı istediğiniz zaman silebilirsiniz
          '''),
          _buildSection(context, '5. Haklarınız', '''
KVKK kapsamında haklarınız:

• Verilerinize erişme hakkı
• Verilerinizi düzeltme hakkı
• Verilerinizi silme hakkı (hesap silme)
• İşleme itiraz etme hakkı

Hesabınızı silmek için Ayarlar > Hesabı Sil bölümünü kullanabilirsiniz.
          '''),
          _buildSection(context, '6. Çocukların Korunması', '''
Uygulamamız 18 yaş üstü kullanıcılar için tasarlanmıştır. 18 yaşından küçük kişilerin kişisel verilerini toplamıyoruz.
          '''),
          _buildSection(context, '7. Politikası Değişiklikler', '''
Bu gizlilik politikasını zaman zaman güncelleyebiliriz. Önemli değişikliklerde uygulama içi bildirim göndereceğiz.
          '''),
          _buildSection(context, '8. İletişim', '''
Gizlilik politikamız hakkında sorularınız varsa:

E-posta: destek@takash.app
          '''),
          const SizedBox(height: 32),
          Text(
            'Son güncelleme: Nisan 2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
