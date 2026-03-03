import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles all secure persistent storage for auth tokens, user info,
/// cached permissions, and the permissions version number.
class AuthStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyToken       = 'auth_token';
  static const _keyUserId      = 'user_id';
  static const _keyUsername    = 'username';
  static const _keyFullName    = 'full_name';
  static const _keyRole        = 'role';
  static const _keyPermissions = 'permissions';
  static const _keyPermVersion = 'permissions_version';

  // ─── Save after login ───────────────────────────────────────────────
  Future<void> saveLoginData({
    required String token,
    required String userId,
    required String username,
    required String fullName,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken,    value: token),
      _storage.write(key: _keyUserId,   value: userId),
      _storage.write(key: _keyUsername, value: username),
      _storage.write(key: _keyFullName, value: fullName),
      _storage.write(key: _keyRole,     value: role),
    ]);
  }

  // ─── Save after permission fetch ────────────────────────────────────
  Future<void> savePermissions(List<String> perms, int? version) async {
    await _storage.write(key: _keyPermissions, value: perms.join(','));
    await _storage.write(key: _keyPermVersion, value: (version ?? 0).toString());
  }

  // ─── Getters ────────────────────────────────────────────────────────
  Future<String?> getToken()    => _storage.read(key: _keyToken);
  Future<String?> getRole()     => _storage.read(key: _keyRole);
  Future<String?> getUserId()   => _storage.read(key: _keyUserId);
  Future<String?> getUsername() => _storage.read(key: _keyUsername);
  Future<String?> getFullName() => _storage.read(key: _keyFullName);

  Future<List<String>> getPermissions() async {
    final raw = await _storage.read(key: _keyPermissions);
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',');
  }

  Future<int> getPermissionsVersion() async {
    final v = await _storage.read(key: _keyPermVersion);
    return int.tryParse(v ?? '0') ?? 0;
  }

  // ─── Clear on logout ────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
