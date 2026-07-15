const unitService = require("../services/unitService");

const getUnits = async (req, res) => {
    try {
        const units = await unitService.getUnits();

        res.json(units);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: "Error al obtener las unidades."
        });
    }
};

module.exports = {
    getUnits
};
