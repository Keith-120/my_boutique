const express = require("express");
const { db } = require("../firebase");
const { assignNearestDriver } = require("../services/assignService");
const { sendNotification } = require("../services/fcmService");

const router = express.Router();

router.post("/create", async (req, res) => {
  const { orderId, clientLocation } = req.body;

  const driver = await assignNearestDriver(
    clientLocation.lat,
    clientLocation.lng
  );

  if (!driver) {
    return res.json({ success: false, message: "No driver available" });
  }

  await db.collection("deliveries").doc(orderId).set({
    status: "assigned",
    driverId: driver.id,
    clientLocation,
    driverLocation: driver.lastLocation,
  }, { merge: true });

  if (driver.fcmToken) {
    await sendNotification(
      driver.fcmToken,
      "Nouvelle livraison",
      "Une commande est disponible"
    );
  }

  res.json({
    success: true,
    driverId: driver.id
  });
});

module.exports = router;