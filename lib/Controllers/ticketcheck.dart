import 'package:http/http.dart';

import 'package:http/http.dart' as http;

class TicketCheckController {
  Future<Response> checkTicket(qr, station) async {
    var urlBase = 'http://192.168.1.92:8001/bookings' +
        ((qr.toString().substring(1, 3) != 'S-')
            ? '/check/' + qr + '/' + station
            : '/season/check/' + qr);
    var url = Uri.parse(urlBase);
    return await http.get(url);
  }
}
