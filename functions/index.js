import functions from "firebase-functions";
import express from "express";
import axios from "axios";
import cors from "cors";

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

app.post("/aiChat", async (req, res) => {
  try {
    const { message } = req.body;
    const hfKey = functions.config().huggingface.key;

    const response = await axios.post(
      "https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill",
      { inputs: message },
      {
        headers: { Authorization: `Bearer ${hfKey}` },
        timeout: 60000,
      }
    );

    const reply = response.data[0]?.generated_text || "🤔 AI is thinking...";
    res.json({ reply });

  } catch (err) {
    console.error("Error from HuggingFace:", err.message);
    res.status(500).json({
      reply: "Server issue. Please try again later."
    });
  }
});

export const api = functions.https.onRequest(app);
