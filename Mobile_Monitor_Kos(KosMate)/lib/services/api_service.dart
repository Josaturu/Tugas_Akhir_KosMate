import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk Emulator Android, atau IP asli laptop jika pakai HP fisik.
  static const String baseUrl = "https://kosmate-api.loca.lt/api";

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  static Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }

  static Future register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // --- CRUD KAMAR ---

  static Future getKamar() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kamar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getKamarDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/kamar/$id'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future createKamar(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kamar'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future updateKamar(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kamar/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future deleteKamar(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/kamar/$id'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // --- TENANCY & USERS ---

  static Future getMyTenancy() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-tenancy'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getPenyewa() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get-penyewa'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future storePenyewaan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/store-penyewaan'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // API Pembayaran
  static Future getPembayaran() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pembayaran'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future konfirmasiPembayaran(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pembayaran/konfirmasi/$id'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future uploadBukti(int id, String metode, String? bukti) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pembayaran/upload-bukti/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'metode': metode,
        'bukti': bukti,
      }),
    );
    return jsonDecode(response.body);
  }

  // --- REPORTS ---

  static Future getReportSummary(int bulan, int tahun) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/summary?bulan=$bulan&tahun=$tahun'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getPaymentReport(int bulan, int tahun) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/payments?bulan=$bulan&tahun=$tahun'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getTunggakanReport() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/tunggakan'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // --- COMPLAINTS ---

  static Future getComplaints() async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaints'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getMyComplaints() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-complaints'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future storeComplaint(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaints'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future updateComplaintStatus(int id, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaints/update-status/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body);
  }

  // --- NOTIFICATIONS ---

  static Future sendBroadcastNotification(String title, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/broadcast'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'message': message,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future markNotificationRead(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/mark-read/$id'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future logout() async {
    try {
      // Optional: Panggil endpoint logout di server
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );
    } catch (e) {
      debugPrint('Logout server error: $e');
    }

    // Hapus data lokal tetap dilakukan meskipun server error
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('user_id');
  }
}
