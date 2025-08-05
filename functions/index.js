
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.sendNotificationOnOrder = onDocumentCreated('Orders/{orderId}', async (event) => {
  const orderData = event.data.data();

  const makerId = orderData.makerId;
  const salesmanId = orderData.salesmanID;
  const db = getFirestore();

  // Fetch the maker's FCM token
  const makerDoc = await db.collection('users').doc(makerId).get();
  const fcmToken = makerDoc.data()?.fcmToken;

  if (!fcmToken) {
    console.log("No FCM token found for maker:", makerId);
    return;
  }

  // Fetch the salesman's name
  const salesmanDoc = await db.collection('users').doc(salesmanId).get();
  const salesmanName = salesmanDoc.data()?.name || "a salesman"; // fallback if name is missing

  const message = {
    token: fcmToken,
    notification: {
      title: 'New Order Received',
      body: `You have a new order from ${salesmanName}`,
    },
  };
 
  await getMessaging().send(message);
});



exports.notifyMakerOnOrderCancel = onDocumentUpdated('Orders/{orderId}', async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  // Only proceed if 'Cancel' changed from false to true
  if (!beforeData.Cancel && afterData.Cancel) {
    const db = getFirestore();
    const makerId = afterData.makerId;
    const salesmanId = afterData.salesmanID;

    // Get maker's FCM token
    const makerDoc = await db.collection('users').doc(makerId).get();
    const fcmToken = makerDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token found for maker:", makerId);
      return;
    }

    // Get salesman's name from users collection
    let salesmanName = 'Salesman';
    if (salesmanId) {
      const salesmanDoc = await db.collection('users').doc(salesmanId).get();
      if (salesmanDoc.exists) {
        salesmanName = salesmanDoc.data()?.name || salesmanName;
      }
    }

    const message = {
      token: fcmToken,
      notification: {
        title: 'Order Cancelled',
        body: `The order "${afterData.orderId}" was cancelled by ${salesmanName}.`,
      },
    };

    await getMessaging().send(message);
    console.log("Notification sent to maker:", makerId);
  }
});
