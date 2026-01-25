const { db } = require("../firebase");
const { distance } = require("../services/geoService");

async function assignNearestDriver(clientLat, clientLng) {
  const driversSnap = await db.collection("drivers")
    .where("isAvailable", "==", true)
    .get();

  let bestDriver = null;
  let minDist = 999999;

  driversSnap.forEach(doc => {
    const d = doc.data();

    if (!d.lastLocation) return;

    const dist = distance(
      clientLat,
      clientLng,
      d.lastLocation.lat,
      d.lastLocation.lng
    );

    if (dist < minDist) {
      minDist = dist;
      bestDriver = { id: doc.id, ...d };
    }
  });

  return bestDriver;
}

module.exports = { assignNearestDriver };