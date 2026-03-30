-- Ticket kiểm kê chính (tạo bởi worker daily hoặc sub-admin scheduled)
CREATE TABLE IF NOT EXISTS maintenance_tickets (
    ticket_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_type VARCHAR(20) NOT NULL CHECK (ticket_type IN ('daily', 'scheduled')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    scheduled_date DATE,
    completed_date TIMESTAMPTZ,
    building_id UUID NOT NULL REFERENCES buildings(building_id) ON DELETE RESTRICT,
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    assigned_to UUID REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Scope: ticket kiểm kê ở floor nào, room nào
CREATE TABLE IF NOT EXISTS maintenance_ticket_scopes (
    scope_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES maintenance_tickets(ticket_id) ON DELETE CASCADE,
    floor_id UUID REFERENCES floors(floor_id) ON DELETE CASCADE,
    room_id UUID REFERENCES rooms(room_id) ON DELETE CASCADE
);

-- Chi tiết kiểm kê từng asset (product)
CREATE TABLE IF NOT EXISTS maintenance_ticket_items (
    ticket_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES maintenance_tickets(ticket_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    room_id UUID REFERENCES rooms(room_id) ON DELETE SET NULL,
    check_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (check_status IN ('pending', 'ok', 'damaged', 'missing', 'needs_repair')),
    note TEXT,
    checked_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    checked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mt_building ON maintenance_tickets(building_id);
CREATE INDEX IF NOT EXISTS idx_mt_status ON maintenance_tickets(status);
CREATE INDEX IF NOT EXISTS idx_mt_type ON maintenance_tickets(ticket_type);
CREATE INDEX IF NOT EXISTS idx_mt_scheduled ON maintenance_tickets(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_mts_ticket ON maintenance_ticket_scopes(ticket_id);
CREATE INDEX IF NOT EXISTS idx_mti_ticket ON maintenance_ticket_items(ticket_id);
CREATE INDEX IF NOT EXISTS idx_mti_product ON maintenance_ticket_items(product_id);
