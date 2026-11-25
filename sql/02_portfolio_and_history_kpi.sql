-- ============================================================================
-- 02_portfolio_and_history_kpi.sql
-- Analisis Portofolio Kredit, Beban Cicilan (DTI), & Riwayat Multi-Tabel
-- ============================================================================

-- QUERY 1: Ringkasan Kesehatan Portofolio Kredit (Executive KPI)
SELECT 
    COUNT(*) AS total_applicants,
    SUM(target) AS total_defaults,
    ROUND(AVG(target) * 100, 2) AS default_rate_pct,
    ROUND(SUM(amt_credit) / 1000000.0, 2) AS total_credit_exposure_million,
    ROUND(SUM(CASE WHEN target = 1 THEN amt_credit ELSE 0 END) / 1000000.0, 2) AS default_exposure_million,
    ROUND(AVG(annuity_to_income_ratio) * 100, 2) AS avg_dti_pct
FROM fact_applications;

-- QUERY 2: Analisis Risiko Berdasarkan Jenis Pendapatan & Kontrak (Window Function)
SELECT 
    name_income_type,
    name_contract_type,
    COUNT(*) AS total_loans,
    SUM(target) AS default_count,
    ROUND(AVG(target) * 100, 2) AS default_rate_pct,
    ROUND(SUM(amt_credit) / 1000000.0, 2) AS exposure_million,
    ROUND(SUM(SUM(CASE WHEN target = 1 THEN amt_credit ELSE 0 END)) OVER (PARTITION BY name_income_type) / 1000000.0, 2) AS total_default_loss_by_income_type
FROM fact_applications
GROUP BY name_income_type, name_contract_type
HAVING COUNT(*) >= 50
ORDER BY default_rate_pct DESC;

-- QUERY 3: Matriks Risiko — Kombinasi External Credit Score & Debt-to-Income (DTI)
SELECT 
    ext_score_tier,
    dti_tier,
    COUNT(*) AS total_applicants,
    ROUND(AVG(target) * 100, 2) AS default_rate_pct,
    ROUND(SUM(CASE WHEN target = 1 THEN amt_credit ELSE 0 END) / 1000000.0, 2) AS default_exposure_million
FROM fact_applications
GROUP BY ext_score_tier, dti_tier
ORDER BY ext_score_tier, dti_tier;

-- QUERY 4: Analisis Multi-Tabel (LEFT JOIN) — Dampak Pinjaman Aktif di Biro Kredit & Riwayat Penolakan
WITH borrower_history AS (
    SELECT 
        a.sk_id_curr,
        a.target,
        a.amt_credit,
        COALESCE(b.bureau_active_loans, 0) AS active_external_loans,
        COALESCE(b.bureau_has_overdue, 0) AS has_external_overdue,
        COALESCE(p.prev_refused_count, 0) AS prev_refusals
    FROM fact_applications a
    LEFT JOIN dim_bureau_history b ON a.sk_id_curr = b.sk_id_curr
    LEFT JOIN dim_prev_applications p ON a.sk_id_curr = p.sk_id_curr
)
SELECT 
    CASE 
        WHEN active_external_loans = 0 THEN '0 Active Loans'
        WHEN active_external_loans BETWEEN 1 AND 2 THEN '1-2 Active Loans'
        WHEN active_external_loans BETWEEN 3 AND 4 THEN '3-4 Active Loans'
        ELSE '5+ Active Loans'
    END AS external_loan_burden,
    CASE WHEN prev_refusals > 0 THEN 'Has Prior Refusal' ELSE 'No Prior Refusal' END AS internal_history_flag,
    COUNT(*) AS total_applicants,
    ROUND(AVG(target) * 100, 2) AS default_rate_pct,
    ROUND(AVG(amt_credit), 0) AS avg_loan_size
FROM borrower_history
GROUP BY 1, 2
ORDER BY 1, 2;