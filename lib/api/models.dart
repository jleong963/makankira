// API DTOs (camelCase JSON from the /api layer). Money fields are integer sen.

class ApiException implements Exception {
  final int status;
  final String code;
  final String message;
  ApiException(this.status, this.code, this.message);
  @override
  String toString() => message;
}

class AppUser {
  final String id;
  final String authProvider;
  final String? email;
  final String? displayName;
  final String? mobileNumber;
  final String? photoUrl;
  final String preferredLanguage;

  AppUser({
    required this.id,
    required this.authProvider,
    this.email,
    this.displayName,
    this.mobileNumber,
    this.photoUrl,
    required this.preferredLanguage,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        authProvider: j['authProvider'] as String? ?? 'google',
        email: j['email'] as String?,
        displayName: j['displayName'] as String?,
        mobileNumber: j['mobileNumber'] as String?,
        photoUrl: j['photoUrl'] as String?,
        preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
      );
}

class MealSession {
  final String id;
  final String title;
  final String? mealType;
  final bool farewellEnabled;
  final String restaurantName;
  final String? menuUrl;
  final String? mealDateTime;
  final String? seatDetails;
  final String? organizerName;
  final String? organizerContact;
  final String status;
  final bool reminderEnabled;
  final int reminderLeadMinutes;
  final String? remindAt;
  final String role; // 'organizer' (owned) or 'participant' (joined)
  final String? inviteToken; // present on owned meals (for the Share link)

  MealSession({
    required this.id,
    required this.title,
    required this.mealType,
    required this.farewellEnabled,
    required this.restaurantName,
    required this.menuUrl,
    required this.mealDateTime,
    required this.seatDetails,
    required this.organizerName,
    required this.organizerContact,
    required this.status,
    required this.reminderEnabled,
    required this.reminderLeadMinutes,
    this.remindAt,
    this.role = 'participant',
    this.inviteToken,
  });

  bool get isParticipant => role == 'participant';

  factory MealSession.fromJson(Map<String, dynamic> j) => MealSession(
        id: j['id'] as String,
        title: j['title'] as String,
        mealType: j['mealType'] as String?,
        farewellEnabled: j['farewellEnabled'] as bool? ?? false,
        restaurantName: j['restaurantName'] as String? ?? '',
        menuUrl: j['menuUrl'] as String?,
        mealDateTime: j['mealDateTime'] as String?,
        seatDetails: j['seatDetails'] as String?,
        organizerName: j['organizerName'] as String?,
        organizerContact: j['organizerContact'] as String?,
        status: j['status'] as String? ?? 'draft',
        reminderEnabled: j['reminderEnabled'] as bool? ?? true,
        reminderLeadMinutes: (j['reminderLeadMinutes'] as num?)?.toInt() ?? 120,
        remindAt: j['remindAt'] as String?,
        // Least privilege: an unknown/missing role is treated as participant, so
        // organizer-only actions (e.g. Mark as complete) never show by default.
        // Owner endpoints send role explicitly (see toMealSession).
        role: j['role'] as String? ?? 'participant',
        inviteToken: j['inviteToken'] as String?,
      );
}

class PaymentMethod {
  final String id;
  final String methodType;
  final String? accountName;
  final String? bankName;
  final String? accountNumber;
  final String? duitNowId;
  final String? qrImageFileId;
  final String? instructions;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.methodType,
    this.accountName,
    this.bankName,
    this.accountNumber,
    this.duitNowId,
    this.qrImageFileId,
    this.instructions,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> j) => PaymentMethod(
        id: j['id'] as String,
        methodType: j['methodType'] as String,
        accountName: j['accountName'] as String?,
        bankName: j['bankName'] as String?,
        accountNumber: j['accountNumber'] as String?,
        duitNowId: j['duitNowId'] as String?,
        qrImageFileId: j['qrImageFileId'] as String?,
        instructions: j['instructions'] as String?,
        isDefault: j['isDefault'] as bool? ?? false,
      );
}

class MenuItem {
  final String id;
  final String? itemCode;
  final String name;
  final String? category;
  final String? description;
  final int? estimatedPriceCents;
  final int? actualPriceCents;
  final bool available;

  MenuItem({
    required this.id,
    this.itemCode,
    required this.name,
    this.category,
    this.description,
    this.estimatedPriceCents,
    this.actualPriceCents,
    this.available = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
        id: j['id'] as String,
        itemCode: j['itemCode'] as String?,
        name: j['name'] as String,
        category: j['category'] as String?,
        description: j['description'] as String?,
        estimatedPriceCents: (j['estimatedPriceCents'] as num?)?.toInt(),
        actualPriceCents: (j['actualPriceCents'] as num?)?.toInt(),
        available: j['available'] as bool? ?? true,
      );
}

class OrderItem {
  final String id;
  final String menuItemId;
  final int quantity;
  final String? remarks;

  OrderItem({required this.id, required this.menuItemId, required this.quantity, this.remarks});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id: j['id'] as String? ?? '',
        menuItemId: j['menuItemId'] as String,
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        remarks: j['remarks'] as String?,
      );
}

class ParticipantOrder {
  final String id;
  final String participantName;
  final String participantRole;
  final String? mobileNumber;
  final List<OrderItem> items;

  ParticipantOrder({
    required this.id,
    required this.participantName,
    required this.participantRole,
    this.mobileNumber,
    required this.items,
  });

  bool get isHonoree => participantRole == 'farewell_honoree';

  factory ParticipantOrder.fromJson(Map<String, dynamic> j) => ParticipantOrder(
        id: j['id'] as String,
        participantName: j['participantName'] as String,
        participantRole: j['participantRole'] as String? ?? 'paying_participant',
        mobileNumber: j['mobileNumber'] as String?,
        items: (j['items'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(OrderItem.fromJson)
            .toList(),
      );
}

/// What a participant sees on the invite/join page: the public meal, available
/// menu, the live per-person order list (names + items, no mobiles), and their
/// own order (if any).
class MemberMealView {
  final MealSession meal;
  final List<MenuItem> menu;
  final List<dynamic> orders; // [{ participantOrderId, participantName, role, items:[...] }]
  final ParticipantOrder? myOrder;

  MemberMealView({required this.meal, required this.menu, required this.orders, this.myOrder});

  factory MemberMealView.fromJson(Map<String, dynamic> j) => MemberMealView(
        meal: MealSession.fromJson(j['meal'] as Map<String, dynamic>),
        menu: (j['menu'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(MenuItem.fromJson)
            .toList(),
        orders: (j['orders'] as List? ?? const <dynamic>[]),
        myOrder: j['myOrder'] == null ? null : ParticipantOrder.fromJson(j['myOrder'] as Map<String, dynamic>),
      );
}

class BillAdjustment {
  final String calculationMode;
  final bool includeOrganizerInSplit;
  final int taxAmountCents;
  final int serviceChargeAmountCents;
  final int discountAmountCents;
  final String companyClaimType; // none | fixed | percentage
  final double? companyClaimPercent;
  final int companyClaimAmountCents;
  final int? finalBillAmountCents;

  BillAdjustment({
    this.calculationMode = 'item_based',
    this.includeOrganizerInSplit = true,
    this.taxAmountCents = 0,
    this.serviceChargeAmountCents = 0,
    this.discountAmountCents = 0,
    this.companyClaimType = 'none',
    this.companyClaimPercent,
    this.companyClaimAmountCents = 0,
    this.finalBillAmountCents,
  });

  factory BillAdjustment.fromJson(Map<String, dynamic> j) => BillAdjustment(
        calculationMode: j['calculationMode'] as String? ?? 'item_based',
        includeOrganizerInSplit: j['includeOrganizerInSplit'] as bool? ?? true,
        taxAmountCents: (j['taxAmountCents'] as num?)?.toInt() ?? 0,
        serviceChargeAmountCents: (j['serviceChargeAmountCents'] as num?)?.toInt() ?? 0,
        discountAmountCents: (j['discountAmountCents'] as num?)?.toInt() ?? 0,
        companyClaimType: j['companyClaimType'] as String? ?? 'none',
        companyClaimPercent: (j['companyClaimPercent'] as num?)?.toDouble(),
        companyClaimAmountCents: (j['companyClaimAmountCents'] as num?)?.toInt() ?? 0,
        finalBillAmountCents: (j['finalBillAmountCents'] as num?)?.toInt(),
      );
}

class PaymentResult {
  final String id;
  final String participantName;
  final String participantRole;
  final String? mobileNumber;
  final int subtotalCents;
  final int taxCents;
  final int serviceChargeCents;
  final int discountCents;
  final int companyClaimCents;
  final int farewellSponsoredShareCents;
  final int roundingAdjustmentCents;
  final int totalDueCents;
  final bool isManualOverride;
  final String paymentStatus;
  final String? paymentReference;

  PaymentResult({
    required this.id,
    required this.participantName,
    required this.participantRole,
    this.mobileNumber,
    required this.subtotalCents,
    required this.taxCents,
    required this.serviceChargeCents,
    required this.discountCents,
    required this.companyClaimCents,
    required this.farewellSponsoredShareCents,
    required this.roundingAdjustmentCents,
    required this.totalDueCents,
    required this.isManualOverride,
    required this.paymentStatus,
    this.paymentReference,
  });

  bool get isHonoree => participantRole == 'farewell_honoree';

  factory PaymentResult.fromJson(Map<String, dynamic> j) {
    int c(String k) => (j[k] as num?)?.toInt() ?? 0;
    return PaymentResult(
      id: j['id'] as String,
      participantName: j['participantName'] as String,
      participantRole: j['participantRole'] as String? ?? 'paying_participant',
      mobileNumber: j['mobileNumber'] as String?,
      subtotalCents: c('subtotalCents'),
      taxCents: c('taxCents'),
      serviceChargeCents: c('serviceChargeCents'),
      discountCents: c('discountCents'),
      companyClaimCents: c('companyClaimCents'),
      farewellSponsoredShareCents: c('farewellSponsoredShareCents'),
      roundingAdjustmentCents: c('roundingAdjustmentCents'),
      totalDueCents: c('totalDueCents'),
      isManualOverride: j['isManualOverride'] as bool? ?? false,
      paymentStatus: j['paymentStatus'] as String? ?? 'pending',
      paymentReference: j['paymentReference'] as String?,
    );
  }
}

class CalcSummary {
  final int calculatedTotalCents;
  final int? finalBillAmountCents;
  final int companyClaimAmountCents;
  final int collectedFromParticipantsCents;
  final int mismatchCents;

  CalcSummary({
    required this.calculatedTotalCents,
    this.finalBillAmountCents,
    required this.companyClaimAmountCents,
    required this.collectedFromParticipantsCents,
    required this.mismatchCents,
  });

  factory CalcSummary.fromJson(Map<String, dynamic> j) => CalcSummary(
        calculatedTotalCents: (j['calculatedTotalCents'] as num?)?.toInt() ?? 0,
        finalBillAmountCents: (j['finalBillAmountCents'] as num?)?.toInt(),
        companyClaimAmountCents: (j['companyClaimAmountCents'] as num?)?.toInt() ?? 0,
        collectedFromParticipantsCents: (j['collectedFromParticipantsCents'] as num?)?.toInt() ?? 0,
        mismatchCents: (j['mismatchCents'] as num?)?.toInt() ?? 0,
      );
}

class PaymentRequest {
  final String resultId;
  final String participantName;
  final String? mobileNumber;
  final int totalDueCents;
  final String message;
  final String? whatsappUrl;
  final String? qrImageUrl;
  final String? paymentReference;

  PaymentRequest({
    required this.resultId,
    required this.participantName,
    this.mobileNumber,
    required this.totalDueCents,
    required this.message,
    this.whatsappUrl,
    this.qrImageUrl,
    this.paymentReference,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> j) => PaymentRequest(
        resultId: j['resultId'] as String,
        participantName: j['participantName'] as String,
        mobileNumber: j['mobileNumber'] as String?,
        totalDueCents: (j['totalDueCents'] as num?)?.toInt() ?? 0,
        message: j['message'] as String? ?? '',
        whatsappUrl: j['whatsappUrl'] as String?,
        qrImageUrl: j['qrImageUrl'] as String?,
        paymentReference: j['paymentReference'] as String?,
      );
}
