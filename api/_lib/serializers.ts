/**
 * serializers.ts — map snake_case DB rows to the camelCase JSON DTOs the UI
 * consumes (README Section 9). Money stays as integer-cents fields.
 */

import type { Row } from '@libsql/client';

const str = (v: unknown): string | null => (v == null ? null : String(v));
const num = (v: unknown): number | null => (v == null ? null : Number(v));
const bool = (v: unknown): boolean => Number(v) === 1;

/** Public user DTO — never exposes the provider's raw user id. */
export function toUser(row: Row): Record<string, unknown> {
  return {
    id: row.id,
    authProvider: row.auth_provider,
    email: str(row.email),
    displayName: str(row.display_name),
    mobileNumber: str(row.mobile_number),
    photoUrl: str(row.photo_url),
    preferredLanguage: row.preferred_language,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export function toMealSession(row: Row): Record<string, unknown> {
  return {
    id: row.id,
    ownerUserId: row.owner_user_id,
    title: row.title,
    mealType: str(row.meal_type),
    occasionType: row.occasion_type,
    farewellEnabled: bool(row.farewell_enabled),
    restaurantName: row.restaurant_name,
    menuUrl: str(row.menu_url),
    mealDateTime: str(row.meal_date_time),
    seatDetails: str(row.seat_details),
    organizerName: str(row.organizer_name),
    organizerContact: str(row.organizer_contact),
    status: row.status,
    reminderEnabled: bool(row.reminder_enabled),
    reminderLeadMinutes: num(row.reminder_lead_minutes),
    remindAt: str(row.remind_at),
    reminderSentAt: str(row.reminder_sent_at),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

/** Works for both session payment_methods and account user_payment_methods. */
export function toPaymentMethod(row: Row): Record<string, unknown> {
  return {
    id: row.id,
    ...(row.meal_session_id != null ? { mealSessionId: row.meal_session_id } : {}),
    ...(row.user_id != null ? { userId: row.user_id } : {}),
    methodType: row.method_type,
    accountName: str(row.account_name),
    bankName: str(row.bank_name),
    accountNumber: str(row.account_number),
    duitNowId: str(row.duitnow_id),
    qrImageFileId: str(row.qr_image_file_id),
    instructions: str(row.instructions),
    isDefault: bool(row.is_default),
    sortOrder: num(row.sort_order),
  };
}

export const serdeHelpers = { str, num, bool };
