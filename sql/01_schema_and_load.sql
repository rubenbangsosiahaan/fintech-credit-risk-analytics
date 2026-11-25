-- ============================================================================
-- 01_schema_and_load.sql
-- Membuat Skema Relasional 3 Tabel Home Credit Default Risk
-- ============================================================================

DROP TABLE IF EXISTS dim_prev_applications CASCADE;
DROP TABLE IF EXISTS dim_bureau_history CASCADE;
DROP TABLE IF EXISTS fact_applications CASCADE;

-- 1. Tabel Fakta Utama (307.504 baris x 31 kolom)
CREATE TABLE fact_applications (
    sk_id_curr INTEGER PRIMARY KEY,
    target SMALLINT NOT NULL,
    name_contract_type VARCHAR(50),
    code_gender VARCHAR(10),
    flag_own_car VARCHAR(5),
    flag_own_realty VARCHAR(5),
    cnt_children INTEGER,
    cnt_fam_members NUMERIC(6,2),
    amt_income_total NUMERIC(15,2),
    amt_credit NUMERIC(15,2),
    amt_annuity NUMERIC(15,2),
    amt_goods_price NUMERIC(15,2),
    name_income_type VARCHAR(50),
    name_education_type VARCHAR(80),
    name_family_status VARCHAR(50),
    name_housing_type VARCHAR(50),
    occupation_type VARCHAR(60),
    organization_type VARCHAR(80),
    ext_source_1 NUMERIC(10,6),
    ext_source_2 NUMERIC(10,6),
    ext_source_3 NUMERIC(10,6),
    is_pensioner_or_unemployed SMALLINT,
    age_years NUMERIC(5,1),
    employment_years NUMERIC(5,1),
    registration_years NUMERIC(5,1),
    credit_to_income_ratio NUMERIC(10,3),
    annuity_to_income_ratio NUMERIC(10,4),
    avg_ext_source NUMERIC(10,4),
    age_group VARCHAR(30),
    dti_tier VARCHAR(30),
    ext_score_tier VARCHAR(30)
);

-- 2. Tabel Dimensi Riwayat Biro Kredit Eksternal (9 kolom)
CREATE TABLE dim_bureau_history (
    sk_id_curr INTEGER PRIMARY KEY,
    bureau_total_loans INTEGER,
    bureau_active_loans INTEGER,
    bureau_closed_loans INTEGER,
    bureau_total_credit NUMERIC(18,2),
    bureau_total_debt NUMERIC(18,2),
    bureau_max_overdue_days INTEGER,
    bureau_overdue_count INTEGER,
    bureau_has_overdue SMALLINT
);

-- 3. Tabel Dimensi Riwayat Pengajuan Sebelumnya di Home Credit (7 kolom)
CREATE TABLE dim_prev_applications (
    sk_id_curr INTEGER PRIMARY KEY,
    prev_app_count INTEGER,
    prev_approved_count INTEGER,
    prev_refused_count INTEGER,
    prev_avg_application NUMERIC(15,2),
    prev_avg_credit NUMERIC(15,2),
    prev_refusal_rate NUMERIC(6,2)
);


-- Hapus catatan riwayat milik ID nasabah di luar fact_applications (versi cepat dengan NOT EXISTS)
DELETE FROM dim_bureau_history b
WHERE NOT EXISTS (
    SELECT 1 FROM fact_applications f WHERE f.sk_id_curr = b.sk_id_curr
);

DELETE FROM dim_prev_applications p
WHERE NOT EXISTS (
    SELECT 1 FROM fact_applications f WHERE f.sk_id_curr = p.sk_id_curr
);

-- Pasang Foreign Key untuk integritas relasional
ALTER TABLE dim_bureau_history
ADD CONSTRAINT fk_bureau_app FOREIGN KEY (sk_id_curr) REFERENCES fact_applications(sk_id_curr);

ALTER TABLE dim_prev_applications
ADD CONSTRAINT fk_prev_app FOREIGN KEY (sk_id_curr) REFERENCES fact_applications(sk_id_curr);

-- Buat Index pada kolom filter utama untuk mempercepat query BI
CREATE INDEX idx_app_target ON fact_applications(target);
CREATE INDEX idx_app_income_type ON fact_applications(name_income_type);
CREATE INDEX idx_app_dti_tier ON fact_applications(dti_tier);
CREATE INDEX idx_app_ext_tier ON fact_applications(ext_score_tier);

-- Verifikasi jumlah baris setelah relasi terpasang
SELECT 
    (SELECT COUNT(*) FROM fact_applications) AS total_applicants,
    (SELECT COUNT(*) FROM dim_bureau_history) AS matched_bureau,
    (SELECT COUNT(*) FROM dim_prev_applications) AS matched_prev_app;