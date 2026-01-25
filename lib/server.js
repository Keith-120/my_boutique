const express = require("express");
const axios = require("axios");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;


const PAYPAL_API = "https://api-m.sandbox.paypal.com";


const TAUX = 600;


async function getAccessToken() {
const response = await axios({
url: `${PAYPAL_API}/v1/oauth2/token`,
method: "post",
headers: {
"Accept": "application/json",
"Accept-Language": "en_US",
},
auth: {
username: process.env.PAYPAL_CLIENT_ID,
password: process.env.PAYPAL_SECRET,
},
data: "grant_type=client_credentials",
});

return response.data.access_token;
}

// 🔵 CREATE PAYMENT
app.post("/create_payment", async (req, res) => {
try {
const { amount_cfa, tx_ref, email } = req.body;


const amountUSD = (amount_cfa / TAUX).toFixed(2);

const accessToken = await getAccessToken();

const response = await axios({
  url: `${PAYPAL_API}/v2/checkout/orders`,
  method: "post",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${accessToken}`,
  },
  data: {
    intent: "CAPTURE",
    purchase_units: [
      {
        reference_id: tx_ref,
        amount: {
          currency_code: "USD",
          value: amountUSD,
        },
      },
    ],
    application_context: {
      return_url: "https://your-app.com/success",
      cancel_url: "https://your-app.com/cancel",
    },
  },
});

const order = response.data;

const approvalLink = order.links.find(
  (link) => link.rel === "approve"
).href;

res.json({
  status: "success",
  approval_url: approvalLink,
  paypal_order_id: order.id,
  amount_usd: amountUSD,
});


} catch (error) {
console.error(error.response?.data || error.message);
res.json({
status: "error",
message: "Erreur création paiement",
});
}
});


app.get("/", (req, res) => {
res.send("Server PayPal OK 🚀");
});

app.listen(PORT, () => {
console.log(`Serveur lancé sur ${PORT}`);
});



app.get("/verify_payment", async (req, res) => {
try {
const { order_id, tx_ref, amount_cfa, email } = req.query;

const accessToken = await getAccessToken();

const response = await axios({
  url: `${PAYPAL_API}/v2/checkout/orders/${order_id}`,
  method: "get",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${accessToken}`,
  },
});

const data = response.data;

// 🔥 statut du paiement
let status = data.status;

// ✔️ paiement validé
if (status === "COMPLETED") {
  console.log("Paiement validé :", tx_ref);

  // 👉 ici tu peux stocker en base (MongoDB / Firestore / etc)
  // Exemple simple log :
  console.log({
    tx_ref,
    order_id,
    email,
    amount_cfa,
    status,
  });
}

res.json({
  status: "success",
  data,
});

} catch (error) {
console.error(error.response?.data || error.message);
res.json({
status: "error",
message: "Erreur verification",
});
}
});

//
// 🔵 TEST SERVER
//
app.get("/", (req, res) => {
res.send("PayPal Server OK 🚀 (Create + Verify + CFA→USD)");
});

app.listen(PORT, () => {
console.log('Serveur lancé sur port ${PORT}');
});