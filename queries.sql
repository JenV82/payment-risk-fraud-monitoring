-- Query 1: Prioritize open alerts by severity and oldest creation date.
SELECT "merchants"."business_name", "risk_alerts"."severity",
    "risk_alerts"."alert_status", "risk_alerts"."alert_reason",
    "risk_alerts"."created_at"
FROM "merchants"
JOIN "risk_alerts"
    ON "risk_alerts"."merchant_id" = "merchants"."id"
WHERE "risk_alerts"."alert_status" = 'Open'
ORDER BY
    CASE
        WHEN "risk_alerts"."severity" = 'High' THEN 1
        WHEN "risk_alerts"."severity" = 'Medium' THEN 2
        WHEN "risk_alerts"."severity" = 'Low' THEN 3
    END ASC,
    "risk_alerts"."created_at" ASC;

-- Query 2: Count risk alerts by severity level.
SELECT "severity", COUNT(*) AS "alert_count" FROM "risk_alerts"
GROUP BY "severity";

-- Query 3: Count open risk alerts for each merchant.
SELECT "merchants"."business_name",
    COUNT("risk_alerts"."id") AS "open_alerts"
FROM "merchants"
LEFT JOIN "risk_alerts"
    ON "risk_alerts"."merchant_id" = "merchants"."id"
    AND "risk_alerts"."alert_status" = 'Open'
GROUP BY "merchants"."id";

-- Query 4: Identify transactions with AVS or CVV2 mismatches by merchant.
SELECT "merchants"."business_name", "transactions"."id", "transactions"."amount",
    "transactions"."status", "transactions"."avs", "transactions"."cvv2"
FROM "transactions"
JOIN "merchants"
    ON "merchants"."id" = "transactions"."merchant_id"
WHERE "transactions"."avs" = 'No Match' OR "transactions"."cvv2" = 'No Match';

-- Query 5: Identify merchants with more than five declined transactions
-- within a historical 30-minute UTC window.
SELECT "merchants"."business_name", COUNT(*) AS "declined_count"
FROM "transactions"
JOIN "merchants"
    ON "merchants"."id" = "transactions"."merchant_id"
WHERE "transactions"."status" = 'Declined'
AND "transactions"."transaction_datetime" >= '2026-11-18 16:00:00'
AND "transactions"."transaction_datetime" < '2026-11-18 16:30:00'
GROUP BY "merchants"."id"
HAVING "declined_count" > 5;

-- Query 6: Identify unresolved chargebacks and prioritize
-- them by the earliest response deadline.
SELECT "merchants"."business_name", "chargebacks"."id",
    "chargebacks"."dispute_amount", "chargebacks"."dispute_status",
    "chargebacks"."response_deadline"
FROM "merchants"
JOIN "transactions"
	ON "transactions"."merchant_id" = "merchants"."id"
JOIN "chargebacks"
	ON "chargebacks"."transaction_id" = "transactions"."id"
WHERE "chargebacks"."dispute_status" != 'Resolved'
ORDER BY "chargebacks"."response_deadline" ASC;

-- Query 7: Identify unresolved chargebacks with response deadlines
-- within the next seven days or already overdue.
SELECT "merchants"."business_name", "chargebacks"."id",
    "chargebacks"."dispute_amount", "chargebacks"."dispute_status",
    "chargebacks"."response_deadline"
FROM "merchants"
JOIN "transactions"
	ON "transactions"."merchant_id" = "merchants"."id"
JOIN "chargebacks"
	ON "chargebacks"."transaction_id" = "transactions"."id"
WHERE "chargebacks"."dispute_status" != 'Resolved'
AND "chargebacks"."response_deadline" <= date('now', '+7 days')
ORDER BY "chargebacks"."response_deadline" ASC;

-- Query 8: Count open risk alerts by severity, ordered by risk priority.
SELECT "severity", COUNT(*) AS "alert_count"
FROM "risk_alerts"
WHERE "alert_status" = 'Open'
GROUP BY "severity"
ORDER BY
    CASE
        WHEN "severity" = 'High' THEN 1
        WHEN "severity" = 'Medium' THEN 2
        WHEN "severity" = 'Low' THEN 3
    END ASC;

-- Query 9: Example of inserting a new merchant account.
-- This statement was used when testing merchant relationships.
-- Commented out to prevent duplicate records when queries.sql is executed.

-- INSERT INTO "merchants" (
--     "id", "business_name", "industry", "account_status",
--     "onboarding_date", "risk_classification"
-- )
-- VALUES (
--     2, 'Mountain View Electronics', 'Electronics', 'Active',
--     '2026-11-18', 'High'
-- );

-- Query 10: Example of updating a chargeback response deadline.
-- Previously used to test deadline monitoring in Query 7.
-- Commented out to preserve the original sample data.

-- UPDATE "chargebacks"
-- SET "response_deadline" = '2026-11-22'
-- WHERE "id" = 2;

-- Query 11: Example of deleting an accidentally duplicated risk alert.
-- Previously used during sample data testing.
-- Commented out to prevent accidental deletion of existing records.

-- DELETE FROM "risk_alerts"
-- WHERE "id" = <duplicate_alert_id>;