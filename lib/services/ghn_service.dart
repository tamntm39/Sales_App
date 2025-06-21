// lib/services/ghn_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chichanka_perfume/models/address_model.dart';

class GhnService {
  static const String _token = '53ab3a62-4ebc-11f0-8cf5-d2552bfd31d8';
  static const Map<String, String> _headers = {
    'Token': _token,
    'Content-Type': 'application/json',
  };

  static Future<List<Province>> fetchProvinces() async {
    final res = await http.get(
      Uri.parse(
          'https://online-gateway.ghn.vn/shiip/public-api/master-data/province'),
      headers: _headers,
    );
    final data = jsonDecode(res.body)['data'] as List;
    return data.map((e) => Province.fromJson(e)).toList();
  }

  static Future<List<District>> fetchDistricts(int provinceId) async {
    final res = await http.get(
      Uri.parse(
          'https://online-gateway.ghn.vn/shiip/public-api/master-data/district'),
      headers: _headers,
    );
    final data = jsonDecode(res.body)['data'] as List;
    return data
        .where((e) => e['ProvinceID'] == provinceId)
        .map((e) => District.fromJson(e))
        .toList();
  }

  static Future<List<Ward>> fetchWards(int districtId) async {
    final res = await http.post(
      Uri.parse(
          'https://online-gateway.ghn.vn/shiip/public-api/master-data/ward'),
      headers: _headers,
      body: jsonEncode({'district_id': districtId}),
    );
    final data = jsonDecode(res.body)['data'] as List;
    return data.map((e) => Ward.fromJson(e)).toList();
  }

  static Future<int> calculateShippingFee({
    required int fromDistrictId,
    required int toDistrictId,
    required String toWardCode,
    required int weight,
    required int length,
    required int width,
    required int height,
  }) async {
    final res = await http.post(
      Uri.parse(
          'https://online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/fee'),
      headers: {
        ..._headers,
        'ShopId': '5850670',
      },
      body: jsonEncode({
        "service_type_id": 2,
        "insurance_value": 1000000,
        "coupon": null,
        "from_district_id": fromDistrictId,
        "to_district_id": toDistrictId,
        "to_ward_code": toWardCode,
        "height": height,
        "length": length,
        "weight": weight,
        "width": width,
      }),
    );

    print('GHN Fee API response: ${res.body}'); // Thêm dòng này để debug

    final json = jsonDecode(res.body);
    if (res.statusCode == 200 && json['code'] == 200) {
      return json['data']['total'];
    } else {
      throw Exception('Lỗi khi tính phí vận chuyển: ${json['message']}');
    }
  }
}
