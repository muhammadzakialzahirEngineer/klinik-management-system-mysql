# 🏥 Sistem Informasi Klinik (Database MySQL/MariaDB)

Database relasional untuk sistem informasi klinik/puskesmas yang mengelola data pasien, dokter, poli, kunjungan, resep, dan stok obat. Dilengkapi dengan **stored procedure**, **function**, dan **trigger** untuk otomatisasi proses pendaftaran kunjungan, pembuatan resep, serta pencatatan log perubahan data.

## 📋 Deskripsi

Proyek ini merupakan rancangan basis data untuk mendukung operasional klinik, mencakup:

- Pendataan pasien dan dokter
- Manajemen poli (departemen)
- Pencatatan kunjungan pasien
- Pembuatan resep dan detail obat yang diberikan
- Manajemen stok obat beserta riwayat perubahannya
- Pencatatan log otomatis (audit trail) untuk kunjungan dan stok obat

## ERD
<img width="571" height="267" alt="image" src="https://github.com/user-attachments/assets/69e5ab22-f39c-4e18-aa43-7c9df839cb5a" />

## 🗂️ Struktur Tabel

| Tabel | Deskripsi |
|---|---|
| `pasien` | Data identitas pasien (nama, alamat, jenis kelamin, tanggal lahir, no. HP) |
| `dokter` | Data dokter beserta spesialisasinya |
| `poli` | Data poli/departemen klinik beserta lokasi |
| `kunjungan` | Data kunjungan pasien ke dokter/poli tertentu beserta keluhan |
| `resep` | Data resep yang diterbitkan untuk suatu kunjungan |
| `detail_resep` | Rincian obat dan jumlah pada suatu resep |
| `obat` | Data obat, jenis, harga, dan stok |
| `log_kunjungan` | Log otomatis setiap ada kunjungan baru |
| `log_stok_obat` | Log otomatis setiap ada perubahan stok obat |

### Relasi Antar Tabel

<img width="625" height="329" alt="image" src="https://github.com/user-attachments/assets/2d1d9fb2-9c06-4c60-ad7e-d9f820a35f6c" />

- `kunjungan` mereferensikan `pasien`, `dokter`, dan `poli`
- `resep` mereferensikan `kunjungan` dan `poli`
- `detail_resep` mereferensikan `resep` dan `obat`

## ⚙️ Objek Basis Data Lanjutan

### Stored Procedures
- **`sp_daftar_kunjungan`** — Mendaftarkan kunjungan baru setelah memvalidasi keberadaan data pasien.
- **`sp_buat_resep`** — Membuat resep baru, menambahkan detail obat, dan otomatis mengurangi stok obat (dengan validasi stok mencukupi).

### Functions
- **`fn_status_stok`** — Mengembalikan status stok obat (`HABIS`, `HAMPIR HABIS`, `TERSEDIA`) berdasarkan jumlah stok.
- **`fn_total_biaya_resep`** — Menghitung total biaya suatu resep berdasarkan harga dan jumlah obat.
- **`fn_total_kunjungan`** — Menghitung jumlah total kunjungan seorang pasien.

### Triggers
- **`trg_after_insert_kunjungan`** — Otomatis mencatat log setiap ada kunjungan baru yang didaftarkan.
- **`trg_after_update_stok_obat`** — Otomatis mencatat log setiap ada perubahan jumlah stok obat.

## 🚀 Cara Import Database

1. Buka **phpMyAdmin** atau tool database favorit kamu (DBeaver, HeidiSQL, MySQL Workbench, dll).
2. Buat database baru, misalnya:
   ```sql
   CREATE DATABASE sistem_klinik;
   ```
3. Pilih (gunakan) database tersebut, lalu import file `.sql` dari repo ini.
   - **Via phpMyAdmin:** klik database → tab **Import** → pilih file `.sql` → klik **Go**.
   - **Via command line:**
     ```bash
     mysql -u root -p sistem_klinik < nama_file.sql
     ```
4. Pastikan versi MySQL/MariaDB kamu mendukung `DELIMITER`, stored procedure, function, dan trigger (disarankan MariaDB 10.4+ atau MySQL 5.7+).

> 💡 Nama file `.sql` bebas diganti sesuai keinginan — tidak memengaruhi isi database, karena tidak ada perintah `CREATE DATABASE`/`USE` yang bergantung pada nama file di dalam script.

## 🛠️ Teknologi

- **Database:** MySQL / MariaDB
- **Tools:** phpMyAdmin

## 📄 Lisensi

Bebas digunakan untuk keperluan belajar, tugas, atau pengembangan lebih lanjut.
