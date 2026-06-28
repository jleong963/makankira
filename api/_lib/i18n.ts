/**
 * i18n.ts — server-side labels for generated content (payment messages, export
 * sheet headings). UI strings live in Flutter ARB files; this covers only text
 * the server produces. User-entered content (names, items) is never translated.
 * English is the fallback (README Section 11, Language).
 */

import type { Locale } from './validate';

export interface PaymentLabels {
  greeting: (name: string, meal: string, amount: string) => string;
  items: string;
  farewellShare: string;
  taxService: string;
  discount: string;
  companyClaim: string;
  transferTo: string;
  scanQr: string;
  reference: string;
}

const PAYMENT: Record<Locale, PaymentLabels> = {
  en: {
    greeting: (name, meal, amount) => `Hi ${name}, your total for ${meal} is ${amount}.`,
    items: 'Items:',
    farewellShare: 'Farewell share',
    taxService: 'Tax/service charge',
    discount: 'Discount',
    companyClaim: 'Company claim subsidy',
    transferTo: 'Please transfer to:',
    scanQr: 'Or scan the DuitNow QR:',
    reference: 'Reference',
  },
  zh: {
    greeting: (name, meal, amount) => `${name} 您好，您在「${meal}」的应付总额为 ${amount}。`,
    items: '项目：',
    farewellShare: '欢送分摊',
    taxService: '税务／服务费',
    discount: '折扣',
    companyClaim: '公司报销',
    transferTo: '请转账至：',
    scanQr: '或扫描 DuitNow QR：',
    reference: '参考编号',
  },
  ms: {
    greeting: (name, meal, amount) => `Hai ${name}, jumlah anda untuk ${meal} ialah ${amount}.`,
    items: 'Item:',
    farewellShare: 'Bahagian majlis perpisahan',
    taxService: 'Cukai/caj perkhidmatan',
    discount: 'Diskaun',
    companyClaim: 'Subsidi tuntutan syarikat',
    transferTo: 'Sila pindahkan ke:',
    scanQr: 'Atau imbas DuitNow QR:',
    reference: 'Rujukan',
  },
};

export function paymentLabels(locale: string): PaymentLabels {
  return PAYMENT[(locale as Locale) in PAYMENT ? (locale as Locale) : 'en'];
}
