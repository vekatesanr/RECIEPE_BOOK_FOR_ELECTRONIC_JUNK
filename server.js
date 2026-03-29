/**
 * Express Server - Firebase Upload API
 * Endpoint for component uploads from mobile app
 */

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Lazy import - Only import upload service when needed
let uploadServiceReady = false;
let uploadService = null;

async function loadUploadService() {
  if (uploadServiceReady) return uploadService;
  try {
    uploadService = await import('./uploadService.js');
    uploadServiceReady = true;
    return uploadService;
  } catch (error) {
    console.error('[SERVER] ❌ Failed to load upload service:', error.message);
    throw error;
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: uploadServiceReady ? 'ok' : 'Firebase not configured',
    firebase_ready: uploadServiceReady,
    timestamp: new Date().toISOString(),
    message: uploadServiceReady ? 'Service ready' : 'Configure firebase-service-account.json to enable uploads'
  });
});

/**
 * POST /api/components/upload
 * Upload component image and create metadata
 */
app.post('/api/components/upload', async (req, res) => {
  try {
    if (!uploadServiceReady) {
      return res.status(503).json({
        success: false,
        error: 'Firebase not configured',
        message: 'upload service is not ready. Check server logs for Firebase setup instructions.',
      });
    }

    const { localImageURI, specs } = req.body;

    if (!localImageURI || !specs) {
      return res.status(400).json({
        error: 'Missing required fields: localImageURI and specs',
      });
    }

    const result = await uploadService.processComponentUpload(localImageURI, specs);

    res.status(201).json({
      success: true,
      data: result,
      message: 'Component uploaded successfully',
    });
  } catch (error) {
    console.error('[SERVER] Upload error:', error);

    const statusCode = error.code === 'PERMISSION_DENIED' ? 403 : error.code === 'NETWORK_TIMEOUT' ? 503 : 400;

    res.status(statusCode).json({
      success: false,
      error: error.message || 'Upload failed',
      code: error.code || 'UNKNOWN_ERROR',
    });
  }
});

/**
 * GET /api/components/:docId
 * Retrieve component by ID
 */
app.get('/api/components/:docId', async (req, res) => {
  try {
    if (!uploadServiceReady) {
      return res.status(503).json({
        success: false,
        error: 'Firebase not configured',
      });
    }

    const { docId } = req.params;
    const component = await uploadService.getComponent(docId);

    res.json({
      success: true,
      data: component,
    });
  } catch (error) {
    console.error('[SERVER] Get component error:', error);
    res.status(404).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * PATCH /api/components/:docId/verify
 * Update verification status
 */
app.patch('/api/components/:docId/verify', async (req, res) => {
  try {
    if (!uploadServiceReady) {
      return res.status(503).json({
        success: false,
        error: 'Firebase not configured',
      });
    }

    const { docId } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        error: 'Status field is required',
      });
    }

    await uploadService.updateVerificationStatus(docId, status);

    res.json({
      success: true,
      message: `Component status updated to ${status}`,
    });
  } catch (error) {
    console.error('[SERVER] Update status error:', error);
    res.status(400).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/components
 * Query components by status
 */
app.get('/api/components', async (req, res) => {
  try {
    if (!uploadServiceReady) {
      return res.status(503).json({
        success: false,
        error: 'Firebase not configured',
      });
    }

    const { status = 'pending', limit = 20 } = req.query;
    const components = await uploadService.getComponentsByStatus(status, parseInt(limit));

    res.json({
      success: true,
      count: components.length,
      data: components,
    });
  } catch (error) {
    console.error('[SERVER] Query error:', error);
    res.status(400).json({
      success: false,
      error: error.message,
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('[SERVER] Unexpected error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// Initialize upload service on startup
loadUploadService()
  .then(() => {
    uploadServiceReady = true;
    console.log('[SERVER] ✅ Upload service initialized');
  })
  .catch(error => {
    console.error('[SERVER] ⚠️ Upload service NOT available:', error.message);
  });

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📍 Region: asia-south1 (Mumbai)`);
  console.log(`🔥 Storage Bucket: ${process.env.STORAGE_BUCKET || 'your-project.appspot.com'}`);
  console.log(`\n✓ Health Check: http://localhost:${PORT}/health`);
});
