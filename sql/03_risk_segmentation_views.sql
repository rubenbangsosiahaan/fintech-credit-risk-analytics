-- ============================================================================
-- 03_risk_segmentation_views.sql
-- Analytical Views untuk Konsumsi Langsung Power BI Dashboard
-- ============================================================================

-- View 1: Ringkasan Portofolio Terintegrasi (3 Tabel Digabung)
CREATE OR REPLACE VIEW vw_credit_portfolio_summary AS
SELECT 
    a.name_contract_type,
    a.code_gender,
    a.name_income_type,
    a.name_education_type,
    a.name_housing_type,
    a.age_group,
    a.dti_tier,
    a.ext_score_tier,
    CASE 
        WHEN COALESCE(b.bureau_active_loans, 0) = 0 THEN '0 Active'
        WHEN b.bureau_active_loans BETWEEN 1 AND 2 THEN '1-2 Active'
        ELSE '3+ Active'
    END AS bureau_active_tier,
    CASE WHEN COALESCE(p.prev_refused_count, 0) > 0 THEN 'Prior Refusal' ELSE 'Clean History' END AS prev_refusal_flag,
    COUNT(*) AS total_applicants,
    SUM(a.target) AS total_defaults,
    SUM(a.amt_income_total) AS total_income,
    SUM(a.amt_credit) AS total_credit_exposure,
    SUM(a.amt_annuity) AS total_annuity,
    SUM(CASE WHEN a.target = 1 THEN a.amt_credit ELSE 0 END) AS default_credit_exposure
FROM fact_applications a
LEFT JOIN dim_bureau_history b ON a.sk_id_curr = b.sk_id_curr
LEFT JOIN dim_prev_applications p ON a.sk_id_curr = p.sk_id_curr
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

-- View 2: Watchlist Segmen Berisiko Tinggi (Default Rate > 15% & Volume Signifikan)
CREATE OR REPLACE VIEW vw_high_risk_watchlist AS
SELECT 
    name_income_type,
    age_group,
    dti_tier,
    ext_score_tier,
    bureau_active_tier,
    prev_refusal_flag,
    SUM(total_applicants) AS segment_applicants,
    SUM(total_defaults) AS segment_defaults,
    ROUND(SUM(total_defaults)::NUMERIC / NULLIF(SUM(total_applicants), 0) * 100, 2) AS segment_default_rate_pct,
    ROUND(SUM(default_credit_exposure) / 1000000.0, 2) AS at_risk_exposure_million
FROM vw_credit_portfolio_summary
GROUP BY 1, 2, 3, 4, 5, 6
HAVING SUM(total_applicants) >= 100 
   AND (SUM(total_defaults)::NUMERIC / NULLIF(SUM(total_applicants), 0) * 100) >= 15.0
ORDER BY segment_default_rate_pct DESC;