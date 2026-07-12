// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'MakanKira';

  @override
  String get appTagline => '一起点餐，公平计算，轻松付款。';

  @override
  String get loginSubtitle => '组织聚餐、收集点餐、分摊账单并请求付款。';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get signOut => '退出登录';

  @override
  String get termsPrivacy => '条款与隐私';

  @override
  String get loginError => '登录失败，请重试。';

  @override
  String get language => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get loading => '加载中…';

  @override
  String get errorTitle => '出错了';

  @override
  String get retry => '重试';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get create => '创建';

  @override
  String get search => '搜索';

  @override
  String get required => '必填';

  @override
  String get comingSoon => '敬请期待';

  @override
  String get mealSessions => '聚餐';

  @override
  String get newMeal => '新建聚餐';

  @override
  String get searchMeals => '搜索聚餐';

  @override
  String get noMeals => '还没有聚餐，创建第一个吧。';

  @override
  String get filterAll => '全部';

  @override
  String get settings => '设置';

  @override
  String get profile => '个人资料';

  @override
  String get statusDraft => '草稿';

  @override
  String get statusCollecting => '收集点餐中';

  @override
  String get statusFinalized => '已确认';

  @override
  String get statusBillEntered => '已录入账单';

  @override
  String get statusClaimApplied => '已报销';

  @override
  String get statusPaymentRequested => '已请求付款';

  @override
  String get statusClosed => '已完成';

  @override
  String get mealSetup => '聚餐设置';

  @override
  String get mealTitle => '聚餐名称';

  @override
  String get mealType => '餐别';

  @override
  String get mealTypeBreakfast => '早餐';

  @override
  String get mealTypeLunch => '午餐';

  @override
  String get mealTypeDinner => '晚餐';

  @override
  String get mealTypeSupper => '宵夜';

  @override
  String get mealTypeCustom => '自定义';

  @override
  String get restaurantName => '餐厅名称';

  @override
  String get menuUrl => '菜单链接';

  @override
  String get mealDateTime => '日期与时间';

  @override
  String get seatDetails => '座位 / 桌号';

  @override
  String get organizerName => '组织者姓名';

  @override
  String get organizerContact => '组织者联系方式';

  @override
  String get farewellMeal => '欢送会';

  @override
  String get farewellMealHint => '欢送对象参加点餐但无需付款。';

  @override
  String get orderReminder => '点餐提醒';

  @override
  String get reminderTime => '提醒时间';

  @override
  String get reminderTimeRequired => '请设置提醒日期和时间';

  @override
  String get reminderBeforeMeal => '提醒时间必须早于用餐时间';

  @override
  String get reminderTimePast => '请选择未来的日期和时间';

  @override
  String get mealCreated => '聚餐已创建';

  @override
  String get mealDeleted => '聚餐已删除';

  @override
  String get deleteMealConfirm => '删除此聚餐？此操作无法撤销。';

  @override
  String get markComplete => '标记为已完成';

  @override
  String get markCompleteConfirm => '确定将此聚餐标记为已完成吗？之后仍可查看。';

  @override
  String get mealMarkedComplete => '聚餐已标记为完成';

  @override
  String get restaurant => '餐厅';

  @override
  String get seat => '座位';

  @override
  String get statusLabel => '状态';

  @override
  String get paymentMethods => '收款方式';

  @override
  String get manage => '管理';

  @override
  String get noPaymentMethods => '尚未设置收款方式。';

  @override
  String get sectionMenu => '菜单';

  @override
  String get sectionOrders => '点餐';

  @override
  String get sectionReview => '核对点餐';

  @override
  String get sectionBill => '账单与付款';

  @override
  String get sectionPaymentRequests => '付款请求';

  @override
  String get sectionPaymentSummary => '付款汇总';

  @override
  String get notSet => '未设置';

  @override
  String get menuManager => '菜单';

  @override
  String get addItem => '添加项目';

  @override
  String get editItem => '编辑项目';

  @override
  String get itemName => '名称';

  @override
  String get itemCategory => '类别';

  @override
  String get itemDescription => '描述';

  @override
  String get estimatedPrice => '预估价格（RM）';

  @override
  String get actualPrice => '实际价格（RM）';

  @override
  String get available => '可选';

  @override
  String get noMenuItems => '还没有项目，添加第一个。';

  @override
  String get deleteItemConfirm => '删除此项目？';

  @override
  String get saved => '已保存';

  @override
  String get addOrder => '添加点餐';

  @override
  String get participantName => '姓名';

  @override
  String get mobileNumber => '手机号';

  @override
  String get searchCountry => '搜索国家/地区';

  @override
  String get noCountryMatch => '没有匹配的国家/地区';

  @override
  String get addMobilePrompt => '添加您的手机号码，方便组织者联系您。';

  @override
  String get addMobileCta => '添加号码';

  @override
  String get role => '角色';

  @override
  String get rolePaying => '付款';

  @override
  String get roleHonoree => '欢送对象';

  @override
  String get myOrder => '这是我的点餐';

  @override
  String get quantity => '数量';

  @override
  String get remarks => '备注';

  @override
  String get noOrders => '还没有点餐。';

  @override
  String get selectItems => '请至少选择一个项目。';

  @override
  String get addNewMenuItem => '添加新项目';

  @override
  String get addNewItemHint => '列表中没有？在此添加——组织者稍后确认价格。';

  @override
  String get viewList => '点餐';

  @override
  String get viewByItem => '按项目';

  @override
  String get viewByPerson => '按人';

  @override
  String get finalize => '确认锁定';

  @override
  String get finalizeConfirm => '锁定并确认点餐？之后无法再编辑。';

  @override
  String get orderSaved => '已添加点餐';

  @override
  String get totalQuantity => '合计';

  @override
  String get deleteOrderConfirm => '删除此点餐？';

  @override
  String get ordersLocked => '聚餐确认后订单已锁定。';

  @override
  String get calcMode => '计算方式';

  @override
  String get modeItemBased => '按项目';

  @override
  String get modeEqualSplit => '平均分摊';

  @override
  String get modeFarewell => '欢送会';

  @override
  String get tax => '税务（RM）';

  @override
  String get serviceCharge => '服务费（RM）';

  @override
  String get discount => '折扣（RM）';

  @override
  String get finalBill => '最终账单（RM）';

  @override
  String get companyClaim => '公司报销';

  @override
  String get claimNone => '无';

  @override
  String get claimFixed => '固定金额（RM）';

  @override
  String get claimPercent => '百分比（%）';

  @override
  String get claimValue => '数值';

  @override
  String get calculate => '计算';

  @override
  String get results => '结果';

  @override
  String get subtotal => '小计';

  @override
  String get totalDue => '应付总额';

  @override
  String get calculatedTotal => '计算总额';

  @override
  String get mismatch => '差额';

  @override
  String get billMismatchWarning => '计算总额与最终账单不符。';

  @override
  String get noResults => '点击「计算」查看每人金额。';

  @override
  String get farewellShareLabel => '欢送分摊';

  @override
  String get copyMessage => '复制';

  @override
  String get copyAll => '全部复制';

  @override
  String get openWhatsApp => 'WhatsApp';

  @override
  String get markPaid => '标记已付';

  @override
  String get markPending => '标记未付';

  @override
  String get paid => '已付';

  @override
  String get pending => '未付';

  @override
  String get copied => '已复制到剪贴板';

  @override
  String get noPaymentRequests => '请先计算以生成付款请求。';

  @override
  String get payableToOrganizer => '应付给组织者';

  @override
  String get paymentSummaryHint => '每人应付给组织者的金额。';

  @override
  String get paymentSummaryEmpty => '请先输入账单并点击计算，以查看完整付款明细。';

  @override
  String get howToPay => '如何付款给组织者';

  @override
  String get whatYouOwe => '您应付金额';

  @override
  String get paymentPending => '组织者结算账单后，您的应付金额将显示在这里。';

  @override
  String get honoreeNoPay => '您是荣誉嘉宾，无需付款。';

  @override
  String get displayName => '显示名称';

  @override
  String get email => '电子邮件';

  @override
  String get paymentDefaults => '默认收款方式';

  @override
  String get notifications => '通知';

  @override
  String get darkMode => '深色模式';

  @override
  String get addPaymentMethod => '添加方式';

  @override
  String get methodType => '类型';

  @override
  String get methodBank => '银行账户';

  @override
  String get methodDuitNowId => 'DuitNow ID';

  @override
  String get methodDuitNowQr => 'DuitNow QR';

  @override
  String get methodCustom => '自定义';

  @override
  String get bankName => '银行';

  @override
  String get accountName => '账户名称';

  @override
  String get accountNumber => '账号';

  @override
  String get duitNowIdLabel => 'DuitNow ID';

  @override
  String get instructions => '说明';

  @override
  String get setDefault => '设为默认';

  @override
  String get defaultLabel => '默认';

  @override
  String get noSavedMethods => '尚未保存收款方式。';

  @override
  String get profileSaved => '资料已保存';

  @override
  String get enableWebPush => '在此设备上启用通知';

  @override
  String get webPushEnabled => '已在此设备启用通知';

  @override
  String get webPushFailed => '无法在此启用通知。';

  @override
  String get emailReminderNote => '点餐提醒也会发送到您登录的电子邮件（所有设备）。';

  @override
  String get webPushNote => 'Web Push 适用于安卓和桌面浏览器（不支持 iOS）。';

  @override
  String get exportExcel => '导出 Excel';

  @override
  String get exportCsv => '导出 CSV';

  @override
  String get inviteInvalid => '此邀请链接无效或已被撤销。';

  @override
  String get leaveMeal => '退出聚餐';

  @override
  String get leaveMealConfirm => '从你的列表中移除此聚餐？你的点餐会为组织者保留。';

  @override
  String get withdrawOrder => '撤回';

  @override
  String get yourOrder => '你的点餐';

  @override
  String get everyonesOrders => '所有人的点餐';

  @override
  String get addYourOrder => '添加你的点餐';

  @override
  String get ordersClosed => '此聚餐已停止点餐。';

  @override
  String get roleOrganizer => '组织者';

  @override
  String get roleParticipant => '参与者';

  @override
  String get shareLink => '分享邀请链接';

  @override
  String get shareLinkHint => '在点餐开放期间，拥有此链接的人都可登录并添加自己的点餐。';

  @override
  String get copyLink => '复制链接';

  @override
  String get rotateLink => '重置链接';

  @override
  String get shareLinkMessage => '加入我们在 MakanKira 的聚餐点餐：';

  @override
  String get linkRotated => '邀请链接已重置——旧链接已失效。';

  @override
  String get storageFullTitle => '存储空间已满';

  @override
  String get storageFullBody => '应用存储空间已满，无法保存你的更改。请删除旧的聚餐或历史记录以释放空间，然后重试。';
}
