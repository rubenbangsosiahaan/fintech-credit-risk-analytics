# Ringkasan Analisis: Risiko Kredit & Portofolio Pinjaman Fintech (Home Credit)

---

## 1. Latar Belakang & Tujuan Proyek

Proyek ini merupakan studi kasus analisis risiko kredit dan kesehatan portofolio pinjaman menggunakan dataset **Home Credit Default Risk** yang mencakup **307.504 aplikasi pinjaman aktif** yang diintegrasikan dengan **3,38 juta catatan riwayat kredit** (**1,71 juta** riwayat biro kredit eksternal dan **1,67 juta** riwayat pengajuan internal). Total nilai penyaluran kredit dalam portofolio ini mencapai **$184,20 Miliar**, dengan tingkat gagal bayar keseluruhan (*Overall Default Rate*) sebesar **8,07%** (**24.824 debitur**) dan nilai pokok bermasalah (*Default Credit Exposure*) sebesar **$13,85 Miliar**.

Melalui kombinasi **Python**, **PostgreSQL**, dan **Power BI**, analisis ini dilakukan untuk menjawab beberapa pertanyaan bisnis utama:

1. Variabel finansial dan profil nasabah apa yang secara statistik paling kuat membedakan debitur lancar dan gagal bayar?
2. Bagaimana dampak rekam jejak pinjaman aktif di lembaga lain serta riwayat penolakan sebelumnya terhadap risiko gagal bayar?
3. Segmen peminjam mana yang menyumbang eksposur kerugian terbesar, dan kebijakan persetujuan kredit (*underwriting*) apa yang perlu diterapkan untuk menekan angka gagal bayar?

---

## 2. Temuan Utama dari Hasil Analisis

### A. Skor Kredit Eksternal Merupakan Prediktor Risiko Paling Dominan
* Pengujian hipotesis (*Chi-Square* dan *Mann-Whitney U* pada $\alpha = 0,05$) membuktikan bahwa **skor kredit eksternal gabungan (`avg_ext_source`)** memiliki asosiasi paling kuat terhadap status gagal bayar ($\chi^2 = 14.024,80$; Cramér's $V = 0,2136$; $p < 0,0001$), jauh melampaui rasio cicilan terhadap pendapatan (*Debt-to-Income / DTI*) yang berdiri sendiri ($V = 0,0196$).
* Peminjam pada kelompok **`High Risk (<0.35)`** mencatat *default rate* sebesar **22,05%** (berkisar **20,13% – 25,23%** lintas tingkat beban cicilan) dan menyumbang **$4,16 Miliar** kerugian gagal bayar.
* Sebaliknya, segmen **`Low Risk (>0.55)`** tetap sangat aman dengan *default rate* hanya **3,30%** (**2,94% – 4,15%**), meskipun rasio cicilan mereka berada di atas **35%**.

### B. Eksposur Kerugian Terkonsentrasi pada Pekerja Aktif dengan Fasilitas *Cash Loans*
* Segmen **`Working` dengan fasilitas `Cash loans`** menyumbang volume gagal bayar terbesar dalam portofolio (**14.190 debitur** dari **142.718 pinjaman**, dengan *default rate* **9,94%**). Secara keseluruhan, kategori pendapatan `Working` menyumbang **$8,15 Miliar** atau **58,8%** dari total kerugian gagal bayar portofolio.
* Fasilitas **`Revolving loans`** menunjukkan kinerja pembayaran jauh lebih sehat di seluruh kelompok pendapatan dibandingkan `Cash loans` (misalnya `State servant` hanya mencatat *default rate* **3,27%** dan `Pensioner` **4,16%**).

### C. Efek Ganda (*Compounding Risk*) dari Pinjaman Aktif & Riwayat Penolakan
* Hasil penggabungan tabel multi-relasi menunjukkan bahwa nasabah yang memiliki **$\ge 5$ pinjaman aktif di biro kredit eksternal** sekaligus **pernah ditolak pada pengajuan sebelumnya (*Has Prior Refusal*)** mengalami lonjakan *default rate* hingga **14,90%**—lebih dari **2 kali lipat** dibandingkan nasabah dengan **1–2 pinjaman aktif** tanpa riwayat penolakan (**6,55%**).

### D. Kerentanan Lebih Tinggi pada Peminjam Usia Muda & Pendidikan Menengah ke Bawah
* Tingkat gagal bayar menurun secara konsisten seiring bertambahnya usia: kelompok **`18–25 (Young)`** mencatat *default rate* tertinggi sebesar **12,27%**, turun bertahap hingga **5,22%** pada kelompok **`55+ (Senior)`**.
* Berdasarkan tingkat pendidikan, segmen **`Lower secondary`** (**10,93%**) dan **`Secondary / secondary special`** (**8,94%**, volume terbesar sebanyak **218.387 nasabah**) berada di atas rata-rata portofolio, sedangkan **`Higher education`** jauh lebih rendah di angka **5,36%**.

---

## 3. Rekomendasi Strategi Kebijakan Kredit

### A. Pengetatan Ambang Persetujuan (*Hard Cut-Off*) pada Zona Risiko Tinggi
* Terapkan penolakan otomatis atau wajibkan penjamin (*co-signer*) bagi pemohon dengan skor kredit eksternal **`< 0.35`** yang memiliki rasio cicilan **`DTI > 25%`** (*High Burden & Critical*), karena tingkat gagal bayar pada kelompok ini mencapai **22,67% – 25,23%** dengan eksposur bermasalah sebesar **$1,01 Miliar**.

### B. Skrining Tambahan untuk Pemohon Multi-Pinjaman & Riwayat Penolakan
* Wajibkan verifikasi arus kas (mutasi rekening 3 bulan terakhir) dan batasi pencairan dana tunai (`Cash loans`) bagi segmen **`Working`** yang tercatat memiliki **$\ge 3$ pinjaman aktif** di lembaga lain serta memiliki riwayat penolakan internal (*watchlist* segmen ini mencatat *default rate* antara **12,17% hingga 36,54%**).

### C. Skema Limit Bertahap (*Step-Up Limit*) untuk Nasabah Usia Muda
* Alihkan penawaran kredit awal bagi pemohon usia **`18–25 tahun`** dari pinjaman tunai berplafon besar ke fasilitas **`Revolving loans`** berlimit awal kecil yang dinaikkan secara bertahap setelah nasabah membuktikan ketepatan pembayaran selama 6 bulan pertama.