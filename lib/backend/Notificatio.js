const axios = require("axios");

async function sendNotification(token, title, body) {
  await axios.post(
    "https://fcm.googleapis.com/fcm/send",
    {
      to: token,
      notification: {
        title,
        body
      }
    },
    {
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=YOUR_SERVER_KEY"
      }
    }
  );
}

module.exports = { sendNotification };