-- Store merchant account information, including account status
-- and risk classification, to support merchant risk reviews.
CREATE TABLE "merchants" (
    "id" INTEGER PRIMARY KEY,
    "business_name" TEXT NOT NULL,
    "industry" TEXT NOT NULL,
    "account_status" TEXT NOT NULL
        CHECK ("account_status" IN ('Active', 'Restricted', 'Suspended', 'Closed',
            'Terminated')),
    "onboarding_date" TEXT NOT NULL,
    "risk_classification" TEXT NOT NULL
        CHECK ("risk_classification" IN ('Low', 'Medium', 'High'))
);

-- Store merchant payment transactions and card verification results.
-- Monetary amounts are stored as integer cents for accuracy.
CREATE TABLE "transactions" (
    "id" INTEGER PRIMARY KEY,
    "merchant_id" INTEGER NOT NULL,
    "transaction_datetime" TEXT NOT NULL,
    "amount" INTEGER NOT NULL
        CHECK ("amount" > 0),
    "status" TEXT NOT NULL
        CHECK ("status" IN ('Authorized', 'Captured', 'Declined', 'Refunded',
            'Partially Refunded', 'Voided')),
    "cardholder_name" TEXT NOT NULL,
    "billing_zip" TEXT NOT NULL,
    "avs" TEXT NOT NULL
        CHECK ("avs" IN ('Full Match', 'ZIP Match Only', 'Address Match Only',
            'No Match', 'Unavailable')),
    "cvv2" TEXT NOT NULL
        CHECK ("cvv2" IN ('Match', 'No Match', 'Unavailable')),
    "card_brand" TEXT NOT NULL
        CHECK ("card_brand" IN ('Visa', 'MasterCard', 'Discover', 'American Express')),
    "card_last_four" TEXT NOT NULL
        CHECK ("card_last_four" GLOB '[0-9][0-9][0-9][0-9]'),
    FOREIGN KEY ("merchant_id") REFERENCES "merchants"("id")
);

-- Track payment disputes, response deadlines, and resolution outcomes.
-- Each chargeback references the original transaction.
CREATE TABLE "chargebacks" (
    "id" INTEGER PRIMARY KEY,
    "transaction_id" INTEGER NOT NULL,
    "reason_code" TEXT NOT NULL,
    "dispute_amount" INTEGER NOT NULL
        CHECK ("dispute_amount" > 0),
    "dispute_date" TEXT NOT NULL,
    "response_deadline" TEXT NOT NULL,
    "dispute_status" TEXT NOT NULL
        CHECK ("dispute_status" IN ('Open', 'Under Review', 'Represented', 'Resolved')),
    "resolution_date" TEXT,
    "outcome" TEXT
        CHECK ("outcome" IN ('Won', 'Lost', 'Accepted')),
    FOREIGN KEY ("transaction_id") REFERENCES "transactions"("id"),
    CHECK (
        (
            "dispute_status" = 'Resolved'
            AND "outcome" IS NOT NULL
            AND "resolution_date" IS NOT NULL
        )
        OR
        (
            "dispute_status" != 'Resolved'
            AND "outcome" IS NULL
            AND "resolution_date" IS NULL
        )
    )
);

-- Store merchant-level and transaction-level risk alerts.
-- Track alert severity, investigation status, and resolution details.
CREATE TABLE "risk_alerts" (
    "id" INTEGER PRIMARY KEY,
    "merchant_id" INTEGER NOT NULL,
    "transaction_id" INTEGER,
    "alert_type" TEXT NOT NULL
        CHECK ("alert_type" IN ('Merchant', 'Transaction')),
    "alert_reason" TEXT NOT NULL,
    "severity" TEXT NOT NULL
        CHECK ("severity" IN ('High', 'Medium', 'Low')),
    "alert_status" TEXT NOT NULL
        CHECK ("alert_status" IN ('Open', 'Under Review', 'Resolved', 'Dismissed')),
    "created_at" TEXT NOT NULL,
    "resolved_at" TEXT,
    "resolution_notes" TEXT,
    FOREIGN KEY ("merchant_id") REFERENCES "merchants"("id"),
    FOREIGN KEY ("transaction_id") REFERENCES "transactions"("id"),
    CHECK (
        (
            "alert_type" = 'Transaction' AND "transaction_id" IS NOT NULL
        )
        OR
        (
            "alert_type" = 'Merchant' AND "transaction_id" IS NULL
        )
    )
);

-- Improve transaction lookups and joins by merchant ID.
CREATE INDEX "idx_transactions_merchant_id"
ON "transactions" ("merchant_id");

-- Improve chargeback searches filtered by response deadline.
CREATE INDEX "idx_chargebacks_response_deadline"
ON "chargebacks" ("response_deadline");

