import 'dart:convert';
import 'package:http/http.dart' as http;

class MealDBService {
  /// Mengambil data bahan masakan dan langkah-langkah pembuatan resep dari API
  /// atau menggunakan basis data lokal khas Indonesia jika hidangannya autentik tradisional.
  Future<Map<String, dynamic>> fetchRecipe(String foodName) async {
    final normalized = foodName.toLowerCase();

    // 1. Periksa hidangan tradisional Indonesia terlebih dahulu
    if (normalized.contains('matang')) {
      return {
        'ingredients': [
          '500 gram Daging Sapi (potong dadu kecil)',
          '10 tusuk Sate (lidi)',
          '5 siung Bawang Merah & 3 siung Bawang Putih',
          '2 cm Jahe & 2 cm Lengkuas',
          '1 sdm Ketumbar bubuk',
          '500 ml Santan cair (untuk kuah soto)',
          '2 batang Serai & 3 lembar Daun Jeruk',
          '100 gram Kacang Tanah (goreng & haluskan untuk saus)',
          'Garam, gula, kecap manis secukupnya'
        ],
        'instructions': '1. Haluskan bawang merah, putih, jahe, ketumbar, lengkuas, garam, dan sedikit gula.\n2. Lumuri daging sapi dengan bumbu halus tersebut, diamkan 30 menit agar meresap.\n3. Tusuk daging pada lidi sate lalu panggang di atas bara api hingga matang beraroma harum.\n4. Buat kuah soto berempah kental dengan merebus santan bersama bumbu soto sisa, serai, daun jeruk, dan garam.\n5. Buat saus kacang gurih manis dengan mencampurkan kacang tanah halus, kecap manis, garam, dan sedikit kuah kaldu.\n6. Sajikan Sate Matang hangat bersama nasi, kuah soto berempah kental, dan cocolan saus kacang kental.'
      };
    } else if (normalized.contains('aceh')) {
      return {
        'ingredients': [
          '300 gram Mie Kuning basah/tebal',
          '150 gram Daging Sapi atau Udang kupas',
          '4 siung Bawang Merah & 3 siung Bawang Putih',
          '3 butir Kemiri (sangrai)',
          '1 sdm Bubuk Kari khas Aceh',
          '1 batang Daun Bawang & Seledri (iris)',
          '50 gram Toge segar',
          '1 sdm Kecap Manis & 1 sdt Kecap Asin',
          'Acar bawang merah & emping melinjo'
        ],
        'instructions': '1. Haluskan bawang merah, bawang putih, kemiri, cabai merah, dan campurkan bubuk kari Aceh.\n2. Tumis bumbu halus bersama irisan bawang merah dan daging sapi/udang hingga berubah warna dan harum.\n3. Tambahkan sedikit air kaldu, masak hingga mendidih dan daging empuk.\n4. Masukkan mie kuning, toge, daun bawang, kecap manis, kecap asin, garam, dan gula secukupnya.\n5. Aduk merata di atas api sedang hingga kuah menyusut menjadi nyemek (sedikit berkuah kental).\n6. Angkat dan sajikan selagi panas dengan emping renyah dan acar bawang merah segar.'
      };
    } else if (normalized.contains('rendang')) {
      return {
        'ingredients': [
          '1 kg Daging Sapi segar (potong menjadi 20-24 bagian)',
          '1000 ml Santan Kental dari 3 butir kelapa tua',
          '1000 ml Santan Encer',
          '15 butir Bawang Merah & 8 siung Bawang Putih',
          '5 cm Lengkuas & 5 cm Jahe',
          '2 lembar Daun Kunyit (ikat simpul)',
          '5 lembar Daun Jeruk & 2 batang Serai',
          '2 buah Asam Kandis',
          '2 sdm Kelapa Parut Gongseng (sundeng)'
        ],
        'instructions': '1. Haluskan bawang merah, bawang putih, cabai merah, jahe, lengkuas, ketumbar, dan garam.\n2. Rebus santan encer bersama bumbu halus, serai, daun kunyit, daun jeruk, dan asam kandis sambil terus diaduk agar santan tidak pecah.\n3. Setelah santan mengeluarkan minyak, masukkan potongan daging sapi. Masak dengan api sedang hingga daging empuk.\n4. Tambahkan santan kental dan kelapa gongseng halus. Kecilkan api kompor.\n5. Masak terus sambil diaduk perlahan hingga kuah santan berubah cokelat pekat dan mengeluarkan minyak berlimpah.\n6. Teruskan mengaduk hingga bumbu mengering dan berwarna cokelat kehitaman (karamelisasi rendang). Angkat dan sajikan.'
      };
    } else if (normalized.contains('bakso')) {
      return {
        'ingredients': [
          '500 gram Daging Sapi cincang halus bebas urat',
          '50 gram Es Batu (hancurkan)',
          '4 sdm Tepung Sagu/Tapioka',
          '1 sdm Bawang Putih goreng & 1 sdm Bawang Merah goreng',
          '1 sdt Garam & 1/2 sdt Merica bubuk',
          '1500 ml Air Kaldu Sapi segar',
          'Sawi hijau, toge, daun seledri, mie kuning/bihun'
        ],
        'instructions': '1. Blender daging sapi dingin bersama es batu, bawang merah-putih goreng, garam, merica, dan tepung tapioka hingga terbentuk pasta emulsi halus.\n2. Panaskan air kaldu sapi dalam panci besar hingga hampir mendidih, lalu kecilkan api.\n3. Lumuri tangan dengan minyak, bentuk adonan bakso menjadi bulatan menggunakan genggaman jari tangan dan sendok.\n4. Masukkan bulatan bakso langsung ke dalam air panas. Biarkan hingga mengapung sempurna (tanda matang).\n5. Buat kuah gurih dengan menambahkan garam, merica bubuk, bawang putih halus tumis, dan tulang sumsum ke air rebusan.\n6. Tata mie, toge, sawi dalam mangkuk, siram bakso panas beserta kuah kaldunya, taburi daun seledri.'
      };
    }

    // 2. Hubungi TheMealDB API untuk hidangan internasional umum
    try {
      final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$foodName');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'];
        if (meals != null && meals is List && meals.isNotEmpty) {
          final meal = meals[0];
          final List<String> ingredients = [];
          for (int i = 1; i <= 20; i++) {
            final ingredient = meal['strIngredient$i'];
            final measure = meal['strMeasure$i'];
            if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
              ingredients.add('${measure ?? ''} ${ingredient.toString().trim()}'.trim());
            }
          }
          return {
            'ingredients': ingredients,
            'instructions': meal['strInstructions'] ?? 'Ikuti petunjuk umum pembuatan hidangan ini.',
          };
        }
      }
    } catch (e) {
      // Lanjut ke fallback statis di bawah jika API gagal
    }

    // Fallback resep umum universal jika resep tidak ditemukan
    return {
      'ingredients': [
        'Bahan-bahan utama segar sesuai porsi',
        'Bumbu dasar tradisional (bawang, garam, merica)',
        'Minyak nabati atau mentega untuk menumis',
        'Air atau kaldu penyedap alami secukupnya'
      ],
      'instructions': '1. Siapkan dan cuci bersih semua bahan dasar makanan secara higienis.\n2. Panaskan wajan, tumis bumbu dasar hingga mengeluarkan aroma wangi.\n3. Masukkan bahan utama (daging/sayur), aduk hingga bumbu merata.\n4. Tambahkan air atau kaldu, tutup wajan dan masak hingga matang meresap sempurna.\n5. Sajikan hangat di piring saji terbaik.'
    };
  }
}
