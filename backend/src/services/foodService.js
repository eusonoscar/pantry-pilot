const pool = require("../config/database");

const getFoods = async () => {
    const result = await pool.query(`
        SELECT
            foods.id,
            foods.name,
            categories.name AS category,
            units.name AS defaultUnit,
            foods.is_prepared AS isPrepared
        FROM foods
        JOIN categories
            ON foods.category_id = categories.id
        JOIN units
            ON foods.default_unit_id = units.id
        ORDER BY foods.name;
    `);

    return result.rows;
};

module.exports = {
    getFoods
};
