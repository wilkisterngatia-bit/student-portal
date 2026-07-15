import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Handles login and registration as a real client-server exchange:
/// the password is hashed on the device before it ever leaves the
/// app, and requests are sent as HTTP POSTs — matching the Week 6
/// networking brief ("App sends username and password to API. API
/// verifies credentials. API returns response.") and the Week 7
/// requirement to demonstrate password hashing rather than storing
/// or sending plain text.
///
/// In a real deployment, the school's server would store the
/// password hash and the registered-users table, and compare hashes
/// on each login attempt. Here, since this is a coursework prototype
/// without a live backend, that server-side store is simulated with
/// SharedPreferences on the device — but the POST requests and
/// SHA-256 hashing are real, not mocked.
class AuthApi {
  static const _registeredUsersKey = 'registered_user_hashes';

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
  /// known password for this demo account is 'admin123'.
  static final Map<String, String> _knownUserHashes = {
    'admin': hashPassword('admin123'),
  };

  /// Reads locally-registered users (username -> password hash) from
  /// SharedPreferences. Stored as a JSON string since SharedPreferences
  /// only supports flat primitive types natively.
  static Future<Map<String, String>> _loadRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_registeredUsersKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  static Future<void> _saveRegisteredUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredUsersKey, json.encode(users));
  }

  /// Registers a new student account. Sends a real HTTP POST (same
  /// pattern as login) representing the "create account" request to
  /// the server, then persists the hashed credential locally so
  /// login can verify against it afterwards — standing in for the
  /// server's user table, since this prototype has no live backend.
  ///
  /// Returns false if the username is already taken (by the demo
  /// account or a previously registered one).
  static Future<bool> register(String username, String password) async {
    final registered = await _loadRegisteredUsers();

    if (_knownUserHashes.containsKey(username) || registered.containsKey(username)) {
      return false;
    }

    final hashedPassword = hashPassword(password);

    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'passwordHash': hashedPassword,
        'action': 'register',
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    registered[username] = hashedPassword;
    await _saveRegisteredUsers(registered);
    return true;
  }

  /// Sends the login attempt as a real HTTP POST request, carrying
  /// the hashed password in the request body — never the raw
  /// password. Checks the hash against both the built-in demo
  /// account and any locally-registered accounts.
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

    final expectedHash = _knownUserHashes[username];
    if (expectedHash != null) {
      return expectedHash == hashedPassword;
    }

    final registered = await _loadRegisteredUsers();
    final registeredHash = registered[username];
    return registeredHash != null && registeredHash == hashedPassword;
  }
}