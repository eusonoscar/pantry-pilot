const express = require("express");

const app = express();

app.get("/", (req, res) => {
    res.send("PantryPilot funcionando");
});

module.exports = app;
