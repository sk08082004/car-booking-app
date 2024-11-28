import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    try {
      final http.Response httpResponse = await http.get(Uri.parse(url));

      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;
        var decodedResponse = jsonDecode(responseData);
        return decodedResponse;
      } else {
        return "Error Occurred: Failed. No Response";
      }
    } catch (e) {
      return "Error Occurred: $e";
    }
  }
}
