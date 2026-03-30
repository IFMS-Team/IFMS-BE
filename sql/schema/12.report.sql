-- Report từ người trong hệ thống (checker/staff)
CREATE TABLE IF NOT EXISTS report_checker (
    report_checker_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    room_id UUID REFERENCES rooms(room_id) ON DELETE SET NULL,
    status INT NOT NULL DEFAULT 1 CHECK (status IN (1, 2)),
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    description TEXT NOT NULL,
    url_image VARCHAR(255),
    confirmed_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Report từ khách (quét QR phòng để báo cáo)
CREATE TABLE IF NOT EXISTS report_guest (
    report_guest_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_sender VARCHAR(100) NOT NULL,
    phone_sender VARCHAR(20),
    email_sender VARCHAR(100),
    room_id UUID REFERENCES rooms(room_id) ON DELETE SET NULL,
    item_id UUID REFERENCES items(item_id) ON DELETE SET NULL,
    status INT NOT NULL DEFAULT 1 CHECK (status IN (1, 2)),
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    description TEXT NOT NULL,
    url_image VARCHAR(255),
    confirmed_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
