// ====== BACKEND (Node.js avec Express et Vonage) ======
const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");
const { Vonage } = require('@vonage/server-sdk');

const app = express();
app.use(bodyParser.json());

// Configuration Firebase
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Configuration Vonage
const vonage = new Vonage({
  apiKey: "2b55365e",
  apiSecret: "fQ99R2Jk7o7aS12F",
});

// Mémoire temporaire pour les OTP
let otpStore = {}; // { "+213XXXXXXXX": "123456" }

// Envoi OTP
app.post("/send-otp", async (req, res) => {
  const { phoneNumber } = req.body;
  if (!phoneNumber) {
    return res.status(400).send({ success: false, error: "phoneNumber manquant" });
  }

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  otpStore[phoneNumber] = otp;
  console.log(`Envoi OTP ${otp} à ${phoneNumber}`);

  await vonage.sms.send({
  to: phoneNumber,
  from: "TARI9IApp",
  text: `Votre code est : ${otp}`,
}, (err, responseData) => {
  if (err) {
    console.error("Erreur Vonage:", err);
  } else {
    console.log("Réponse Vonage:", responseData);
  }
});

});

// Vérification OTP + création token Firebase
app.post("/verify-otp", async (req, res) => {
  const { phoneNumber, otp } = req.body;
  if (!phoneNumber || !otp) {
    return res.status(400).send({ success: false, error: "phoneNumber ou otp manquant" });
  }

  if (otpStore[phoneNumber] !== otp) {
    return res.status(400).send({ success: false, error: "OTP incorrect" });
  }

  const uid = phoneNumber.replace('+', '');

  try {
    const customToken = await admin.auth().createCustomToken(uid, { phone: phoneNumber });
    delete otpStore[phoneNumber];
    res.send({ success: true, token: customToken });
  } catch (err) {
    res.status(500).send({ success: false, error: err.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Serveur lancé sur http://localhost:${PORT}`);
});