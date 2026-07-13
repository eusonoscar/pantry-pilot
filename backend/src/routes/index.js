const express = require("express");
const productRoutes = require("./productRoutes");

const router = express.Router();

router.get("/", (req, res) => {
    res.send("PantryPilot funcionando");
});

router.use("/products", productRoutes);

module.exports = router;
