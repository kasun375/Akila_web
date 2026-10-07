const express = require('express');
const cors = require('cors');
require('dotenv').config();

const stripeKey = process.env.STRIPE_SECRET_KEY;
if (!stripeKey) {
  console.warn("⚠️ STRIPE_SECRET_KEY environment variable is not set. Please add it in Render dashboard or local .env file.");
}

const stripe = require('stripe')(stripeKey || 'sk_test_placeholder');

const app = express();

// Enable CORS for Flutter Web frontend
app.use(cors({ origin: '*' }));
app.use(express.json());

const path = require('path');
const fs = require('fs');

// Candidate static paths for Flutter Web app
const candidatePaths = [
  path.join(__dirname, 'public'),
  path.join(__dirname, '../build/web'),
  path.join(process.cwd(), 'server/public'),
  path.join(process.cwd(), 'build/web'),
];

let staticPath = candidatePaths.find((p) => fs.existsSync(path.join(p, 'index.html')));

if (staticPath) {
  console.log(`📁 Serving Flutter Web App from: ${staticPath}`);
  app.use(express.static(staticPath));
} else {
  console.warn("⚠️ Flutter Web build index.html not found in any standard path.");
}

// Health Check Endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'Akila Com Maths LMS Payment Backend Server',
    timestamp: new Date().toISOString(),
  });
});

// Create Stripe Payment Intent Endpoint
app.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency = 'lkr', studentId, classId, className, studentEmail, month } = req.body;

    if (!amount || isNaN(amount) || amount <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid amount. Amount must be a positive number.',
      });
    }

    // Amount in smallest unit (e.g., LKR integer cents math)
    const amountInCents = Math.round(Number(amount) * 100);

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: (currency || 'lkr').toLowerCase(),
      description: `Class Fee: ${className || 'Maths Class'} - ${month || 'Current Month'}`,
      receipt_email: studentEmail || undefined,
      metadata: {
        studentId: String(studentId || 'N/A'),
        classId: String(classId || 'N/A'),
        className: String(className || 'N/A'),
        month: String(month || 'N/A'),
      },
    });

    return res.status(200).json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
    });
  } catch (error) {
    console.error('Error creating payment intent:', error);
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to create payment intent',
    });
  }
});

// Verify Payment Status Endpoint
app.get('/verify-payment/:paymentIntentId', async (req, res) => {
  try {
    const { paymentIntentId } = req.params;
    if (!paymentIntentId) {
      return res.status(400).json({ success: false, error: 'Payment Intent ID is required' });
    }

    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    return res.status(200).json({
      success: true,
      status: paymentIntent.status, // e.g., 'succeeded', 'requires_payment_method'
      amount: paymentIntent.amount / 100,
      currency: paymentIntent.currency,
      metadata: paymentIntent.metadata,
    });
  } catch (error) {
    console.error('Error verifying payment intent:', error);
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to verify payment intent',
    });
  }
});

// Wildcard Fallback Route for Single Page Application (Flutter Web)
app.get('*', (req, res) => {
  if (staticPath && fs.existsSync(path.join(staticPath, 'index.html'))) {
    res.sendFile(path.join(staticPath, 'index.html'));
  } else {
    res.status(200).json({
      status: 'online',
      service: 'Akila Com Maths LMS Payment Backend Server',
      message: 'Web app build not found in server/public. Run `flutter build web` and copy `build/web` contents to `server/public`.',
      timestamp: new Date().toISOString(),
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Akila Payment Backend Server running on port ${PORT}`);
});
