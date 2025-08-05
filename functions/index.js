
// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.sendNewOrderNotification = functions.firestore
//   .document('Orders/{orderId}')
//   .onCreate(async (snap, context) => {
//     const newOrder = snap.data();
//     const salesmanId = newOrder.salesmanID;

//     // Fetch the salesman's user document
//     const userDoc = await admin.firestore().collection('users').doc(salesmanId).get();
//     const fcmToken = userDoc.data()?.fcm_token;

//     if (!fcmToken) {
//       console.log(`No FCM token found for salesman ID: ${salesmanId}`);
//       return null;
//     }

//     // Prepare the notification
//     const message = {
//       notification: {
//         title: 'New Order Assigned',
//         body: `Order ID: ${newOrder.orderId} for ${newOrder.name}`,
//       },
//       token: fcmToken,
//     };

//     // Send push notification
//     try {
//       await admin.messaging().send(message);
//       console.log('Notification sent to:', salesmanId);
//     } catch (error) {
//       console.error('Error sending notification:', error);
//     }

//     return null;
//   });
const { onDocumentCreated } = require('firebase-functions/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.sendNotificationOnOrder = onDocumentCreated('orders/{orderId}', async (event) => {
  const orderData = event.data.data();

  const makerId = orderData.makerId;
  const db = getFirestore();
  
  // Get maker's FCM token
  const makerDoc = await db.collection('user').doc(makerId).get();
  const fcmToken = makerDoc.data()?.fcmToken;

  if (!fcmToken) {
    console.log("No FCM token found for maker:", makerId);
    return;
  }

  const message = {
    token: fcmToken,
    notification: {
      title: 'New Order Received',
      body: `You have a new order from ${orderData.salesmanName}`,
    },
  };

  await getMessaging().send(message);
});
