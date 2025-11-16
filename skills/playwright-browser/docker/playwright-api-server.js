#!/usr/bin/env node

/**
 * Playwright REST API Server
 * Exposes Playwright browser automation via HTTP REST API
 */

const express = require('express');
const { chromium } = require('playwright');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

let browser = null;
let context = null;
let page = null;

// Initialize browser on startup
async function initBrowser() {
  browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });
  context = await browser.newContext();
  page = await context.newPage();
  console.log('Browser initialized successfully');
}

// Ensure browser is ready, reinitialize if needed
async function ensureBrowser() {
  if (!page || !page.context() || !page.context().browser()) {
    console.log('Browser not ready, reinitializing...');
    await initBrowser();
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'Running', browserReady: !!(page && page.context && page.context()) });
});

// Navigate to URL
app.post('/navigate', async (req, res) => {
  try {
    await ensureBrowser();
    const { url, waitUntil = 'load', timeout = 30000 } = req.body;

    if (!url) {
      return res.status(400).json({ error: 'URL is required' });
    }

    const response = await page.goto(url, { waitUntil, timeout });
    res.json({
      success: true,
      url: page.url(),
      status: response.status()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Take screenshot
app.post('/screenshot', async (req, res) => {
  try {
    await ensureBrowser();
    const { fullPage = false, type = 'png', quality } = req.body;

    const options = { fullPage, type };
    if (type === 'jpeg' && quality) {
      options.quality = quality;
    }

    const screenshot = await page.screenshot(options);

    res.json({
      success: true,
      buffer: screenshot.toString('base64'),
      type
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Evaluate JavaScript
app.post('/evaluate', async (req, res) => {
  try {
    await ensureBrowser();
    const { expression } = req.body;

    if (!expression) {
      return res.status(400).json({ error: 'Expression is required' });
    }

    const result = await page.evaluate(expression);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Click element
app.post('/click', async (req, res) => {
  try {
    const { selector, timeout = 30000 } = req.body;

    if (!selector) {
      return res.status(400).json({ error: 'Selector is required' });
    }

    await page.click(selector, { timeout });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Fill input
app.post('/fill', async (req, res) => {
  try {
    const { selector, value, timeout = 30000 } = req.body;

    if (!selector || value === undefined) {
      return res.status(400).json({ error: 'Selector and value are required' });
    }

    await page.fill(selector, value, { timeout });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Wait for selector
app.post('/wait', async (req, res) => {
  try {
    const { selector, timeout = 30000 } = req.body;

    if (!selector) {
      return res.status(400).json({ error: 'Selector is required' });
    }

    await page.waitForSelector(selector, { timeout });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get page content
app.get('/content', async (req, res) => {
  try {
    const content = await page.content();
    res.json({ success: true, content });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get page title
app.get('/title', async (req, res) => {
  try {
    const title = await page.title();
    res.json({ success: true, title });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Close browser
app.post('/close', async (req, res) => {
  try {
    if (page) await page.close();
    if (context) await context.close();
    if (browser) await browser.close();
    page = null;
    context = null;
    browser = null;
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, '0.0.0.0', async () => {
  console.log(`Playwright API Server listening on port ${PORT}`);
  await initBrowser();
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, closing browser...');
  if (browser) await browser.close();
  process.exit(0);
});
