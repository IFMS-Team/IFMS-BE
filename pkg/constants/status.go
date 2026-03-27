package constants

// General Status
const (
	StatusActive   = 1
	StatusInactive = 0
)

// Room Status
const (
	RoomAvailable   = "available"
	RoomUsing       = "using"
	RoomMaintenance = "maintenance"
)

// Product Status
const (
	ProductActive      = 1
	ProductMaintenance = 2
	ProductDamaged     = 3
	ProductDisposed    = 4
	ProductInactive    = 0
)

// Product Condition
const (
	ConditionNew       = "new"
	ConditionGood      = "good"
	ConditionDamaged   = "damaged"
	ConditionRepairing = "repairing"
)

// Building / Floor Status
const (
	BuildingActive   = 1
	BuildingInactive = 0
	FloorActive      = 1
	FloorInactive    = 0
)

// User Status
const (
	UserActive   = 1
	UserInactive = 0
	UserBanned   = 2
)

// Category / Item Status
const (
	CategoryActive   = 1
	CategoryInactive = 0
	ItemActive       = 1
	ItemInactive     = 0
)
