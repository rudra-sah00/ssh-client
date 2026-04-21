import 'package:ssh_client/data/models/connection/connection_model.dart';

abstract class SshService {
  Future<void> connect(ConnectionModel connection);
  Future<void> disconnect();
  Stream<String> get outputStream;
  Future<void> sendCommand(String command);
  Future<void> resizeTerminal(int width, int height);
  bool get isConnected;
}
