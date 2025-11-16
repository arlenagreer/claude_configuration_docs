#!/usr/bin/env node

/**
 * Chrome DevTools Protocol REST API Server
 * Exposes CDP browser automation via HTTP REST API
 */

const express = require('express');
const puppeteer = require('puppeteer-core');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

let browser = null;
let page = null;

// Initialize browser connection on startup
async function initBrowser() {
  const browserHost = process.env.BROWSER_HOST || 'chrome-devtools-browser';
  const browserPort = process.env.BROWSER_PORT || '3000';

  browser = await puppeteer.connect({
    browserWSEndpoint: `ws://${browserHost}:${browserPort}`
  });

  const pages = await browser.pages();
  page = pages.length > 0 ? pages[0] : await browser.newPage();

  console.log('Browser connected successfully');
}

// Ensure browser is ready, reconnect if needed
async function ensureBrowser() {
  if (!browser || !browser.isConnected() || !page) {
    console.log('Browser not ready, reconnecting...');
    await initBrowser();
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'Running',
    browserReady: !!(browser && browser.isConnected() && page)
  });
});

// Navigate to URL
app.post('/navigate', async (req, res) => {
  try {
    await ensureBrowser();
    const { url, waitUntil = 'load', timeout = 30000 } = req.body;

    if (!url) {
      return res.status(400).json({ error: 'URL is required' });
    }

    const response = await page.goto(url, {
      waitUntil,
      timeout
    });

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

    const result = await page.evaluate((expr) => {
      return eval(expr);
    }, expression);

    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Click element
app.post('/click', async (req, res) => {
  try {
    await ensureBrowser();
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
    await ensureBrowser();
    const { selector, value, timeout = 30000 } = req.body;

    if (!selector || value === undefined) {
      return res.status(400).json({ error: 'Selector and value are required' });
    }

    await page.type(selector, value, { timeout });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Wait for selector
app.post('/wait', async (req, res) => {
  try {
    await ensureBrowser();
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
    await ensureBrowser();
    const content = await page.content();
    res.json({ success: true, content });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get page title
app.get('/title', async (req, res) => {
  try {
    await ensureBrowser();
    const title = await page.title();
    res.json({ success: true, title });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get console logs
app.get('/console', async (req, res) => {
  try {
    await ensureBrowser();

    const logs = [];
    page.on('console', msg => {
      logs.push({
        type: msg.type(),
        text: msg.text(),
        timestamp: Date.now()
      });
    });

    res.json({ success: true, logs });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get network requests
app.get('/network', async (req, res) => {
  try {
    await ensureBrowser();

    const requests = [];
    page.on('request', request => {
      requests.push({
        url: request.url(),
        method: request.method(),
        headers: request.headers(),
        timestamp: Date.now()
      });
    });

    res.json({ success: true, requests });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Close browser connection
app.post('/close', async (req, res) => {
  try {
    if (page) await page.close();
    if (browser) await browser.disconnect();
    page = null;
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
  console.log(`CDP API Server listening on port ${PORT}`);
  try {
    await initBrowser();
  } catch (error) {
    console.error('Failed to connect to browser:', error.message);
    console.log('Server will retry connection on first request');
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, disconnecting from browser...');
  if (browser) await browser.disconnect();
  process.exit(0);
});
