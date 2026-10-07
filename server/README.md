# Akila Com Maths LMS - Full Stack Server (Flutter Web + Payment Backend)

Node.js Express backend server that serves the **Flutter Web frontend app** and securely handles Stripe PaymentIntents on **Render.com**.

---

## 📦 How to Include Flutter Web App in Server

To open your web app when visiting the Render URL:

1. **Build the Flutter Web App:**
   ```bash
   flutter build web --release
   ```

2. **Copy Built Files to Server Public Directory:**
   Copy all contents of `build/web/` into `server/public/`.
   - On Windows PowerShell:
     ```powershell
     xcopy /E /I /Y ..\build\web server\public
     ```
   - On macOS / Linux:
     ```bash
     mkdir -p server/public && cp -r build/web/* server/public/
     ```

3. Commit and push the `server/public/` folder to GitHub.

---

## 🚀 Local Setup & Testing

1. Install dependencies:
   ```bash
   cd server
   npm install
   ```

2. Start server locally:
   ```bash
   npm start
   ```
   Open `http://localhost:3000` in your browser. The Flutter Web App will open!

---

## ☁️ Deploying to Render.com

1. Go to **[dashboard.render.com](https://dashboard.render.com)**.
2. Click **New +** -> **Web Service**.
3. Connect your repository (`kasun375/Akila_web`).
4. Set settings:
   - **Root Directory**: `server`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node index.js`
5. Add Environment Variable:
   - `STRIPE_SECRET_KEY` = your live Stripe secret key (`sk_live_...`)
6. Deploy! Render will give you a live HTTPS domain (e.g. `https://akila-maths-lms.onrender.com`).
7. When you open your Render URL in the browser, your **Flutter Web App** will launch immediately!

