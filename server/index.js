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

// Health Check Endpoint
app.get('/', (req, res) => {
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Akila Payment Backend Server running on port ${PORT}`);
});
