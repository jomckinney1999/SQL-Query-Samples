-- Anonymized core schema to support sample queries

CREATE TABLE clients (
  client_id        INT PRIMARY KEY,
  client_name      VARCHAR(255),
  client_tier      VARCHAR(50),
  region           VARCHAR(50),
  created_at       TIMESTAMP
);

CREATE TABLE products (
  product_id       INT PRIMARY KEY,
  product_name     VARCHAR(255),
  category         VARCHAR(100),
  unit_cost        DECIMAL(12,2),
  unit_price       DECIMAL(12,2),
  active_flag      INT,
  created_at       TIMESTAMP
);

CREATE TABLE orders (
  order_id         INT PRIMARY KEY,
  client_id        INT,
  order_date       DATE,
  order_status     VARCHAR(50),
  channel          VARCHAR(50),
  total_amount     DECIMAL(12,2),
  currency         VARCHAR(10),
  created_at       TIMESTAMP
);

CREATE TABLE order_items (
  order_item_id    INT PRIMARY KEY,
  order_id         INT,
  product_id       INT,
  quantity         INT,
  unit_price       DECIMAL(12,2),
  line_amount      DECIMAL(12,2)
);

CREATE TABLE workflow_steps (
  step_id          INT PRIMARY KEY,
  step_name        VARCHAR(100),
  step_group       VARCHAR(100)
);

CREATE TABLE order_events (
  event_id         INT PRIMARY KEY,
  order_id         INT,
  step_id          INT,
  event_type       VARCHAR(50),
  event_status     VARCHAR(50),
  event_ts         TIMESTAMP,
  payload_json     TEXT,
  payload_xml      TEXT
);

CREATE TABLE app_metrics (
  metric_id        INT PRIMARY KEY,
  service_name     VARCHAR(100),
  endpoint         VARCHAR(200),
  metric_ts        TIMESTAMP,
  latency_ms       INT,
  status_code      INT,
  error_flag       INT,
  region           VARCHAR(50)
);

CREATE TABLE institutions (
  institution_id   INT PRIMARY KEY,
  institution_name VARCHAR(255),
  institution_type VARCHAR(50),
  country          VARCHAR(50)
);

CREATE TABLE bank_accounts (
  account_id       INT PRIMARY KEY,
  institution_id   INT,
  client_id        INT,
  account_type     VARCHAR(50),
  status           VARCHAR(50),
  opened_date      DATE,
  closed_date      DATE
);
