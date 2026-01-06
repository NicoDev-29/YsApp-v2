const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {onCall} = require('firebase-functions/v2/https');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

// Umbral de stock bajo (configurable)
const STOCK_THRESHOLD = 5;

/**
 * Cloud Function que se ejecuta cuando el stock de un producto cambia
 * Detecta si el stock bajo al umbral minimo y envia notificaciones push
 */
exports.checkLowStock = onDocumentUpdated('productos/{productId}', async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();
  const productId = event.params.productId;
  
  // Solo procesar si el stock cambio
  if (beforeData.stock === afterData.stock) {
    console.log('Stock no cambio, saliendo...');
    return null;
  }
  
  const previousStock = beforeData.stock;
  const currentStock = afterData.stock;
  
  console.log(`Producto: ${afterData.nombre}`);
  console.log(`Stock anterior: ${previousStock} -> actual: ${currentStock}`);
  
  // Detectar si el stock bajo Y ahora esta en nivel critico
  if (currentStock <= STOCK_THRESHOLD && previousStock > STOCK_THRESHOLD) {
    console.log(`ALERTA! Stock bajo detectado: ${afterData.nombre} (${currentStock} unidades)`);
    
    try {
      // Obtener todos los administradores activos con token FCM
      const adminsSnapshot = await db
        .collection('usuarios')
        .where('idRol', '==', 'admin')
        .where('activo', '==', true)
        .get();
      
      if (adminsSnapshot.empty) {
        console.log('No hay administradores activos');
        return null;
      }
      
      // Recopilar tokens FCM validos
      const tokens = [];
      adminsSnapshot.forEach(doc => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) {
          tokens.push(fcmToken);
          console.log(`Token encontrado para admin: ${doc.id}`);
        }
      });
      
      if (tokens.length === 0) {
        console.log('No hay administradores con tokens FCM configurados');
        return null;
      }
      
      // Determinar nombre del salon
      const salonName = afterData.idSalon === 'salon_principal' 
        ? 'Salon Principal' 
        : 'Salon Secundario';
      
      // Determinar nivel de urgencia
      let urgencyLevel = 'ALERTA';
      let urgencyText = 'Stock Bajo';
      
      if (currentStock === 0) {
        urgencyLevel = 'CRITICO';
        urgencyText = 'Stock Agotado';
      } else if (currentStock <= 2) {
        urgencyLevel = 'URGENTE';
        urgencyText = 'Stock Critico';
      }
      
      // Crear mensaje de notificacion
      const message = {
        notification: {
          title: `${urgencyLevel} - ${urgencyText}`,
          body: `${afterData.nombre} tiene solo ${currentStock} unidades en ${salonName}. Considera hacer un pedido.`,
        },
        data: {
          productId: productId,
          productName: afterData.nombre,
          stock: currentStock.toString(),
          salonId: afterData.idSalon,
          salonName: salonName,
          timestamp: new Date().toISOString(),
          route: '/notifications',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'stock_alerts',
            priority: 'high',
            color: '#D9266D',
            sound: 'default',
            icon: 'ic_launcher',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        tokens: tokens,
      };
      
      // Enviar notificacion multicast a todos los admins
      const response = await messaging.sendEachForMulticast(message);
      
      console.log(`Notificaciones enviadas exitosamente: ${response.successCount}/${tokens.length}`);
      
      // Log de errores individuales
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(`Error enviando a token ${idx}: ${resp.error?.message}`);
            
            // Si el token es invalido, marcarlo en Firestore
            if (resp.error?.code === 'messaging/invalid-registration-token' ||
                resp.error?.code === 'messaging/registration-token-not-registered') {
              console.log(`Token invalido detectado, debe ser eliminado`);
            }
          }
        });
      }
      
      // Registrar alerta en Firestore (para historial)
      await db.collection('stock_alerts').add({
        productId: productId,
        productName: afterData.nombre,
        stock: currentStock,
        previousStock: previousStock,
        salonId: afterData.idSalon,
        salonName: salonName,
        timestamp: FieldValue.serverTimestamp(),
        notificationsSent: response.successCount,
        resolved: false,
      });
      
      console.log('Alerta registrada en Firestore');
      
      return {
        success: true,
        notificationsSent: response.successCount,
        failureCount: response.failureCount,
      };
      
    } catch (error) {
      console.error('Error en checkLowStock:', error);
      return null;
    }
  } else if (currentStock > STOCK_THRESHOLD && previousStock <= STOCK_THRESHOLD) {
    console.log(`Stock recuperado: ${afterData.nombre} (${currentStock} unidades)`);
    
    // Opcional: Marcar alertas como resueltas
    try {
      const alertsSnapshot = await db
        .collection('stock_alerts')
        .where('productId', '==', productId)
        .where('resolved', '==', false)
        .get();
      
      const batch = db.batch();
      alertsSnapshot.forEach(doc => {
        batch.update(doc.ref, { resolved: true, resolvedAt: FieldValue.serverTimestamp() });
      });
      
      await batch.commit();
      console.log(`Alertas marcadas como resueltas para: ${afterData.nombre}`);
    } catch (error) {
      console.error('Error marcando alertas como resueltas:', error);
    }
  } else {
    console.log(`Stock cambio pero no requiere notificacion (actual: ${currentStock}, umbral: ${STOCK_THRESHOLD})`);
  }
  
  return null;
});

/**
 * Cloud Function para probar notificaciones manualmente (opcional)
 */
exports.testNotification = onCall(async (request) => {
  console.log('Funcion de prueba ejecutada');
  
  const adminsSnapshot = await db
    .collection('usuarios')
    .where('idRol', '==', 'admin')
    .where('activo', '==', true)
    .get();
  
  const tokens = [];
  adminsSnapshot.forEach(doc => {
    const fcmToken = doc.data().fcmToken;
    if (fcmToken) tokens.push(fcmToken);
  });
  
  if (tokens.length === 0) {
    return { success: false, message: 'No hay tokens FCM' };
  }
  
  const message = {
    notification: {
      title: 'Prueba de Notificaciones',
      body: 'Esta es una notificacion de prueba. Sistema funcionando correctamente.',
    },
    tokens: tokens,
  };
  
  const response = await messaging.sendEachForMulticast(message);
  
  return {
    success: true,
    sent: response.successCount,
    failed: response.failureCount,
  };
});

console.log('Cloud Functions cargadas exitosamente');