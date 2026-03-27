CREATE TABLE IF NOT EXISTS audit_logs (
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    username    TEXT        NOT NULL,
    path        TEXT        NOT NULL,
    action      TEXT        NOT NULL,
    table_name  TEXT        NOT NULL,
    record_id   TEXT        NOT NULL,
    old_data    JSONB       NOT NULL,
    new_data    JSONB       NOT NULL,
    request     JSONB,
    response    JSONB,
    status_code INT         NOT NULL,
    latency_ms  BIGINT      NOT NULL,
    ip_address  TEXT        NOT NULL,
    user_agent  TEXT        NOT NULL,
    request_id  UUID                 DEFAULT uuid_generate_v4(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);

CREATE TABLE IF NOT EXISTS webhook_logs (
    id               BIGSERIAL PRIMARY KEY,
    timestamp        TIMESTAMPTZ NOT NULL,
    provider         TEXT        NOT NULL,
    action           TEXT        NOT NULL,
    method           TEXT        NOT NULL,
    uri              TEXT        NOT NULL,
    path_params      JSONB       NOT NULL DEFAULT '{}'::jsonb,
    query_params     JSONB       NOT NULL DEFAULT '{}'::jsonb,
    headers          JSONB       NOT NULL DEFAULT '{}'::jsonb,
    request_body     JSONB,
    response_body    JSONB,
    status           INT         NOT NULL,
    response_headers JSONB       NOT NULL DEFAULT '{}'::jsonb,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
