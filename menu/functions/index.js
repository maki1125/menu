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
