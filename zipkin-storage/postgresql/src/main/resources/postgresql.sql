-- Rewrite of mysql.sql
-- Comments removed. If needed, add them with:
-- COMMENT ON COLUMN <table.column> IS <comment>;

BEGIN;
CREATE TABLE IF NOT EXISTS zipkin_spans (
  trace_id_high BIGINT NOT NULL DEFAULT 0,
  trace_id BIGINT NOT NULL,
  id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  parent_id BIGINT,
  debug BIT(1),
  start_ts BIGINT, 
  duration BIGINT 
);

ALTER TABLE zipkin_spans ADD UNIQUE (trace_id_high, trace_id, id);
CREATE INDEX ON zipkin_spans (trace_id_high, trace_id, id);
-- froske: Useless index. Similar as above:
-- ALTER TABLE zipkin_spans ADD INDEX(`trace_id_high`, `trace_id`) COMMENT 'for getTracesByIds';
CREATE INDEX ON zipkin_spans (name);
CREATE INDEX ON zipkin_spans (start_ts);

CREATE TABLE IF NOT EXISTS zipkin_annotations (
  trace_id_high BIGINT NOT NULL DEFAULT 0,
  trace_id BIGINT NOT NULL,
  span_id BIGINT NOT NULL,
  a_key VARCHAR(255) NOT NULL,
  a_value BYTEA,
  a_type INT NOT NULL,
  a_timestamp BIGINT,
  endpoint_ipv4 INET, -- Check if this works as expected
  endpoint_ipv6 INET, -- Check if this works as expected
  endpoint_port SMALLINT,
  endpoint_service_name VARCHAR(255)
);

ALTER TABLE zipkin_annotations ADD UNIQUE (trace_id_high, trace_id, span_id, a_key, a_timestamp);
CREATE INDEX ON zipkin_annotations (trace_id_high, trace_id, span_id);
-- ALTER TABLE zipkin_annotations ADD INDEX(`trace_id_high`, `trace_id`);
CREATE INDEX ON zipkin_annotations (endpoint_service_name);
CREATE INDEX ON zipkin_annotations (a_type);
CREATE INDEX ON zipkin_annotations (a_key);
CREATE INDEX ON zipkin_annotations (trace_id, span_id, a_key);

CREATE TABLE IF NOT EXISTS zipkin_dependencies (
  day DATE NOT NULL,
  parent VARCHAR(255) NOT NULL,
  child VARCHAR(255) NOT NULL,
  call_count BIGINT,
  error_count BIGINT
);

ALTER TABLE zipkin_dependencies ADD UNIQUE (day, parent, child);
COMMIT;
