const express = require("express");

const productRoutes = require("./productRoutes");
const unitRoutes = require("./unitRoutes");

const router = express.Router();

router.get("/", (req, res) => {
    res.send("PantryPilot funcionando");
});

router.use("/products", productRoutes);
router.use("/units", unitRoutes);

module.exports = router;
