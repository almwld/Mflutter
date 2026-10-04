import 'dart:convert';
import 'package:http/http.dart' as http;

class IoTSanctuaryService {
  IoTSanctuaryService._();
  static final instance = IoTSanctuaryService._();
  Uri? _endpoint; String? _token;
  void configure({required String endpoint, String? token}) { _endpoint = Uri.tryParse(endpoint); _token = token; }
  bool get isConfigured => _endpoint != null;
  Future<Map<String,dynamic>> discover() async {
    final uri=_endpoint; if(uri==null) throw StateError('IoT endpoint غير مهيأ');
    final r=await http.get(uri,headers:_headers()).timeout(const Duration(seconds:8));
    if(r.statusCode~/100!=2) throw Exception('IoT discovery HTTP ${r.statusCode}');
    final v=jsonDecode(r.body); return v is Map<String,dynamic>?v:{'devices':v};
  }
  Future<Map<String,dynamic>> sendCommand({required String deviceId,required String command,Map<String,dynamic> payload=const {}}) async {
    final base=_endpoint; if(base==null) throw StateError('IoT endpoint غير مهيأ');
    final r=await http.post(base.resolve('/devices/$deviceId/commands'),headers:{..._headers(),'Content-Type':'application/json'},body:jsonEncode({'command':command,'payload':payload})).timeout(const Duration(seconds:10));
    if(r.statusCode~/100!=2) throw Exception('IoT command HTTP ${r.statusCode}');
    final v=jsonDecode(r.body); return v is Map<String,dynamic>?v:{'result':v};
  }
  Map<String,String> _headers()=>_token==null?{}:{'Authorization':'Bearer $_token'};
}
