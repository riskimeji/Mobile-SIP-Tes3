import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';
import 'config.dart';

class Repository {
  final _baseUrl = '${AppConfig.apiBaseUrl}/api/notes';

  Future getData() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // print(response.body);
        Iterable it = jsonDecode(response.body);
        List<Note> note = it.map((e) => Note.fromJson(e)).toList();
        return note;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future postData(String title, String content) async {
    try {
      final response = await http.post(Uri.parse(_baseUrl),
          body: {'title': title, 'content': content});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, dynamic> data = jsonData['data'];
        final Note note = Note.fromJson(data);
        return note;
      } else {
        print('Gagal melakukan POST: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return null;
    }
  }

  Future editData(String title, String content, String id) async {
    final url = '${AppConfig.apiBaseUrl}/api/notes/${id}/update';
    try {
      final response = await http
          .put(Uri.parse(url), body: {'title': title, 'content': content});
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, dynamic> data = jsonData['data'];
        final Note note = Note.fromJson(data);
        return note;
      } else {
        print('Gagal melakukan PUT: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return null;
    }
  }

  Future delete(String id) async {
    final url = '${AppConfig.apiBaseUrl}/api/notes/$id';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Catatan berhasil dihapus');
        return true;
      } else {
        print('Gagal melakukan DELETE: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return false;
    }
  }
}
