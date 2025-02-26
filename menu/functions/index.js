/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions/v1"); // v1と明示的にバージョン指定しないとエラーが起きる
const admin = require("firebase-admin"); // Firebase Admin SDK

admin.initializeApp(); // Firebase Admin SDK の初期化
const db = admin.firestore(); // Firestore のインスタンス

// 匿名ユーザーの削除 (30日以上ログインしていないユーザー)
exports.deleteInactiveAnonymousUsers = functions.pubsub
    .schedule("every 24 hours") // 毎日実行
    .timeZone("Asia/Tokyo") // 日本時間
    .onRun(async (context) => {
      try {
        const users = await admin.auth().listUsers(); // ユーザー一覧取得
        const now = Date.now(); // 現在時刻 (ミリ秒)
        const threshold = 20 * 24 * 60 * 60 * 1000; // 20日 (ミリ秒)

        const inactiveUids = users.users // 匿名ユーザーのみを抽出
            .filter((user) =>
              user.providerData.length === 0 && // プロバイダーが存在しない
                    user.metadata.lastSignInTime && // 最終ログイン時刻が存在する
                    now - new Date(user.metadata.lastSignInTime)
                        .getTime() > threshold,
            )
            .map((user) => user.uid); // UID のみ抽出

        if (inactiveUids.length > 0) { // 削除対象が存在する場合
          await admin.auth().deleteUsers(inactiveUids); // ユーザー削除
          console.log(`${inactiveUids.length} anonymous users deleted.`);
        } else {
          console.log("削除対象がありません");
        }
      } catch (error) {
        console.error("Error deleting users:", error);
      }
    });

// LINE ユーザーの登録
exports.lineWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") { // POST メソッド以外はエラー
    return res.status(405).send("Method Not Allowed");
  }

  const events = req.body.events;
  if (!events) { // events プロパティが存在しない場合はエラー
    return res.status(400).send("Bad Request");
  }

  const promises = events.map(async (event) => {
    if (event.source && event.source.userId) {
      await db.collection("lineUsers").doc(event.source.userId).set({
        userId: event.source.userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}); // 既存のデータがある場合は更新
      console.log(`LINE User ID: ${event.source.userId}`);
    }
  });

  await Promise.all(promises); // 全ての処理が完了するまで待機

  res.status(200).send("OK"); // 正常終了
});
