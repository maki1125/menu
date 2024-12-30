// エラーメッセージクラス
class AuthErrorMessages {
  static const userNotFound = 'ユーザーが見つかりません';
  static const wrongPassword = 'パスワードが間違っています';
  static const invalidEmail = '無効なメールアドレスです';
  static const weakPassword = 'パスワードが脆弱です, 6文字以上で入力してください';
  static const emailAlreadyInUse = 'そのアカウント名は既に使用されています';
  static const unknownError = 'エラーが発生しました';
  static const operationNotAllowed = 'アカウントが有効ではありません';
  static const userDisabled = 'ユーザーが存在しません';
  static const anonymousAuthDisabled = 'このプロジェクトでは匿名認証が有効になっていません';
  static const accountExistCrediential = '異なる認証情報を持つアカウントが存在します';
  static const invalidCredential = '無効な認証情報です';
}
