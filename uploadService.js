/**
 * Firebase v10 Upload Service for Electronics Database
 * Handles image upload to Firebase Storage and Firestore metadata creation
 * Region: asia-south1 (Mumbai)
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getStorage } from 'firebase-admin/storage';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as fs from 'fs';
import * as path from 'path';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';

let storage = null;
let firestore = null;

// Initialize on demand - export this public function
export function initializeFirebase() {
  try {
    let serviceAccount;
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT || path.join(__dirname, 'firebase-service-account.json');
    
    if (fs.existsSync(serviceAccountPath)) {
      serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
    } else {
      console.warn('[UPLOAD_SERVICE] 🔴 Firebase service account file NOT FOUND!');
      console.warn('[UPLOAD_SERVICE] 📝 Instructions:');
      console.warn('[UPLOAD_SERVICE]   1. Go to Firebase Console → Settings → Service Accounts');
      console.warn('[UPLOAD_SERVICE]   2. Click "Generate New Private Key"');
      console.warn('[UPLOAD_SERVICE]   3. Save the JSON file as: firebase-service-account.json');
      console.warn('[UPLOAD_SERVICE]   4. Place it in:', __dirname);
      throw new Error('Firebase service account not found');
    }

    const app = initializeApp({
      credential: cert(serviceAccount),
      storageBucket: process.env.STORAGE_BUCKET || 'your-project.appspot.com',
    });

    const storageInstance = getStorage(app);
    const firestoreInstance = getFirestore(app);

    // Set Firestore region to asia-south1 (Mumbai)
    firestoreInstance.settings({ preferredLocation: 'asia-south1' });

    // Store globally
    storage = storageInstance;
    firestore = firestoreInstance;

    console.log('[UPLOAD_SERVICE] ✅ Firebase initialized successfully');
    return app;
  } catch (error) {
    console.error('[UPLOAD_SERVICE] ❌ Firebase initialization failed:', error.message);
    throw error;
  }
}

// DO NOT initialize on import - will be called from server.js

/**
 * Process Component Upload - Main Function
 * @param {string} localImageURI - Local file path or URI to the image
 * @param {Object} specs - Specifications object
 * @param {string} specs.component_name - Name of the component
 * @param {string} specs.origin - Origin/source of the component
 * @param {string} specs.destination_project - Destination project name
 * @param {string} specs.time_range - Time range information
 * @param {string} specs.dismantle_difficulty - Difficulty level (easy/medium/hard)
 * @param {string} [specs.user_description] - Optional user description
 * @returns {Promise<Object>} Document reference and metadata
 */
export async function processComponentUpload(localImageURI, specs) {
  if (!storage || !firestore) {
    throw new Error('Firebase not initialized. Upload service is not available.');
  }

  let bucket = null;
  let downloadURL = null;
  let docId = null;

  try {
    // Validate inputs
    if (!localImageURI || typeof localImageURI !== 'string') {
      throw new Error('Invalid localImageURI provided');
    }

    if (!specs || typeof specs !== 'object') {
      throw new Error('Invalid specs object');
    }

    if (!specs.component_name) {
      throw new Error('component_name is required in specs');
    }

    console.log(`[UPLOAD_SERVICE] Starting upload for component: ${specs.component_name}`);

    // STEP 1: Upload Image to Firebase Storage
    console.log(`[UPLOAD_SERVICE] Step 1: Uploading image to Firebase Storage...`);
    
    bucket = storage.bucket();
    const fileName = `junk_library/${Date.now()}_${path.basename(localImageURI)}`;
    const file = bucket.file(fileName);

    // Check if file exists locally
    if (!fs.existsSync(localImageURI)) {
      throw new Error(`Local image file not found: ${localImageURI}`);
    }

    // Upload file with metadata
    await bucket.upload(localImageURI, {
      destination: fileName,
      metadata: {
        contentType: 'image/jpeg',
        metadata: {
          component: specs.component_name,
          uploadedAt: new Date().toISOString(),
        },
      },
    });

    console.log(`[UPLOAD_SERVICE] Image uploaded successfully: ${fileName}`);

    // STEP 2: Get Download URL
    console.log(`[UPLOAD_SERVICE] Step 2: Retrieving download URL...`);
    
    try {
      // Make file public and get download URL
      await file.makePublic();
      downloadURL = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    } catch (urlError) {
      console.warn(`[UPLOAD_SERVICE] Could not make file public, generating signed URL...`);
      const [signedURL] = await file.getSignedUrl({
        version: 'v4',
        action: 'read',
        expires: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
      });
      downloadURL = signedURL;
    }

    console.log(`[UPLOAD_SERVICE] Download URL obtained: ${downloadURL.substring(0, 50)}...`);

    // STEP 3: Create Firestore Document
    console.log(`[UPLOAD_SERVICE] Step 3: Creating Firestore document...`);

    const componentData = {
      // Required fields
      imageUrl: downloadURL,
      component_name: specs.component_name,
      verification_status: 'pending', // default value
      created_at: Timestamp.now(), // Server timestamp
      dismantle_difficulty: specs.dismantle_difficulty || 'medium',

      // Additional metadata from specs
      origin: specs.origin || '',
      destination_project: specs.destination_project || '',
      time_range: specs.time_range || '',
      user_description: specs.user_description || '',

      // System metadata
      storage_path: fileName,
      upload_timestamp: Timestamp.now(),
      region: 'asia-south1',
      status: 'active',
      mismatch_flag: specs.mismatch_flag || false,
    };

    const docRef = await firestore.collection('components').add(componentData);
    docId = docRef.id;

    console.log(`[UPLOAD_SERVICE] Firestore document created successfully: ${docId}`);

    return {
      success: true,
      docId,
      imageUrl: downloadURL,
      component_name: specs.component_name,
      verification_status: 'pending',
      created_at: new Date().toISOString(),
      dismantle_difficulty: specs.dismantle_difficulty,
    };
  } catch (error) {
    console.error(`[UPLOAD_SERVICE] Error during upload process:`, error);

    // Specific error handling for mobile environments
    if (error.code === 'auth/invalid-api-key' || error.message.includes('Permission denied')) {
      throw {
        code: 'PERMISSION_DENIED',
        message: 'Permission Denied: Unable to upload or save data. Check Firebase credentials and security rules.',
        originalError: error.message,
      };
    }

    if (
      error.code === 'ENOTFOUND' ||
      error.message.includes('ECONNREFUSED') ||
      error.message.includes('timeout') ||
      error.message.includes('Network')
    ) {
      throw {
        code: 'NETWORK_TIMEOUT',
        message: 'Network Timeout: Please check your connection and try again.',
        originalError: error.message,
      };
    }

    if (error.code === 'ENOENT' || error.message.includes('not found')) {
      throw {
        code: 'FILE_NOT_FOUND',
        message: `File not found: ${localImageURI}`,
        originalError: error.message,
      };
    }

    // Generic error handling
    throw {
      code: 'UPLOAD_FAILED',
      message: 'Upload failed. Please try again.',
      originalError: error.message,
      details: error,
    };
  }
}

/**
 * Retrieve Component from Firestore
 * @param {string} docId - Document ID
 * @returns {Promise<Object>} Component data
 */
export async function getComponent(docId) {
  if (!firestore) throw new Error('Firebase not initialized');
  try {
    const doc = await firestore.collection('components').doc(docId).get();
    if (!doc.exists) {
      throw new Error(`Component not found: ${docId}`);
    }
    return { docId: doc.id, ...doc.data() };
  } catch (error) {
    console.error(`[UPLOAD_SERVICE] Error retrieving component:`, error);
    throw error;
  }
}

/**
 * Update Component Verification Status
 * @param {string} docId - Document ID
 * @param {string} status - New status (pending/verified/rejected)
 * @returns {Promise<void>}
 */
export async function updateVerificationStatus(docId, status) {
  if (!firestore) throw new Error('Firebase not initialized');
  try {
    if (!['pending', 'verified', 'rejected'].includes(status)) {
      throw new Error(`Invalid status: ${status}`);
    }

    await firestore.collection('components').doc(docId).update({
      verification_status: status,
      updated_at: Timestamp.now(),
    });

    console.log(`[UPLOAD_SERVICE] Component ${docId} status updated to: ${status}`);
  } catch (error) {
    console.error(`[UPLOAD_SERVICE] Error updating status:`, error);
    throw error;
  }
}

/**
 * Query Components by Verification Status
 * @param {string} status - Status to filter by
 * @param {number} limit - Result limit (default 20)
 * @returns {Promise<Array>} Array of components
 */
export async function getComponentsByStatus(status, limit = 20) {
  if (!firestore) throw new Error('Firebase not initialized');
  try {
    const query = await firestore
      .collection('components')
      .where('verification_status', '==', status)
      .orderBy('created_at', 'desc')
      .limit(limit)
      .get();

    return query.docs.map(doc => ({ docId: doc.id, ...doc.data() }));
  } catch (error) {
    console.error(`[UPLOAD_SERVICE] Error querying components:`, error);
    throw error;
  }
}

/**
 * Delete Component and Associated Storage
 * @param {string} docId - Document ID
 * @returns {Promise<void>}
 */
export async function deleteComponent(docId) {
  if (!storage || !firestore) throw new Error('Firebase not initialized');
  try {
    const doc = await firestore.collection('components').doc(docId).get();

    if (!doc.exists) {
      throw new Error(`Component not found: ${docId}`);
    }

    const storagePath = doc.data().storage_path;

    // Delete from Firestore
    await firestore.collection('components').doc(docId).delete();

    // Delete from Storage
    if (storagePath) {
      await storage.bucket().file(storagePath).delete().catch(err => {
        console.warn(`[UPLOAD_SERVICE] Could not delete storage file: ${storagePath}`, err);
      });
    }

    console.log(`[UPLOAD_SERVICE] Component ${docId} deleted successfully`);
  } catch (error) {
    console.error(`[UPLOAD_SERVICE] Error deleting component:`, error);
    throw error;
  }
}

export default {
  processComponentUpload,
  getComponent,
  updateVerificationStatus,
  getComponentsByStatus,
  deleteComponent,
};