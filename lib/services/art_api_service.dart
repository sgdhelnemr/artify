import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/painting.dart';

/// Public REST API: Art Institute of Chicago (no API key needed).
/// Used by the "Discover" screen to import real artworks into the gallery.
class ArtApiService {
  Future<List<Painting>> search(String query) async {
    final uri = Uri.https('api.artic.edu', '/api/v1/artworks/search', {
      'q': query,
      'limit': '15',
      'fields': 'id,title,artist_title,date_end,image_id,thumbnail',
    });

    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Server responded with ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (body['data'] as List).cast<Map<String, dynamic>>();

    return items.where((e) => e['image_id'] != null).map((e) {
      final id = (e['id'] as num).toInt();
      final thumb = e['thumbnail'] as Map<String, dynamic>?;
      final alt = thumb?['alt_text'] as String?;
      return Painting(
        id: 0, // not saved yet - the database will generate the id
        title: (e['title'] as String?) ?? 'Untitled',
        artist: (e['artist_title'] as String?) ?? 'Unknown artist',
        year: (e['date_end'] as num?)?.toInt() ?? 0,
        price: 500.0 + (id % 10) * 100,
        image:
            'https://lakeimagesweb.artic.edu/iiif/2/${e['image_id']}/full/843,/0/default.jpg',
        description: alt ?? 'From the Art Institute of Chicago collection.',
      );
    }).toList();
  }
}
