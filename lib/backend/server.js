const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const deliveryRoutes = require("./routes/deliveryRoutes");
const driverRoutes = require("./routes/driverRoutes");

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use("/delivery", deliveryRoutes);
app.use("/driver", driverRoutes);

app.listen(3000, () => {
  console.log("Backend running on port 3000");
});