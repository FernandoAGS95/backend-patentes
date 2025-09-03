import express from "express";
import multer from "multer";
import { spawn } from "child_process";
import path from "path";
import cors from "cors";

const app = express();

// 🔥 CORS para permitir requests desde Vercel
app.use(cors({
  origin: [
    'https://frontend-patentes-h77nebs0w.vercel.app/',  // Cambiar por tu URL de Vercel
    'http://localhost:3000',
    'http://localhost:5173'
  ]
}));

// Configuración de Multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + ext);
  },
});

const upload = multer({ storage });

// Ruta de health check
app.get("/", (req, res) => {
  res.json({ 
    status: "OK", 
    message: "Backend de detección de patentes funcionando",
    timestamp: new Date().toISOString()
  });
});

app.post("/api/detect", upload.single("image"), (req, res) => {
  const imagePath = req.file.path;

  const py = spawn("python", ["detect.py", imagePath]);

  let data = "";

  py.stdout.on("data", (chunk) => {
    const str = chunk.toString();
    console.log("STDOUT Python:", str);
    data += str;
  });

  py.stderr.on("data", (chunk) => {
    console.error("STDERR Python:", chunk.toString());
  });

  py.on("close", () => {
    try {
      console.log("Datos recibidos de Python:", data);
      const result = JSON.parse(data);
      res.json(result);
    } catch (err) {
      console.error("Error parseando JSON:", err);
      res.json({ plate: "ERROR_PARSING" });
    }
  });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`✅ Backend corriendo en puerto ${PORT}`);
});