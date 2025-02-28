import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// URL API tanpa API Key & bebas CORS
const String apiUrl = "https://api.frankfurter.app/latest";

void main() {
  runApp(const CurrencyConverterApp());
}

/// **Aplikasi utama dengan tema modern**
class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const CurrencyConverterScreen(),
    );
  }
}

/// **Layar utama dengan state management & UI lebih menarik**
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  Map<String, double> exchangeRates = {};
  String fromCurrency = "USD";
  String toCurrency = "IDR";
  double amount = 1.0;
  String result = "Masukkan jumlah & pilih mata uang.";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  /// **Mengambil data nilai tukar dari API dengan Error Handling**
  Future<void> _fetchExchangeRates() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = Map<String, double>.from(data["rates"]);
          isLoading = false;
        });
      } else {
        throw Exception(
          "Gagal mengambil data dari API (Status: ${response.statusCode})",
        );
      }
    } catch (error) {
      setState(() {
        errorMessage = "⚠️ Gagal mengambil data: $error";
        isLoading = false;
      });
    }
  }

  /// **Melakukan konversi mata uang dengan validasi**
  void _convertCurrency() {
    if (exchangeRates.isEmpty) {
      setState(() {
        result = "⚠️ Data nilai tukar belum tersedia.";
      });
      return;
    }

    if (!exchangeRates.containsKey(fromCurrency) ||
        !exchangeRates.containsKey(toCurrency)) {
      setState(() {
        result = "⚠️ Mata uang tidak valid.";
      });
      return;
    }

    double fromRate = exchangeRates[fromCurrency]!;
    double toRate = exchangeRates[toCurrency]!;
    double convertedAmount = (amount / fromRate) * toRate;

    setState(() {
      result =
          "💵 $amount $fromCurrency = ${convertedAmount.toStringAsFixed(2)} $toCurrency";
    });
  }

  /// **Membuat Dropdown untuk memilih mata uang dengan desain lebih modern**
  Widget _currencyDropdown(
    String selectedCurrency,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo, width: 1),
      ),
      child: DropdownButton<String>(
        value: selectedCurrency,
        isExpanded: true,
        underline: const SizedBox(),
        items:
            exchangeRates.keys.map((currency) {
              return DropdownMenuItem(value: currency, child: Text(currency));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Currency Converter",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 10),
            const Text(
              "Masukkan jumlah:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 1.0;
                });
              },
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _currencyDropdown(fromCurrency, (value) {
                    setState(() => fromCurrency = value!);
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.swap_horiz, size: 30, color: Colors.indigo),
                ),
                Expanded(
                  child: _currencyDropdown(toCurrency, (value) {
                    setState(() => toCurrency = value!);
                  }),
                ),
              ],
            ),

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
              ),
              child: const Text("Konversi", style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
