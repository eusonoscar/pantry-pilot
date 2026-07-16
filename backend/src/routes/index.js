const express = require("express");

const unitRoutes = require("./unitRoutes");
const foodRoutes = require("./foodRoutes");

const router = express.Router();

router.get("/", (req, res) => {
    res.send("PantryPilot funcionando");
});

router.use("/units", unitRoutes);
router.use("/foods", foodRoutes);

module.exports = router;
