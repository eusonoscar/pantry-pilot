const express = require("express");
const unitController = require("../controllers/unitController");

const router = express.Router();

router.get("/", unitController.getUnits);

module.exports = router;
