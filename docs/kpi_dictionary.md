# KPI Dictionary — Credit Risk & Portfolio Analytics

Dokumentasi ini menetapkan definisi standar metrik risiko kredit yang digunakan secara konsisten di PostgreSQL dan Power BI.

| Nama KPI | Rumus Matematis / Logika Bisnis | Tujuan Pemantauan Risiko |
| :--- | :--- | :--- |
| **Total Applicants** | `COUNT(sk_id_curr)` | Mengukur volume total aplikasi pinjaman yang disetujui dalam portofolio. |
| **Overall Default Rate (%)** | $\frac{\sum \text{target}}{\text{Total Applicants}} \times 100\%$ | Indikator utama kualitas aset kredit (persentase debitur yang gagal bayar). |
| **Total Credit Exposure ($)** | $\sum \text{amt\_credit}$ | Total nilai pokok pinjaman yang disalurkan perusahaan. |
| **Default Credit Exposure ($)** | $\sum (\text{amt\_credit} \mid \text{target} = 1)$ | Total nilai pokok pinjaman yang berada pada status gagal bayar (*at-risk principal*). |
| **Debt-to-Income / DTI Ratio (%)** | $\frac{\text{amt\_annuity}}{\text{amt\_income\_total}} \times 100\%$ | Mengukur porsi pendapatan tahunan nasabah yang terserap untuk membayar cicilan. |
| **Credit-to-Income Ratio** | $\frac{\text{amt\_credit}}{\text{amt\_income\_total}}$ | Mengukur kelipatan besar pinjaman dibandingkan kemampuan pendapatan tahunan. |
| **External Credit Score (`avg_ext_source`)** | $\text{Mean}(\text{ext\_source\_1, 2, 3})$ | Skor kelayakan kredit gabungan dari biro eksternal (`0` = risiko tertinggi, `1` = terendah). |
| **Prior Refusal Rate (%)** | $\frac{\text{prev\_refused\_count}}{\text{prev\_app\_count}} \times 100\%$ | Mengukur rekam jejak penolakan pengajuan pinjaman nasabah di masa lalu. |