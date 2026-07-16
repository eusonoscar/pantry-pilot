-- PantryPilot — Schema V1

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Usuarios
CREATE TABLE IF NOT EXISTS users (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    email           TEXT            NOT NULL,
    name            TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT users_email_unique   UNIQUE (email),
    CONSTRAINT users_email_format   CHECK  (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

-- Categorías
CREATE TABLE IF NOT EXISTS categories (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT            NOT NULL,
    parent_id       UUID,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT categories_name_unique   UNIQUE (name),
    CONSTRAINT categories_name_length   CHECK  (char_length(name) BETWEEN 1 AND 100),

    CONSTRAINT categories_parent_fk     FOREIGN KEY (parent_id)
                                        REFERENCES  categories (id)
                                        ON DELETE   RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_categories_parent    ON categories (parent_id)
    WHERE parent_id IS NOT NULL;

-- Unidades de medida
CREATE TABLE IF NOT EXISTS units (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT            NOT NULL,
    code            TEXT            NOT NULL,
    kind            TEXT            NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT units_name_unique    UNIQUE (name),
    CONSTRAINT units_code_unique    UNIQUE (code),
    CONSTRAINT units_name_length    CHECK  (char_length(name) BETWEEN 1 AND 50),
    CONSTRAINT units_code_length    CHECK  (char_length(code) BETWEEN 1 AND 10),
    CONSTRAINT units_kind_values    CHECK  (kind IN ('weight', 'volume', 'count'))
);

-- Alimento
CREATE TABLE IF NOT EXISTS foods (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT            NOT NULL,
    category_id     UUID            NOT NULL,
    default_unit_id UUID            NOT NULL,
    is_prepared     BOOLEAN         NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT foods_name_unique        UNIQUE (name),
    CONSTRAINT foods_name_length        CHECK (char_length(name) BETWEEN 1 AND 150),

    CONSTRAINT foods_category_fk
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT foods_default_unit_fk
        FOREIGN KEY (default_unit_id)
        REFERENCES units(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_foods_category ON foods (category_id);

-- Informacion nutricional
CREATE TABLE IF NOT EXISTS nutritional_information (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    food_id             UUID            NOT NULL,

    basis_quantity      NUMERIC         NOT NULL,
    basis_unit_id       UUID            NOT NULL,

    calories_kcal       NUMERIC(7,2),
    protein_g           NUMERIC(6,2),
    carbohydrates_g     NUMERIC(6,2),
    sugar_g             NUMERIC(6,2),
    fat_g               NUMERIC(6,2),
    saturated_fat_g     NUMERIC(6,2),
    fiber_g             NUMERIC(6,2),
    salt_g              NUMERIC(6,2),

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT nutritional_information_food_unique
        UNIQUE (food_id),

    CONSTRAINT nutritional_information_food_fk
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE CASCADE,

    CONSTRAINT nutritional_information_basis_unit_fk
        FOREIGN KEY (basis_unit_id)
        REFERENCES units(id)
        ON DELETE RESTRICT,

    CONSTRAINT nutritional_calories_positive
        CHECK (calories_kcal IS NULL OR calories_kcal >= 0),

    CONSTRAINT nutritional_protein_positive
        CHECK (protein_g IS NULL OR protein_g >= 0),

    CONSTRAINT nutritional_carbohydrates_positive
        CHECK (carbohydrates_g IS NULL OR carbohydrates_g >= 0),

    CONSTRAINT nutritional_sugar_positive
        CHECK (sugar_g IS NULL OR sugar_g >= 0),

    CONSTRAINT nutritional_fat_positive
        CHECK (fat_g IS NULL OR fat_g >= 0),

    CONSTRAINT nutritional_saturated_fat_positive
        CHECK (saturated_fat_g IS NULL OR saturated_fat_g >= 0),

    CONSTRAINT nutritional_fiber_positive
        CHECK (fiber_g IS NULL OR fiber_g >= 0),

    CONSTRAINT nutritional_salt_positive
        CHECK (salt_g IS NULL OR salt_g >= 0)
);

-- Despensa
CREATE TABLE IF NOT EXISTS pantry_items (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL,
    food_id             UUID            NOT NULL,
    quantity            NUMERIC(10, 3),
    unit_id             UUID,
    brand               TEXT,
    expiration_date     DATE,
    added_at            TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT pantry_items_quantity_positive
        CHECK (quantity IS NULL OR quantity > 0),

    CONSTRAINT pantry_items_brand_length
        CHECK (brand IS NULL OR char_length(brand) BETWEEN 1 AND 100),

    CONSTRAINT pantry_items_quantity_unit_pair
        CHECK (
            (quantity IS NULL AND unit_id IS NULL)
            OR
            (quantity IS NOT NULL AND unit_id IS NOT NULL)
        ),

    CONSTRAINT pantry_items_user_fk
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT pantry_items_food_fk
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE RESTRICT,

    CONSTRAINT pantry_items_unit_fk
        FOREIGN KEY (unit_id)
        REFERENCES units(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_pantry_items_user
    ON pantry_items (user_id);

CREATE INDEX IF NOT EXISTS idx_pantry_items_food
    ON pantry_items (food_id);

CREATE INDEX IF NOT EXISTS idx_pantry_items_user_food
    ON pantry_items (user_id, food_id);

CREATE INDEX IF NOT EXISTS idx_pantry_items_expiration
    ON pantry_items (expiration_date)
    WHERE expiration_date IS NOT NULL;

-- Recetas
CREATE TABLE IF NOT EXISTS recipes (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
	user_id         UUID,
    name            TEXT            NOT NULL,
    description     TEXT,
    instructions    TEXT,
    prep_time_min   INT,
    cook_time_min   INT,
    servings        INT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT recipes_name_length          CHECK   (char_length(name) BETWEEN 1 AND 200),
    CONSTRAINT recipes_prep_time_positive   CHECK   (prep_time_min  IS NULL OR prep_time_min  > 0),
    CONSTRAINT recipes_cook_time_positive   CHECK   (cook_time_min  IS NULL OR cook_time_min  > 0),
    CONSTRAINT recipes_servings_positive    CHECK   (servings       IS NULL OR servings       > 0),

    CONSTRAINT recipes_user_fk FOREIGN KEY (user_id)
                               REFERENCES users(id)
                               ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_recipes_name ON recipes (name);

-- Ingredientes de receta
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id   UUID            NOT NULL,
    food_id     UUID            NOT NULL,
    quantity    NUMERIC(10, 3),
    unit_id     UUID,
    notes       TEXT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT recipe_ingredients_unique        UNIQUE  (recipe_id, food_id),
    CONSTRAINT recipe_ingredients_quantity_pos  CHECK   (quantity IS NULL OR quantity > 0),
    CONSTRAINT recipe_ingredients_notes_length  CHECK   (notes IS NULL OR char_length(notes) <= 300),
    CONSTRAINT recipe_ingredients_quantity_unit_pair CHECK (
        (quantity IS NULL AND unit_id IS NULL)
        OR
        (quantity IS NOT NULL AND unit_id IS NOT NULL)
    ),

    CONSTRAINT recipe_ingredients_recipe_fk     FOREIGN KEY (recipe_id)
                                                REFERENCES  recipes (id)
                                                ON DELETE   CASCADE,

    CONSTRAINT recipe_ingredients_food_fk       FOREIGN KEY (food_id)
                                                REFERENCES  foods (id)
                                                ON DELETE   RESTRICT,

    CONSTRAINT recipe_ingredients_unit_fk       FOREIGN KEY (unit_id)
                                                REFERENCES  units (id)
                                                ON DELETE   RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe ON recipe_ingredients (recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_food   ON recipe_ingredients (food_id);

-- Lista de la compra
CREATE TABLE IF NOT EXISTS shopping_lists (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id 	UUID 			NOT NULL,
    name        TEXT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT shopping_lists_name_length   CHECK (name IS NULL OR char_length(name) BETWEEN 1 AND 150),

    CONSTRAINT shopping_lists_user_fk       FOREIGN KEY (user_id)
                                            REFERENCES  users (id)
                                            ON DELETE   CASCADE
);

CREATE INDEX IF NOT EXISTS idx_shopping_lists_user ON shopping_lists (user_id);

-- Elementos de la lista de la compra
CREATE TABLE IF NOT EXISTS shopping_list_items (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id    UUID            NOT NULL,
    food_id             UUID            NOT NULL,
    quantity            NUMERIC(10, 3),
    unit_id             UUID,
    is_checked          BOOLEAN         NOT NULL DEFAULT false,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT shopping_list_items_quantity_positive    CHECK (quantity IS NULL OR quantity > 0),

    CONSTRAINT shopping_list_items_list_fk  FOREIGN KEY (shopping_list_id)
                                            REFERENCES  shopping_lists (id)
                                            ON DELETE   CASCADE,

    CONSTRAINT shopping_list_items_food_fk  FOREIGN KEY (food_id)
                                            REFERENCES  foods (id)
                                            ON DELETE   RESTRICT,

    CONSTRAINT shopping_list_items_unit_fk  FOREIGN KEY (unit_id)
                                            REFERENCES  units (id)
                                            ON DELETE   RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_shopping_list_items_list     ON shopping_list_items (shopping_list_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_items_food     ON shopping_list_items (food_id);
