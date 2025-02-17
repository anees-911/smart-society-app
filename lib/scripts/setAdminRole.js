const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(require('./firebase-admin-key.json')),
});

// Function to set custom claims
async function setAdminRole() {
  const adminEmail = 'admin@smartsociety.com'; // Predefined admin email

  try {
    // Fetch the user by email
    const user = await admin.auth().getUserByEmail(adminEmail);

    // Assign custom claims for admin role
    await admin.auth().setCustomUserClaims(user.uid, { role: 'admin' });

    console.log(`Admin role assigned to user: ${adminEmail}`);
  } catch (error) {
    console.error('Error assigning admin role:', error);
  }
}

// Run the function
setAdminRole();
