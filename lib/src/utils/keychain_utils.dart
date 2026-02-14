import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();

Future<void> writeKeyChainValue(
    {required String key, required String value}) async {
  await _storage.write(key: key, value: value);
}

Future<String> readKeyChainValue({required String key}) async {
  final value = await _storage.read(key: key);
  return value ?? '';
}

Future<void> deleteKeyChainValue({required String key}) async {
  await _storage.delete(key: key);
}

Future<Map<String, String>> readAllKeyChainValues() async {
  final allValue = await _storage.readAll();
  return allValue;
}

Future<void> deleteAllKeyChainValues() async {
  await _storage.deleteAll();
}
