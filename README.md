# TurboTax Customer Journey Analytics Foundation — Vanta Senior AE Interview Case

**Important:** Entire project is a self-directed, synthetic reconstruction inspired by types
of work an Analytics Engineer might do at a tax software company. It does NOT represent
verified internal TurboTax architecture, datasets or business outcomes. Do not present it
as a production system you owned unless you have independently done equivalent work.

## Business brief
Product, Lifecycle Marketing, Finance, CX, and Data Science need consistent self-service
customer conversion, outreach experiment, feature usage, and captured revenue metrics.
Marketing counts sends; Product counts sessions; Finance counts payments; executives need
a governed customer-level semantic definition rather than ad hoc SQL.

## File inventory / source system
- `crm_customers.csv`: 1,800 rows
- `product_sessions.csv`: 3,657 rows
- `product_events.csv`: 28,932 rows
- `experiment_assignments.csv`: 1,800 rows
- `marketing_outreach.csv`: 997 rows
- `tax_returns.csv`: 1,183 rows
- `billing_payments.csv`: 1,076 rows
- `quarantine_events.csv`: 3 intentional bad test rows; DON'T include in baseline loading.

## Day 1: ingest + dimensional modeling (~6–7h)
1. **Stakeholders/data contract (40m):** Product owns event tracking; Marketing owns
   assignment/outreach; Finance owns captured payments; CX owns customer friction.
   Specify one row per customer, event, payment, return; definitions in docs/metrics_contract.md.
2. **Snowflake setup (30m):** run CREATE DATABASE/WAREHOUSE/SCHEMA/FORMAT/STAGE in
   `snowflake/01_setup_and_copy.sql` with a role allowed to create them.
   IMPORTANT: Run the `COPY INTO` section only AFTER uploading source CSVs.
3. **Upload (60m):** Upload exactly 7 clean CSVs using Snowflake Snowsight to stage
   `@TURBOTAX_AE_LAB.RAW_PRODUCT.UPLOAD_STAGE` or SnowSQL PUT.
   Run CREATE TABLE definitions, then seven COPY INTO commands.
   Note: RAW columns kept as VARCHAR so staging owns reliable casting.
4. **Validate rows (20m):** count raw CUSTOMERS = 1,800; EVENTS = 28,932;
   ASSIGNMENTS = 1,800. Verify distinct customer IDs and event IDs.
5. **GitHub/dbt Cloud (40m):** new private repo, copy repo contents, configure dbt
   project with Snowflake database `TURBOTAX_AE_LAB`, warehouse `TT_AE_WH`,
   target schema `DBT_<YOURNAME>` with grants for RAW read and model schema creation.
   dbt Cloud git integration, then `dbt deps` and `dbt parse`.
6. **Staging (60m):** inspect seven stg_*.sql models: cast timestamp/date/numeric,
   hash synthetic email; dedup event_id. `dbt build --select path:models/staging`.
7. **Intermediate (40m):** inspect int_customer_product_usage and
   int_customer_outreach; check grouping to customer grain.
   `dbt build --select path:models/intermediate`.
8. **Core dimensional data (60m):** `dim_customers`, `fct_product_events`
   (incremental MERGE, 10-day ingestion watermark), `fct_tax_returns`,
   `fct_payments`, `fct_experiment_assignments`.
   `dbt build --select path:models/marts`.
9. **Acceptance:** `dbt build`, `dbt test`; customer dimension + mart both 1,800 rows;
   event fact 28,932; captured payments reconcile to the mart, without fanout.

**Source system ownership clarification:** Assignments are one row/customer for this
experiment. The outreach table is not the experiment population.
Outreach interaction is post-assignment; comparing clicked vs unclicked users is biased.

## Day 2: operational rigor and delivery (~5–7h)
1. **Incrementality:** build event fact; insert one new unique valid event into raw events
   with ingested_at within 10 days of latest watermark; run dbt build twice; confirm one new
   event only. Discuss correction/backfill outside lookback.
2. **Bad feed drill:** load quarantine_events.csv to ISOLATED test relation, run raw
   uniqueness and orphan checks, document incident / upstream Product Engineering resolution.
3. **Data quality + observability:** dbt tests, source freshness configuration, load counts,
   revenue reconciliation, log failure owner. Historical extract ≠ live freshness SLA.
4. **Security:** keep RAW emails restricted; don't propagate cleartext PII.
   Design keyed hashing/tokenization & Snowflake masking policies and warehouse role boundaries.
5. **Self-service + semantic:** run `snowflake/02_qa_and_consumption.sql`.
   Metric contract in `docs/metrics_contract.md`; example YAML in `docs/semantic_layer_example.yml`
   is illustrative, not enabled / guaranteed valid across MetricFlow versions.
6. **Experiment analytical guardrails:** report assignment counts, conversion
   and captured revenue, sample ratio, guardrail metrics. Do not present synthetic
   uplift as proven causal effect; compute uncertainty separately.
7. **Performance:** Snowflake Query Profile. Compare raw fact re-aggregation versus
   consuming materialized mart; record scans/time, don't claim speedups on tiny samples.
8. **Engineering process:** GitHub feature branch, PR, dbt build evidence,
   ask Codex and Claude Code for independent review; approve edits manually.
9. **Interview story:** explain requirements, heterogeneous ingest, fact/dim grains,
   robust revenue reconciliation, reusable metrics, security/privacy, test strategy,
   late arrivals and roadmap from batch CSV to managed ingestion.

## Commands
```bash
dbt deps
dbt parse
dbt build --select path:models/staging
dbt build --select path:models/intermediate
dbt build --select path:models/marts
dbt build
dbt test
```

## Important tradeoffs to discuss
- Customer journey is a current customer grain; production metrics need tax-year grain
  if customers file multiple years, account ownership resolution and dimension history.
- Event ingestion timestamps are separate from occurrence; MERGE watermark is an
  approximation, CDC needed for very late source corrections.
- `TRY_TO_*` casts avoid hard failures but invalid types become NULL; add anomaly tests and
  upstream quarantine and alerts.
- CRM row email hashing with SHA-256 isn't sufficient anonymization for real PII.
- Test statistical significance and assignment integrity before claiming uplift.
- With only ~28,932 events, performance is a conceptual demo; test scaled workloads
  before arguing about material gains.
