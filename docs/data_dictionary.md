# Data Dictionary — Home Credit Default Risk Portfolio

Dokumentasi ini merangkum definisi variabel inti yang diseleksi dari 3 tabel relasional Home Credit beserta temuan audit kualitas data awal.

## 1. Tabel Utama: `fact_applications` (Sumber: `HC_application_train.csv` — 307.511 Baris)

| Nama Kolom (SQL) | Tipe Data | Deskripsi Bisnis | Catatan Audit Awal |
| :--- | :--- | :--- | :--- |
| `sk_id_curr` | `INTEGER` (PK) | ID unik pengajuan pinjaman nasabah. | 100% unik (0 duplikat). |
| `target` | `SMALLINT` | Status pembayaran pinjaman (`0` = Lancar, `1` = Gagal Bayar / *Default*). | *Overall Default Rate* = **8,07%**. |
| `name_contract_type` | `VARCHAR` | Jenis fasilitas kredit (`Cash loans` atau `Revolving loans`). | Lengkap (0% *missing*). |
| `code_gender` | `VARCHAR` | Jenis kelamin nasabah (`F` / `M`). | Terdapat 4 baris `'XNA'` (dihapus saat *cleaning*). |
| `flag_own_car` | `VARCHAR` | Kepemilikan mobil (`Y` / `N`). | Lengkap. |
| `flag_own_realty` | `VARCHAR` | Kepemilikan properti/rumah (`Y` / `N`). | Lengkap. |
| `cnt_children` | `INTEGER` | Jumlah anak tanggungan nasabah. | Lengkap. |
| `cnt_fam_members` | `NUMERIC` | Total anggota keluarga dalam satu rumah tangga. | 2 baris kosong (diisi median). |
| `amt_income_total` | `NUMERIC` | Total pendapatan tahunan yang dilaporkan nasabah. | Median $147.150; terdapat *outlier* ekstrem $117M. |
| `amt_credit` | `NUMERIC` | Total pokok pinjaman yang diajukan/disetujui. | Lengkap (median $513.531). |
| `amt_annuity` | `NUMERIC` | Besaran kewajiban cicilan pinjaman per tahun. | 12 baris kosong (diisi median grup). |
| `amt_goods_price` | `NUMERIC` | Harga barang yang dibiayai (khusus kredit konsumtif). | 278 baris kosong (diisi `amt_credit`). |
| `name_income_type` | `VARCHAR` | Sumber pendapatan utama (*Working*, *Commercial associate*, *Pensioner*, *State servant*, dll.). | Lengkap (8 kategori). |
| `name_education_type` | `VARCHAR` | Tingkat pendidikan terakhir nasabah. | Lengkap (5 kategori). |
| `name_family_status` | `VARCHAR` | Status pernikahan nasabah. | Lengkap (6 kategori). |
| `name_housing_type` | `VARCHAR` | Status tempat tinggal (*House/apartment*, *With parents*, *Rented*, dll.). | Lengkap (6 kategori). |
| `occupation_type` | `VARCHAR` | Jenis pekerjaan spesifik nasabah. | Kosong 31,35% (dilabeli `'Unknown / Pensioner'`). |
| `organization_type` | `VARCHAR` | Sektor/jenis instansi tempat nasabah bekerja. | Lengkap (58 kategori). |
| `age_years` | `NUMERIC` | Usia nasabah dalam tahun (konversi dari `DAYS_BIRTH / -365.25`). | Rentang usia 20,5 – 69,1 tahun. |
| `employment_years` | `NUMERIC` | Lama bekerja dalam tahun (konversi dari `DAYS_EMPLOYED / -365.25`). | Nilai kode `365243` (18,01%) diubah ke `NULL`. |
| `ext_source_1/2/3` | `NUMERIC` | Skor kredit terstandardisasi (0–1) dari 3 lembaga biro eksternal. | `EXT_SOURCE_1` kosong 56,38%; `EXT_SOURCE_3` 19,83%. |

## 2. Tabel Riwayat Eksternal: `dim_bureau_history` (Agregasi dari `HC_bureau.csv`)
* **Granularitas:** 1 baris per nasabah (`sk_id_curr`), mencakup **85,69%** peminjam di tabel utama.
* **Metrik Hasil Agregasi:** `bureau_total_loans` (total pinjaman di luar), `bureau_active_loans` (pinjaman masih aktif), `bureau_total_debt` (total sisa utang eksternal), `bureau_max_overdue_days` (keterlambatan terlama dalam hari), dan `bureau_has_overdue` (penanda pernah menunggak `1/0`).

## 3. Tabel Riwayat Internal: `dim_prev_applications` (Agregasi dari `HC_previous_application.csv`)
* **Granularitas:** 1 baris per nasabah (`sk_id_curr`), mencakup **94,65%** peminjam di tabel utama.
* **Metrik Hasil Agregasi:** `prev_app_count` (total riwayat pengajuan di Home Credit), `prev_approved_count` (jumlah disetujui), `prev_refused_count` (jumlah ditolak), `prev_refusal_rate` (rasio penolakan `%`), dan `prev_avg_credit` (rata-rata plafon pinjaman sebelumnya).