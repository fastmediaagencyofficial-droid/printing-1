import nodemailer, { Transporter } from 'nodemailer';
import { logger } from '../utils/logger';

let transporter: Transporter;

const getTransporter = (): Transporter => {
  if (transporter) return transporter;
  transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,          // TLS via STARTTLS
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS, // Gmail App Password
    },
  });
  return transporter;
};

export interface MailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export const sendEmail = async (opts: MailOptions): Promise<void> => {
  try {
    const info = await getTransporter().sendMail({
      from: `"Fast Printing & Packaging" <${process.env.EMAIL_USER}>`,
      to: opts.to,
      subject: opts.subject,
      html: opts.html,
      text: opts.text,
    });
    logger.info(`Email sent → ${opts.to} (msgId: ${info.messageId})`);
  } catch (err) {
    logger.error('Email send failed:', err);
    // Don't throw — email failure should not break the main flow
  }
};

// ─── TEMPLATES ───────────────────────────────────────────────────────────────
const base = (body: string) => `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
<style>
  body { font-family: Arial, sans-serif; color: #222; margin: 0; padding: 0; background: #f5f5f5; }
  .wrap { max-width: 600px; margin: 30px auto; background: #fff; border-radius: 10px; overflow: hidden; }
  .header { background: #C91A20; padding: 28px 32px; }
  .header h1 { color: #fff; margin: 0; font-size: 22px; }
  .header p  { color: rgba(255,255,255,.75); margin: 4px 0 0; font-size: 13px; }
  .body   { padding: 28px 32px; }
  .box    { background: #f9f9f9; border: 1px solid #e0e0e0; border-radius: 8px; padding: 16px 20px; margin: 16px 0; }
  .footer { padding: 18px 32px; font-size: 11px; color: #999; border-top: 1px solid #eee; }
  .badge  { display: inline-block; background: #C91A20; color: #fff; border-radius: 4px; padding: 3px 10px; font-size: 12px; }
</style>
</head>
<body><div class="wrap">
  <div class="header">
    <h1>🖨️ Fast Printing &amp; Packaging</h1>
    <p>XFast Group · Lahore, Pakistan</p>
  </div>
  <div class="body">${body}</div>
  <div class="footer">
    101A J1 Block, Valencia Town, Main Defence Road, Lahore |
    <a href="mailto:xfastgroup001@gmail.com">xfastgroup001@gmail.com</a> |
    WhatsApp: +92 325 2467463
  </div>
</div></body></html>`;

export const orderConfirmationHtml = (
  orderId: string,
  customerName: string,
  total: number,
  method: string
) =>
  base(`
    <h2>Order Placed! 🎉</h2>
    <p>Hi <strong>${customerName}</strong>,</p>
    <p>Your order has been received. Please complete your payment to start production.</p>
    <div class="box">
      <p><strong>Order ID:</strong> <span class="badge">${orderId}</span></p>
      <p><strong>Amount Due:</strong> PKR ${total.toLocaleString()}</p>
      <p><strong>Payment Method:</strong> ${method === 'JAZZCASH' ? 'JazzCash' : 'EasyPaisa'}</p>
      <p><strong>Status:</strong> Awaiting Payment</p>
    </div>
    <p>Transfer the exact amount and upload your payment screenshot in the app. We verify within <strong>1–2 hours</strong>.</p>
    <p>Questions? WhatsApp us at <strong>+92 325 2467463</strong>.</p>
  `);

export const paymentVerifiedHtml = (orderId: string, customerName: string) =>
  base(`
    <h2>Payment Verified ✅</h2>
    <p>Hi <strong>${customerName}</strong>,</p>
    <p>Your payment for order <span class="badge">${orderId}</span> has been verified.</p>
    <p>Your order is now <strong>in production</strong>. We'll notify you once it ships.</p>
  `);

export const quoteReceivedHtml = (name: string, product: string, quoteId: string) =>
  base(`
    <h2>Quote Request Received 📋</h2>
    <p>Hi <strong>${name}</strong>,</p>
    <p>We've received your quote request for <strong>${product}</strong>.</p>
    <div class="box">
      <p><strong>Quote Reference:</strong> <span class="badge">${quoteId}</span></p>
      <p>Our team will review your requirements and send you a detailed quote within <strong>24 hours</strong>.</p>
    </div>
    <p>For urgent inquiries: <strong>+92 325 2467463</strong> (WhatsApp)</p>
  `);

export const contactAutoReplyHtml = (name: string) =>
  base(`
    <h2>Message Received 📩</h2>
    <p>Hi <strong>${name}</strong>,</p>
    <p>Thanks for reaching out! We've received your message and will get back to you within <strong>24 hours</strong>.</p>
    <p>Need a faster response? Chat with us on WhatsApp: <strong>+92 325 2467463</strong></p>
  `);

export const adminNewOrderHtml = (orderId: string, userName: string, email: string, total: number, method: string) =>
  base(`
    <h2>🆕 New Order: ${orderId}</h2>
    <div class="box">
      <p><strong>Customer:</strong> ${userName} (${email})</p>
      <p><strong>Total:</strong> PKR ${total.toLocaleString()}</p>
      <p><strong>Payment:</strong> ${method}</p>
    </div>
    <p>Log in to the admin panel to manage this order.</p>
  `);
