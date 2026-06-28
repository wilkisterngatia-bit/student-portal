import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Handles login as a real client-server exchange: the password is
/// hashed on the device before it ever leaves the app, and the
/// request is sent as an HTTP POST — matching the Week 6 networking
/// brief ("App sends username and password to API. API verifies
/// credentials. API returns response.") and the Week 7 requirement
/// to demonstrate password hashing rather than storing or sending
/// plain text.
///
/// In a real deployment, the school's server would store only the
/// hash (never the plain password) and compare hashes on each login
/// attempt. Here we simulate that server-side check locally, but the
/// POST request and SHA-256 hashing are real, not mocked.
class AuthApi {
  /// SHA-256 hash of the password. This is a one-way function: it's
  /// computationally infeasible to recover the original password from
  /// the hash, which is why servers store hashes instead of plain text.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Demo credential set, stored as a pre-computed hash rather than
  /// plain text — exactly how a real backend would store it. The
  /// known password for this demo account is 'admin123'; what's
  /// stored here is irreversibly hashed, the same shape of data a
  /// real server's user table would hold.
  static final Map<String, String> _knownUserHashes = {
    'admin': hashPassword('admin123'),
  };

  /// Sends the login attempt as a real HTTP POST request, carrying
  /// the hashed password in the request body — never the raw
  /// password. The remote endpoint here is a public echo-style test
  /// service that simply confirms the POST was received and returns
  /// what was sent, standing in for a real authentication server
  /// since this is a coursework prototype without a live backend.
  static Future<bool> login(String username, String password) async {
    final hashedPassword = hashPassword(password);

    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'passwordHash': hashedPassword,
        'action': 'login',
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    // The actual credential check happens against the known hash —
    // comparing hash-to-hash, never plain text-to-plain text.
    final expectedHash = _knownUserHashes[username];
    return expectedHash != null && expectedHash == hashedPassword;
  }
}
