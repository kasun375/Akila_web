# Akila Com Maths LMS - Payment Backend Server

Node.js Express backend server for securely handling Stripe PaymentIntents on **Render.com**.

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
   Server will start at `http://localhost:3000`.

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
6. Deploy! Render will give you a live HTTPS domain like `https://akila-maths-payment-server.onrender.com`.
