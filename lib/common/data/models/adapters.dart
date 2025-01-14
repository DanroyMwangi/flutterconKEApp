import 'dart:convert';

import 'package:fluttercon/common/data/models/models.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FlutterConUserAdapter extends TypeAdapter<FlutterConUser> {
  @override
  final typeId = 0;

  @override
  FlutterConUser read(BinaryReader reader) {
    return FlutterConUser.fromJson(
      Map<String, dynamic>.of(
        json.decode(reader.read() as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  void write(BinaryWriter writer, FlutterConUser obj) {
    writer.write(json.encode(obj.toJson()));
  }
}

class FlutterConSessionAdapter extends TypeAdapter<SessionResponse> {
  @override
  final typeId = 1;

  @override
  SessionResponse read(BinaryReader reader) {
    return SessionResponse.fromJson(
      Map<String, dynamic>.of(
        json.decode(reader.read() as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  void write(BinaryWriter writer, SessionResponse obj) {
    writer.write(json.encode(obj.toJson()));
  }
}
