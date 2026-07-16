const foodService = require("../services/foodService");

const getFoods = async (req, res) => {
    try {
        const foods = await foodService.getFoods();

        res.json(foods);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: "Error al obtener los alimentos."
        });
    }
};

module.exports = {
    getFoods
};
