import 'package:flutter/material.dart';

void main() {
  runApp(const AplikasiKasir());
}

class AplikasiKasir extends StatelessWidget {
  const AplikasiKasir({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasirku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HalamanUtamaKasir(),
    );
  }
}

class HalamanUtamaKasir extends StatefulWidget {
  const HalamanUtamaKasir({super.key});

  @override
  State<HalamanUtamaKasir> createState() => _HalamanUtamaKasirState();
}

class _HalamanUtamaKasirState extends State<HalamanUtamaKasir> {
  // Daftar barang yang tersedia di toko
  final List<Map<String, dynamic>> _daftarBarang = [
    {'nama': 'Beras 1kg', 'harga': 15000},
    {'nama': 'Minyak Goreng 1L', 'harga': 18000},
    {'nama': 'Gula Pasir 1kg', 'harga': 14000},
    {'nama': 'Mie Instan', 'harga': 3500},
    {'nama': 'Teh Celup', 'harga': 6000},
  ];

  // Keranjang belanjaan saat ini
  final List<Map<String, dynamic>> _keranjang = [];
  
  int _totalHarga = 0;
  final TextEditingController _uangDibayarController = TextEditingController();
  int _uangKembalian = -1; // -1 menandakan belum ada transaksi pembayarn

  // Fungsi menambah barang ke keranjang
  void _tambahKeKeranjang(Map<String, dynamic> barang) {
    setState(() {
      // Cek apakah barang sudah ada di keranjang
      int indeks = _keranjang.indexWhere((item) => item['nama'] == barang['nama']);
      
      if (indeks != -1) {
        _keranjang[indeks]['jumlah']++;
      } else {
        _keranjang.add({
          'nama': barang['nama'],
          'harga': barang['harga'],
          'jumlah': 1,
        });
      }
      _hitungTotal();
    });
  }

  // Fungsi menghitung total belanja
  void _hitungTotal() {
    int total = 0;
    for (var item in _keranjang) {
      total += (item['harga'] as int) * (item['jumlah'] as int);
    }
    setState(() {
      _totalHarga = total;
      _uangKembalian = -1; // Reset kembalian jika keranjang berubah
    });
  }

  // Fungsi proses pembayaran
  void _prosesPembayaran() {
    if (_uangDibayarController.text.isEmpty) return;
    
    int uangBayar = int.parse(_uangDibayarController.text);
    if (uangBayar < _totalHarga) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang dibayarkan kurang!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _uangKembalian = uangBayar - _totalHarga;
    });
  }

  // Fungsi reset transaksi baru
  void _transaksiBaru() {
    setState(() {
      _keranjang.clear();
      _totalHarga = 0;
      _uangKembalian = -1;
      _uangDibayarController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasirku - Aplikasi Toko', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _transaksiBaru,
            tooltip: 'Transaksi Baru',
          )
        ],
      ),
      body: Row(
        children: [
          // SISI KIRI: Daftar Produk Dagangan
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daftar Menu / Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _daftarBarang.length,
                      itemBuilder: (context, index) {
                        var barang = _daftarBarang[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(barang['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Rp ${barang['harga']}'),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _tambahKeKeranjang(barang),
                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                              label: const Text('Tambah'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SISI KANAN: Keranjang & Hitungan Pembayaran
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keranjang Belanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  // List Barang di Keranjang
                  Expanded(
                    child: _keranjang.isEmpty
                        ? const Center(child: Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _keranjang.length,
                            itemBuilder: (context, index) {
                              var item = _keranjang[index];
                              return ListTile(
                                title: Text(item['nama']),
                                subtitle: Text('${item['jumlah']} x Rp ${item['harga']}'),
                                trailing: Text(
                                  'Rp ${item['jumlah'] * item['harga']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(thickness: 2),

                  // Total Tagihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL BAYAR:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        'Rp $_totalHarga',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Kolom input uang tunai pembeli
                  TextField(
                    controller: _uangDibayarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Uang Tunai Pembeli (Rp)',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol Proses
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _totalHarga > 0 ? _prosesPembayaran : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tampilan Kembalian uang
                  if (_uangKembalian >= 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        children: [
                          const Text('TRANSAKSI BERHASIL', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            'Kembalian: Rp $_uangKembalian',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
