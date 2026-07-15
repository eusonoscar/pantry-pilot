const pool = require("../config/database");

const getUnits = async () => {
    const result = await pool.query(`
        SELECT *
        FROM units
        ORDER BY id;
    `);

    return result.rows;
};

module.exports = {
    getUnits
};
