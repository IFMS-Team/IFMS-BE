
--- Report Checker
CREATE TABLE IF NOT EXISTS report_checker (
    report_checker_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status INT NOT NULL CHECK (status IN (1, 2)),
    description VARCHAR(500) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    update_at TIMESTAMP NOT NULL DEFAULT NOW(),
    url_image VARCHAR(255),
    confirm_by VARCHAR(50),
    user_id UUID NOT NULL,
    username VARCHAR(50) NOT NULL,
    is_open INT NOT NULL CHECK (is_open IN (1, 2)),
    room_id UUID,
    CONSTRAINT fk_room
        FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);



--- Report Guest
CREATE TABLE IF NOT EXISTS report_guest (
    report_guest_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_sender TEXT NOT NULL,
    status INT NOT NULL CHECK (status IN (1, 2)), -- 1 = Missing, 2 = Broken
    description TEXT NOT NULL,
    url_image VARCHAR(255), -- Optional for Missing
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    room_id UUID NOT NULL,
    item_id UUID, -- Nullable if unknown
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    confirmed_by UUID, -- Nullable
    CONSTRAINT fk_room
        FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_item
        FOREIGN KEY (item_id) REFERENCES item(item_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
)