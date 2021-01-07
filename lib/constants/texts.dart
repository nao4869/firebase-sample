// common part
const String ja = 'ja';
const String userName = 'ユーザー名';
const String cancel = 'キャンセル';
const String selectIconImage = 'アイコン画像の選択';
const String save = '保存';
const String update = '更新';
const String appTitle = 'Memo';

// in_app_purchase
const bool kAutoConsume = true;
const String kConsumableId = 'ads_off';
const List<String> kProductIds = <String>[
  kConsumableId,
  'upgrade',
  'subscription'
];

const String purchased = '購入完了';
const String successfullyPurchased = '購入処理が完了しました';
const String cmnOkay ='OK';

const String checkNetworkStatus = '通信状態をご確認の上、再度お試しください。';
const String notHaveNetwork = 'インターネット接続がありません。';

const String initText =
    'カテゴリー別にメモを作成できます。\n\n授業の科目毎のメモ、忘れられない用語のメモなどにお使いいただけます。メモ、アイコンの細かいカスタマイズなどは設定画面から変更いただけます。\n\n新規のカテゴリ追加は右上プラスアイコンより、追加することが可能です。';
const String initProfile =
    '当アプリはカテゴリー別に作成できるメモアプリになります。カレンダーを使用し、日付ごとにメモを管理することなども可能です。';
const String userNameEnglish = 'User name';
const String cancelEnglish = 'Cancel';
const String selectIconImageEnglish = 'Select icon iamge';
const String saveEnglish = 'Save';
const String updateEnglish = 'Update';

// profile edit screen
const String defaultSeaImage = 'assets/images/1046.jpg';
const String defaultPersonImage = 'assets/images/default_profile_image.png';
const String next = '次へ';

const String nameTitle = '名前';
const String selfIntroductionTitle = 'メモの説明';
const String website = 'ウェブサイト';
const String editProfile = 'プロフィールを編集';

const String emptyInput = '入力が空です';

const String validate = 'validate';
const String notValidate = 'not validate';

// switch users screen
const String allUsers = 'すべてのユーザー';
const String switchTitle = '変更する';
const String userHasSwitched = 'ユーザーが変更されました';
const String currentLoginUserTitle = '現在ログイン中のユーザー';

const String confirmDeleteUser = '選択中のユーザーを削除しますか？';

// drawer screen
const String profile = 'プロフィール';
const String list = 'リスト';
const String topic = 'トピック';
const String bookmark = 'ブックマーク';
const String moment = 'モーメント';
const String twitterAds = 'Twitter広告';
const String createNewAccount = '新しいアカウントを作成';
const String useExistingAccount = '作成済みのアカウントを使う';

// main - introduction
const String descUserNameEnglish = '未設定';
const String descUserName = '未設定';
const String defaultImagePath = 'assets/images/default_profile_image.png';
const String birdImagePath = 'assets/images/app_icon.png';

const String firstChat =
    'SNS風メモアプリをインストールして下さり、ありがとうございます。簡単に使い方と機能を紹介していきます。\n\n設定されているアカウントの名前やアイコン画像などは変更可能です。';

const String descriptionChat1 =
    'SNS風メモアプリをインストールして下さり、ありがとうございます。簡単に使い方と機能を紹介していきます。\n\n設定されているアカウントの名前やアイコン画像などは変更可能です。\n\n最新のアップデートによりアプリのテーマカラーの変更もできるようになりました。';

const String descriptionChat2 =
    'このアプリはSNSのように使えるメモアプリです。新規にアカウントを作成したり、メモを作成した日付毎に管理することが可能です。\n\nユーザー毎のアイコン画像やプロフィール詳細などは全て変更してお使いいただけます。\n\nアプリに対するお問い合わせや、追加して欲しい機能などがありましたらレビューなどでお知らせいただけますと幸いです。';

// option_selection_screen.dart
const String impressionList = '感想項目';
const String review = 'アプリへの評価';
const String inquiry = 'お問い合わせ';
const String askToCreateReview =
    'このアプリを気に入っていただけましたら、評価をストアの方へ書いていただけますと幸いです。何卒よろしくお願い致します。\n\n同時に、追加して欲しい機能や、改善して欲しいデザインなどありましたら合わせてお知らせください。高評価をいただいた際には機能更新、追加などのスピードが速くなります。';
const String askToCreateInquiry =
    'アプリの使い方でわかりにくい点や、使用方法の説明を追加して欲しい点などありましたら、レビューなどでお知らせください。\n\n返信が必要な場合や、内容がレビューなどで書くことができない長さの場合は、アプリ開発者の連絡先からご連絡ください。';
const String createReview = '評価を書く';
const String createInquiry = 'お問い合わせ';
const String addNewFeature =
    '追加して欲しい機能のアイディアや意見、改善して欲しい機能などが御座いましたら、こちらのリンクからメールをご送信ください。';
const String sendEmail = 'メールを送信する';

// create new account screen
const String createAccount = '新しいメモカテゴリを作成';
const String accountIdTitle = 'メモカテゴリーID';
const String followCountTitle = 'フォロー数';
const String followerCountTitle = 'フォロワー数';

// create new tweet screen
const String addImage = '画像追加';
const String tweet = 'メモ';
const String memoCreatedAt = 'メモの作成日';
const String likeCount = 'いいね数';
const String reTweetCount = 'リツイート数';
const String takePhoto = '写真を撮る';
const String selectImageFromGallery = 'フォルダから画像を選択';

const String cameraAccessNotPermitted = 'カメラへのアクセスが許可されていません。';
const String okay = 'OK';
const String setUp = '設定する';

// create related screens
const String replyingTo = 'メモにメモする: ';
const String doReply = '返信する';
const String publicAccountMark = '公式マーク';

// chat room related screens
const String newMessage = '新しいメッセージ';
const String conversationInformation = '会話情報';
const String message = 'メッセージ';
const String addNewFeatureReequest =
    '追加機能の要望、改善点などがありましたら、レビューにてお知らせいただけますと幸いです。';
const String confirmDeleteConversation = '会話を削除しますか？';
const String doDelete = '削除する';

// crop inage screen
const String adjustSize = 'サイズ調整';
const String adjustSizeForIcon = 'アイコン用のサイズ調整';
const String decide = '決定';

// edit existing tweet screen
const String edit = '編集する';

// home folder
const String memoHasCopied = 'メモをコピーしました';
const String birthday = '生年月日';
const String displayBirthday = '生年月日を表示';

const String notDisplayReplyingToTweet = 'コメント先のツイートを非表示にしますか？';
const String displayReplyingToTweet = 'コメント先のツイートを表示しますか？';
const String birthdayAndCollon = '作成日: ';

// profile detail screen
const String keep = 'Keep';
const String post = '投稿';
const String photo = '写真';

// settings screen
const String accountSettings = 'アカウント設定';
const String accountSettingsEnglish = 'Personal Setting';
const String profileEdit = 'プロフィール編集';
const String profileEditEnglish = 'Edit Profile';
const String darkMode = 'ダークモード';
const String darkModeEnglish = 'Dark Mode';

const String privacyPolicy =
    'https://github.com/nao4869/twitter-like-memo-privacy-policy';
const String appInfo = 'アプリ情報';
const String appInfoEnglish = 'Application Information';
const String privacyPolicyTitle = 'プライバシーポリシー';
const String privacyPolicyTitleEnglish = 'Privacy Policy';

const String licenseInfo = 'ライセンス情報';
const String licenseInfoEnglish = 'License Information';

const String appName = 'カテメモ';
const String appVersion = '1.2.1';
const String rightsInfo = '権利情報';

const String inquiryEnglish = 'Inquiry';
const String reviewApp = 'アプリの評価をする';
const String reviewAppEnglish = 'Review Application';

// tweet detail screen
const String twitterForIphone = '・CateMemo for iPhone';
const String twitterForAndroid = '・CateMemo for Android';
const String reTweetAndQuoteReTweet = 'メモと引用メモ';
const String like = 'いいね';

const String editTweet = 'メモを編集する';
const String deleteTweet = 'メモを削除する';
const String confirmDeleteTweet = '本当にメモを削除しますか？';

// user profile screen
const String userTwitterFrom = 'からTwiMemoを利用しています';
const String tweetAndReply = 'メモ';
const String reply = 'メモのメモ';
const String media = '画像メモ';

const String followVerb = 'フォローする';
const String follow = 'フォロー';
const String follower = 'フォロワー';
const String followFeatureImplementedByUpdate = 'フォロー機能: アップデートにより実施予定';

// drawer screen
const String addUser = 'ユーザーを追加';
const String switchUser = 'ユーザーを変更する';

// bottom date picker
const String completed = '完了';
const String yearJapanese = '年';
const String monthJapanese = '月';
const String dayJapanese = '日';

// common dialog
const String yes = 'はい';
const String finishApplication = 'アプリを終了します';
const String confirmQuitApp = '終了しますか？';
const String cannotGoBackAnymore = 'これ以上戻れません。';

const String editChatTitle = 'チャットへ変更を加える';
const String copyContent = '内容をコピーする';
const String deleteChat = 'チャットを削除する';
const String confirmDeleteChat = '本当にこのチャットを削除しますか？';
const String operationCannotRevert = 'この操作は取り消せません。';
const String createNewMessage = 'メッセージを作成';
