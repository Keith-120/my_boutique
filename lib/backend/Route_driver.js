const express = require("express");
const { db } = require("../firebase");

const router = express.Router();

router.post("/update-location", async (req, res) => {
  const { driverId, lat, lng } = req.body;

  await db.collection("drivers").doc(driverId).update({
    lastLocation: { lat, lng },
  });

  res.json({ success: true });
});

module.exports = router;