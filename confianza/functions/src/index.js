const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

// Inicializar Firebase Admin
admin.initializeApp();

// Configurar SendGrid
const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

const ADMIN_EMAIL = "firebaseconfident@gmail.com";

/**
 * Cloud Function simplificada
 * Se ejecuta cuando se crea un nuevo reporte
 * Envía un email al administrador con: ID del secreto + comentario
 */
exports.sendReportEmail = functions
  .region("us-central1")
  .firestore
  .document("reports/{reportId}")
  .onCreate(async (snap, context) => {
    const report = snap.data();
    const reportId = context.params.reportId;

    try {
      // Preparar el contenido del email
      const emailContent = `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial; color: #333; }
    .container { max-width: 500px; padding: 20px; }
    .header { background: #dc3545; color: white; padding: 15px; border-radius: 5px 5px 0 0; }
    .content { border: 1px solid #ddd; padding: 20px; border-radius: 0 0 5px 5px; }
    .field { margin: 15px 0; }
    .label { font-weight: bold; color: #dc3545; }
    .value { background: #f5f5f5; padding: 10px; margin-top: 5px; font-family: monospace; }
    .comment { background: #f5f5f5; padding: 10px; margin-top: 5px; white-space: pre-wrap; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header"><h2>🚨 Nuevo Reporte</h2></div>
    <div class="content">
      <div class="field">
        <div class="label">ID del Secreto:</div>
        <div class="value">${report.secretId}</div>
      </div>
      <div class="field">
        <div class="label">Comentario:</div>
        <div class="comment">${escapeHtml(report.comment)}</div>
      </div>
      <div class="field">
        <div class="label">Fecha:</div>
        <div class="value">${report.createdAt.toDate().toLocaleString('es-ES')}</div>
      </div>
    </div>
  </div>
</body>
</html>
      `;

      if (SENDGRID_API_KEY) {
        await sgMail.send({
          to: ADMIN_EMAIL,
          from: "noreply@confianza.app",
          subject: `Reporte - ${report.secretId}`,
          html: emailContent,
        });
        console.log(`Email enviado para reporte ${reportId}`);
      } else {
        console.warn("SENDGRID_API_KEY no configurada");
      }

      return { success: true };
    } catch (error) {
      console.error("Error:", error);
      throw error;
    }
  });

function escapeHtml(unsafe) {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
