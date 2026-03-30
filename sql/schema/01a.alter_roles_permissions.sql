-- Thêm cột thiếu cho roles
ALTER TABLE roles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();

-- Thêm cột thiếu cho permissions
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS status INTEGER NOT NULL DEFAULT 1;
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'permissions' AND column_name = 'code') THEN
        ALTER TABLE permissions ADD COLUMN code VARCHAR(100) NOT NULL DEFAULT '';
    END IF;
END $$;
