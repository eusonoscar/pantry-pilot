-- Table users
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Table categories
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    parent_id BIGINT REFERENCES categories(id)
);

CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories (parent_id);

-- Table units
CREATE TABLE IF NOT EXISTS units (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    kind TEXT NOT NULL,

    CHECK (kind IN ('weight', 'volume', 'count'))
);

-- Table brands
CREATE TABLE IF NOT EXISTS brands (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Table foods
CREATE TABLE IF NOT EXISTS foods (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    category_id BIGINT REFERENCES categories(id),
    is_prepared BOOLEAN NOT NULL DEFAULT FALSE,
    default_unit_id BIGINT NOT NULL REFERENCES units(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_foods_category_id ON foods (category_id);
CREATE INDEX IF NOT EXISTS idx_foods_default_unit_id ON foods (default_unit_id);

-- Table products
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    food_id BIGINT NOT NULL REFERENCES foods(id),
    brand_id BIGINT NOT NULL REFERENCES brands(id),
    name TEXT NOT NULL,
    package_size NUMERIC,
    package_unit_id BIGINT REFERENCES units(id),
    barcode TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_food_id ON products (food_id);
CREATE INDEX IF NOT EXISTS idx_products_brand_id ON products (brand_id);

-- Table nutritional_information
CREATE TABLE IF NOT EXISTS nutritional_information (
    id BIGSERIAL PRIMARY KEY,

    food_id BIGINT REFERENCES foods(id),
    product_id BIGINT REFERENCES products(id),

    basis_quantity NUMERIC NOT NULL,
    basis_unit_id BIGINT NOT NULL REFERENCES units(id),

    kcal NUMERIC,
    proteins_g NUMERIC,
    carbs_g NUMERIC,
    sugars_g NUMERIC,
    fats_g NUMERIC,
    fiber_g NUMERIC,
    salt_g NUMERIC,

    source TEXT,

    CHECK (
        (food_id IS NOT NULL AND product_id IS NULL)
        OR
        (food_id IS NULL AND product_id IS NOT NULL)
    ),

    UNIQUE (food_id),
    UNIQUE (product_id)
);

CREATE INDEX IF NOT EXISTS idx_nutritional_information_basis_unit_id ON nutritional_information (basis_unit_id);

-- Table pantry_items
CREATE TABLE IF NOT EXISTS pantry_items (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    food_id BIGINT NOT NULL REFERENCES foods(id),
    product_id BIGINT REFERENCES products(id),

    quantity NUMERIC,
    unit_id BIGINT REFERENCES units(id),

    expiration_date DATE,

    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CHECK (
        (quantity IS NULL AND unit_id IS NULL)
        OR
        (quantity IS NOT NULL AND unit_id IS NOT NULL)
    ),
    CHECK (quantity >= 0)
);

CREATE INDEX IF NOT EXISTS idx_pantry_items_user_id ON pantry_items (user_id);
CREATE INDEX IF NOT EXISTS idx_pantry_items_food_id ON pantry_items (food_id);
CREATE INDEX IF NOT EXISTS idx_pantry_items_product_id ON pantry_items (product_id);
CREATE INDEX IF NOT EXISTS idx_pantry_items_unit_id ON pantry_items (unit_id);

-- Table recipes
CREATE TABLE IF NOT EXISTS recipes (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,

    name TEXT NOT NULL,

    instructions TEXT,

    servings NUMERIC,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_recipes_user_id ON recipes (user_id);

-- Table recipe_ingredients
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id BIGSERIAL PRIMARY KEY,

    recipe_id BIGINT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,

    food_id BIGINT NOT NULL REFERENCES foods(id),

    quantity NUMERIC,

    unit_id BIGINT REFERENCES units(id),

    is_optional BOOLEAN NOT NULL DEFAULT FALSE,

    UNIQUE (recipe_id, food_id),

    CHECK (
        (quantity IS NULL AND unit_id IS NULL)
        OR
        (quantity IS NOT NULL AND unit_id IS NOT NULL)
    ),
    CHECK (quantity >= 0)
);

CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_food_id ON recipe_ingredients (food_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_unit_id ON recipe_ingredients (unit_id);

-- Table shopping_lists
CREATE TABLE IF NOT EXISTS shopping_lists (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    name TEXT NOT NULL DEFAULT 'Lista de la compra',

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_shopping_lists_user_id ON shopping_lists (user_id);

-- Table shopping_list_items
CREATE TABLE IF NOT EXISTS shopping_list_items (
    id BIGSERIAL PRIMARY KEY,

    shopping_list_id BIGINT NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,

    food_id BIGINT NOT NULL REFERENCES foods(id),
    product_id BIGINT REFERENCES products(id),

    quantity NUMERIC,
    unit_id BIGINT REFERENCES units(id),

    is_checked BOOLEAN NOT NULL DEFAULT FALSE,

    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CHECK (
        (quantity IS NULL AND unit_id IS NULL)
        OR
        (quantity IS NOT NULL AND unit_id IS NOT NULL)
    ),
    CHECK (quantity >= 0)
);

CREATE INDEX IF NOT EXISTS idx_shopping_list_items_shopping_list_id ON shopping_list_items (shopping_list_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_items_food_id ON shopping_list_items (food_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_items_product_id ON shopping_list_items (product_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_items_unit_id ON shopping_list_items (unit_id);
