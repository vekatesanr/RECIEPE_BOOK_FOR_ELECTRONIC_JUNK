/**
 * USAGE EXAMPLES - Firebase Upload Service
 * Examples for integrating with Flutter app and backend
 */

// =========================================
// EXAMPLE 1: Basic Component Upload
// =========================================

import { processComponentUpload } from './uploadService.js';

async function basicExample() {
  try {
    const result = await processComponentUpload(
      '/path/to/component-image.jpg',
      {
        component_name: 'Motherboard',
        origin: 'E-waste facility A',
        destination_project: 'Refurbishment Program',
        time_range: '2024-01-01 to 2024-03-29',
        dismantle_difficulty: 'hard',
        user_description: 'Damaged motherboard, needs cleaning',
      }
    );

    console.log('Upload successful!');
    console.log('Document ID:', result.docId);
    console.log('Image URL:', result.imageUrl);
  } catch (error) {
    console.error('Upload failed:', error.message);
  }
}

// =========================================
// EXAMPLE 2: Handle Upload with Error Recovery
// =========================================

async function uploadWithRetry(imageURI, specs, maxRetries = 3) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      attempt++;
      console.log(`Upload attempt ${attempt}/${maxRetries}...`);

      const result = await processComponentUpload(imageURI, specs);
      return result;
    } catch (error) {
      console.error(`Attempt ${attempt} failed:`, error.code);

      if (error.code === 'NETWORK_TIMEOUT' && attempt < maxRetries) {
        // Exponential backoff
        const delayMs = Math.pow(2, attempt) * 1000;
        console.log(`Retrying in ${delayMs}ms...`);
        await new Promise(resolve => setTimeout(resolve, delayMs));
      } else {
        throw error;
      }
    }
  }

  throw new Error('Max retries exceeded');
}

// Usage
try {
  const result = await uploadWithRetry(
    '/path/to/image.jpg',
    {
      component_name: 'GPU Card',
      origin: 'University Lab',
      destination_project: 'Mining Components Recovery',
      time_range: '2024-Q1',
      dismantle_difficulty: 'medium',
    }
  );
  console.log('Uploaded:', result.docId);
} catch (error) {
  console.error('Upload failed after retries:', error.message);
}

// =========================================
// EXAMPLE 3: Batch Upload Multiple Components
// =========================================

async function batchUpload(components) {
  const results = [];
  const errors = [];

  for (const component of components) {
    try {
      console.log(`Uploading ${component.specs.component_name}...`);
      const result = await processComponentUpload(
        component.imageURI,
        component.specs
      );
      results.push({
        status: 'success',
        component: component.specs.component_name,
        docId: result.docId,
      });
    } catch (error) {
      errors.push({
        status: 'failed',
        component: component.specs.component_name,
        error: error.message,
      });
    }
  }

  return { results, errors };
}

// Usage
const components = [
  {
    imageURI: '/images/motherboard.jpg',
    specs: {
      component_name: 'Motherboard',
      origin: 'Facility A',
      destination_project: 'Project X',
      time_range: '2024-Q1',
      dismantle_difficulty: 'hard',
    },
  },
  {
    imageURI: '/images/ram.jpg',
    specs: {
      component_name: 'RAM 8GB',
      origin: 'Facility B',
      destination_project: 'Project Y',
      time_range: '2024-Q1',
      dismantle_difficulty: 'easy',
    },
  },
];

const batchResult = await batchUpload(components);
console.log('Batch upload results:', batchResult);

// =========================================
// EXAMPLE 4: Upload with Mismatch Detection
// =========================================

import { getComponent, updateVerificationStatus } from './uploadService.js';

async function uploadWithMismatchCheck(imageURI, aiLabel, userDescription, specs) {
  // Detect mismatch
  const hasMismatch =
    (userDescription.toLowerCase().includes('damaged') ||
      userDescription.toLowerCase().includes('burnt')) &&
    aiLabel.toLowerCase() === 'new';

  console.log(`Mismatch detected: ${hasMismatch}`);

  const result = await processComponentUpload(imageURI, {
    ...specs,
    user_description: userDescription,
    mismatch_flag: hasMismatch,
  });

  // Mark for manual review if mismatch
  if (hasMismatch) {
    await updateVerificationStatus(result.docId, 'pending');
    console.log('Component marked for manual review');
  }

  return result;
}

// Usage
const mismatchResult = await uploadWithMismatchCheck(
  '/path/to/component.jpg',
  'new', // AI label
  'Component is burnt and damaged', // User description
  {
    component_name: 'Unknown Component',
    origin: 'Facility',
    destination_project: 'Testing',
    time_range: '2024',
    dismantle_difficulty: 'medium',
  }
);

// =========================================
// EXAMPLE 5: Flutter Integration Helper
// =========================================

// This is what the Flutter app would send:

/*
// In analysis_screen.dart
Future<void> _sendToBackend() async {
  try {
    const backendUrl = 'http://your-server.com:3000';
    
    final uploadResponse = await http.post(
      Uri.parse('$backendUrl/api/components/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'localImageURI': _selectedImage.path,
        'specs': {
          'component_name': _descController.text,
          'origin': _originController.text,
          'destination_project': _projectController.text,
          'time_range': _timeController.text,
          'dismantle_difficulty': 'medium',
          'user_description': _descController.text,
          'mismatch_flag': _mismatch,
        }
      }),
    );

    if (uploadResponse.statusCode == 201) {
      final data = jsonDecode(uploadResponse.body);
      final docId = data['data']['docId'];
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded with ID: $docId')),
      );
    } else if (uploadResponse.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Check credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (uploadResponse.statusCode == 503) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network timeout. Check your connection.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
*/

// =========================================
// EXAMPLE 6: Query and Display Components
// =========================================

import { getComponentsByStatus } from './uploadService.js';

async function displayPendingComponents() {
  try {
    const pendingComponents = await getComponentsByStatus('pending', 10);

    console.log(`Found ${pendingComponents.length} pending components:\n`);

    pendingComponents.forEach(comp => {
      console.log(`- ${comp.component_name}`);
      console.log(`  ID: ${comp.docId}`);
      console.log(`  Status: ${comp.verification_status}`);
      console.log(`  Difficulty: ${comp.dismantle_difficulty}`);
      console.log(`  Origin: ${comp.origin}`);
      console.log('');
    });

    return pendingComponents;
  } catch (error) {
    console.error('Error fetching components:', error.message);
  }
}

// =========================================
// EXAMPLE 7: Admin Verification Workflow
// =========================================

async function reviewAndVerifyComponent(docId, adminDecision) {
  try {
    // Get component details
    const component = await getComponent(docId);

    console.log(`Reviewing: ${component.component_name}`);
    console.log(`Current status: ${component.verification_status}`);
    console.log(`Mismatch flag: ${component.mismatch_flag}`);

    // Admin verifies or rejects
    const finalStatus = adminDecision === 'approve' ? 'verified' : 'rejected';
    await updateVerificationStatus(docId, finalStatus);

    console.log(`Component ${finalStatus} by admin`);

    return {
      docId,
      component_name: component.component_name,
      final_status: finalStatus,
      reviewed_at: new Date().toISOString(),
    };
  } catch (error) {
    console.error('Review error:', error.message);
  }
}

// Usage
const adminReview = await reviewAndVerifyComponent('abc123def456', 'approve');
console.log('Admin review complete:', adminReview);

// =========================================
// EXAMPLE 8: Error Handling Best Practices
// =========================================

async function uploadWithFullErrorHandling(imageURI, specs) {
  try {
    const result = await processComponentUpload(imageURI, specs);
    return { success: true, data: result };
  } catch (error) {
    // Handle specific error types
    switch (error.code) {
      case 'PERMISSION_DENIED':
        console.error('🔐 Firebase credentials issue');
        console.error('Action: Check Firebase service account and security rules');
        return { success: false, code: 'AUTH_ERROR', message: error.message };

      case 'NETWORK_TIMEOUT':
        console.error('🌐 Network connectivity issue');
        console.error('Action: Check internet connection and retry');
        return { success: false, code: 'NETWORK_ERROR', message: error.message };

      case 'FILE_NOT_FOUND':
        console.error('📁 Image file not found');
        console.error('Action: Check if file path is correct');
        return { success: false, code: 'FILE_ERROR', message: error.message };

      case 'UPLOAD_FAILED':
      default:
        console.error('❌ Upload failed');
        console.error('Details:', error.originalError);
        return { success: false, code: 'UNKNOWN_ERROR', message: error.message };
    }
  }
}

// Usage
const uploadResult = await uploadWithFullErrorHandling(
  '/path/to/image.jpg',
  {
    component_name: 'Test',
    origin: 'Test',
    destination_project: 'Test',
    time_range: '2024',
    dismantle_difficulty: 'easy',
  }
);

console.log(uploadResult);

export {
  basicExample,
  uploadWithRetry,
  batchUpload,
  uploadWithMismatchCheck,
  displayPendingComponents,
  reviewAndVerifyComponent,
  uploadWithFullErrorHandling,
};
