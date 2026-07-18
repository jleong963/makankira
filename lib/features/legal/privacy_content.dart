import 'legal_document.dart';

/// Privacy Policy — full text in the three app languages.
///
/// Written as a Personal Data Protection Act 2010 (PDPA) notice and kept
/// faithful to what the app actually does: the data lists mirror the real
/// schema (users, payment methods, meal sessions, push subscriptions), the
/// processor list mirrors the real infrastructure (Google, Vercel, Turso,
/// browser push services), and there is no analytics/ads tracking to
/// disclose. Deletion is by request (§10) — there is no self-serve account
/// deletion in the app today. English is the master; MS/ZH mirror it.

LegalDocument privacyEn() => LegalDocument(
      title: 'Privacy Policy',
      updated: 'Last updated: 18 July 2026',
      intro: [
        'This Privacy Policy explains how the operator of MakanKira ("MakanKira", "we", "us") collects, uses, discloses and protects your personal data when you use the MakanKira web application (the "Service"), in line with Malaysia’s Personal Data Protection Act 2010 ("PDPA").',
        'In short: we collect only what the Service needs to organize shared meals, we show no ads, and we never sell your personal data.',
      ],
      sections: [
        LegalSection('1. Who we are', [
          const LegalBlock.p(
              'The operator of MakanKira is the "data user" (data controller) of your personal data under the PDPA. Contact details are in the Contact section below.'),
        ]),
        LegalSection('2. Personal data we collect', [
          const LegalBlock.li(
              'Account data — when you sign in with Google: your name, email address, profile photo and Google account identifier.'),
          const LegalBlock.li(
              'Profile data — your display name, mobile number (optional) and preferred language.'),
          const LegalBlock.li(
              'Payment receiving details you save (typically as an organizer): account holder name, bank name, account number, DuitNow ID, an uploaded DuitNow QR image and payment instructions. We never ask for online-banking passwords, card numbers, PINs or OTPs.'),
          const LegalBlock.li(
              'Meal session data — session details (restaurant, date and time, seating), menus including uploaded menu photos and files, orders and remarks, participant names and optional mobile numbers, bill amounts and adjustments, and payment status records.'),
          const LegalBlock.li(
              'Data provided by others — an organizer may enter your name and phone number into a meal session on your behalf.'),
          const LegalBlock.li(
              'Technical data — a sign-in session cookie; if you enable notifications, a push subscription (endpoint, keys and browser user-agent string); and basic server logs (such as IP address and request details) kept by our hosting provider for security and operations.'),
          const LegalBlock.li(
              'Local preferences — your language and theme choices are stored in your own browser’s storage.'),
        ]),
        LegalSection('3. How we use your data', [
          const LegalBlock.li(
              'To provide the Service — accounts and sign-in, meal sessions, menus, orders, bill calculation, payment requests, and showing the organizer’s payment details to that session’s participants.'),
          const LegalBlock.li(
              'To send notifications and emails you have enabled or that the organizer triggers — such as order reminders and the restaurant order sheet.'),
          const LegalBlock.li('To remember your preferences (language and theme).'),
          const LegalBlock.li(
              'To keep the Service secure — preventing abuse, debugging and maintaining logs.'),
          const LegalBlock.li('To comply with legal obligations.'),
          const LegalBlock.p(
              'We do not sell personal data, and the Service contains no third-party advertising or cross-site tracking.'),
        ]),
        LegalSection('4. Who sees your data inside the Service', [
          const LegalBlock.li(
              'Meal sessions are shared spaces. The organizer sees participants’ names, contact numbers and orders. Participants see the menu, their own orders and amounts, the organizer’s name and contact, and the organizer’s payment details.'),
          const LegalBlock.li(
              'Participant names may be visible to other members of the session — for example on the order list or bill screens.'),
          const LegalBlock.li(
              'An organizer can export or email the order sheet (participant names, orders and remarks) — including to the restaurant.'),
          const LegalBlock.p(
              'Add only information you are comfortable sharing with that group, and join sessions only from people you trust.'),
        ]),
        LegalSection('5. Service providers we rely on', [
          const LegalBlock.p(
              'We use a small number of service providers ("data processors") to run the Service. They process data on our behalf:'),
          const LegalBlock.li(
              'Google — sign-in (Google account authentication) and email delivery (our emails are sent through Gmail).'),
          const LegalBlock.li(
              'Vercel — application hosting, the API, server logs, and storage of uploaded files (such as menu photos and DuitNow QR images).'),
          const LegalBlock.li('Turso — managed database hosting for the Service’s data.'),
          const LegalBlock.li(
              'Your browser’s push service (for example Google, Mozilla or Apple, depending on your browser) — delivers push notifications if you enable them.'),
          const LegalBlock.p(
              'We do not share your personal data with anyone else, except where required by law or to protect the Service and its users.'),
        ]),
        LegalSection('6. International transfers', [
          const LegalBlock.p(
              'Our providers may store and process data on servers located outside Malaysia. Where personal data is transferred outside Malaysia, we use reputable providers and take reasonable steps so that it remains protected in line with the PDPA and this notice.'),
        ]),
        LegalSection('7. Cookies and browser storage', [
          const LegalBlock.li(
              'The Service uses one essential cookie: a signed, HttpOnly session cookie that keeps you signed in. It is not used for advertising or analytics.'),
          const LegalBlock.li(
              'Your browser’s local storage holds preferences such as language and theme, and a service worker is registered if you enable push notifications.'),
          const LegalBlock.li(
              'If you block the session cookie, the Service cannot keep you signed in.'),
        ]),
        LegalSection('8. How we protect your data', [
          const LegalBlock.li(
              'All traffic uses HTTPS. Sign-in tokens are verified on our servers, and sessions use a signed, HttpOnly cookie.'),
          const LegalBlock.li(
              'Access rules ensure meal-session data is only shown to that session’s organizer and participants.'),
          const LegalBlock.li(
              'No online service can guarantee absolute security — please also keep your own Google account secure (we recommend two-factor authentication) and be careful who you share invite links with.'),
        ]),
        LegalSection('9. How long we keep data', [
          const LegalBlock.li('Account and profile data — for as long as your account exists.'),
          const LegalBlock.li(
              'Meal session data — until the organizer deletes the session, or the related account and data are deleted.'),
          const LegalBlock.li(
              'Push subscriptions — until you disable notifications on that device or your account is deleted.'),
          const LegalBlock.li(
              'When data is no longer needed for the purposes above, it is deleted. Copies may persist briefly in provider backups before being purged.'),
        ]),
        LegalSection('10. Your rights', [
          const LegalBlock.li(
              'Under the PDPA you may request access to and correction of your personal data, withdraw consent, and limit the processing of your data. We may need to verify your identity, and we will respond within the timeframes the law requires.'),
          const LegalBlock.li(
              'You can edit your profile and saved payment methods in the app, and organizers can delete their meal sessions in the app.'),
          const LegalBlock.li(
              'To delete your account and associated data, or to exercise any other right, contact us using the details below.'),
          const LegalBlock.li(
              'Withdrawing consent for data we need to run your account may mean we can no longer provide the Service to you.'),
          const LegalBlock.li(
              'If you are unsatisfied with our response, you may complain to Malaysia’s Personal Data Protection Commissioner (JPDP).'),
        ]),
        LegalSection('11. Children', [
          const LegalBlock.p(
              'The Service is not directed at children under 13. Users under 18 should use the Service only with the consent of a parent or guardian. We do not knowingly collect children’s data — if you believe a child has provided us personal data, contact us and we will remove it.'),
        ]),
        LegalSection('12. Changes to this notice', [
          const LegalBlock.p(
              'We may update this Privacy Policy from time to time. The "Last updated" date above shows the current version, and we will flag material changes in the Service.'),
        ]),
        LegalSection('13. Language', [
          const LegalBlock.p(
              'This notice is issued in English, Malay and Chinese. If there is any inconsistency between the versions, the English version prevails.'),
        ]),
        LegalSection('14. Contact', [
          LegalBlock.p(
              'To ask about privacy, exercise your rights, or request account deletion, email us at $kLegalContactEmail.'),
        ]),
      ],
    );

LegalDocument privacyMs() => LegalDocument(
      title: 'Dasar Privasi',
      updated: 'Kemas kini terakhir: 18 Julai 2026',
      intro: [
        'Dasar Privasi ini menerangkan cara pengendali MakanKira ("MakanKira", "kami") mengumpul, menggunakan, mendedahkan dan melindungi data peribadi anda apabila anda menggunakan aplikasi web MakanKira ("Perkhidmatan"), selaras dengan Akta Perlindungan Data Peribadi 2010 ("PDPA") Malaysia.',
        'Ringkasnya: kami hanya mengumpul apa yang diperlukan oleh Perkhidmatan untuk menganjurkan makan bersama, tiada iklan, dan kami tidak sesekali menjual data peribadi anda.',
      ],
      sections: [
        LegalSection('1. Siapa kami', [
          const LegalBlock.p(
              'Pengendali MakanKira ialah "pengguna data" (pengawal data) bagi data peribadi anda di bawah PDPA. Butiran hubungan terdapat dalam bahagian Hubungi Kami di bawah.'),
        ]),
        LegalSection('2. Data peribadi yang kami kumpul', [
          const LegalBlock.li(
              'Data akaun — apabila anda log masuk dengan Google: nama, alamat e-mel, gambar profil dan pengecam akaun Google anda.'),
          const LegalBlock.li(
              'Data profil — nama paparan, nombor telefon bimbit (pilihan) dan bahasa pilihan anda.'),
          const LegalBlock.li(
              'Butiran penerimaan bayaran yang anda simpan (biasanya sebagai penganjur): nama pemegang akaun, nama bank, nombor akaun, ID DuitNow, imej QR DuitNow yang dimuat naik dan arahan bayaran. Kami tidak sesekali meminta kata laluan perbankan dalam talian, nombor kad, PIN atau OTP.'),
          const LegalBlock.li(
              'Data sesi makan — butiran sesi (restoran, tarikh dan masa, tempat duduk), menu termasuk foto dan fail menu yang dimuat naik, pesanan dan catatan, nama peserta dan nombor telefon pilihan, jumlah bil dan pelarasan, serta rekod status bayaran.'),
          const LegalBlock.li(
              'Data yang diberikan oleh orang lain — penganjur mungkin memasukkan nama dan nombor telefon anda ke dalam sesi makan bagi pihak anda.'),
          const LegalBlock.li(
              'Data teknikal — kuki sesi log masuk; jika anda mengaktifkan pemberitahuan, langganan tolak (push) (titik akhir, kunci dan rentetan ejen pengguna pelayar); dan log pelayan asas (seperti alamat IP dan butiran permintaan) yang disimpan oleh pembekal pengehosan kami untuk keselamatan dan operasi.'),
          const LegalBlock.li(
              'Keutamaan setempat — pilihan bahasa dan tema anda disimpan dalam storan pelayar anda sendiri.'),
        ]),
        LegalSection('3. Cara kami menggunakan data anda', [
          const LegalBlock.li(
              'Untuk menyediakan Perkhidmatan — akaun dan log masuk, sesi makan, menu, pesanan, pengiraan bil, permintaan bayaran, dan paparan butiran bayaran penganjur kepada peserta sesi berkenaan.'),
          const LegalBlock.li(
              'Untuk menghantar pemberitahuan dan e-mel yang anda aktifkan atau yang dicetuskan oleh penganjur — seperti peringatan pesanan dan helaian pesanan restoran.'),
          const LegalBlock.li('Untuk mengingati keutamaan anda (bahasa dan tema).'),
          const LegalBlock.li(
              'Untuk memastikan Perkhidmatan selamat — mencegah penyalahgunaan, menyahpepijat dan menyelenggara log.'),
          const LegalBlock.li('Untuk mematuhi kewajipan undang-undang.'),
          const LegalBlock.p(
              'Kami tidak menjual data peribadi, dan Perkhidmatan tidak mengandungi iklan pihak ketiga atau penjejakan merentas laman.'),
        ]),
        LegalSection('4. Siapa yang melihat data anda dalam Perkhidmatan', [
          const LegalBlock.li(
              'Sesi makan ialah ruang yang dikongsi. Penganjur melihat nama, nombor telefon dan pesanan peserta. Peserta melihat menu, pesanan dan jumlah mereka sendiri, nama dan maklumat hubungan penganjur, serta butiran bayaran penganjur.'),
          const LegalBlock.li(
              'Nama peserta mungkin kelihatan kepada ahli lain dalam sesi itu — contohnya pada senarai pesanan atau skrin bil.'),
          const LegalBlock.li(
              'Penganjur boleh mengeksport atau menghantar helaian pesanan melalui e-mel (nama peserta, pesanan dan catatan) — termasuk kepada restoran.'),
          const LegalBlock.p(
              'Tambah hanya maklumat yang anda selesa kongsikan dengan kumpulan itu, dan sertai sesi hanya daripada orang yang anda percayai.'),
        ]),
        LegalSection('5. Pembekal perkhidmatan yang kami gunakan', [
          const LegalBlock.p(
              'Kami menggunakan sebilangan kecil pembekal perkhidmatan ("pemproses data") untuk menjalankan Perkhidmatan. Mereka memproses data bagi pihak kami:'),
          const LegalBlock.li(
              'Google — log masuk (pengesahan akaun Google) dan penghantaran e-mel (e-mel kami dihantar melalui Gmail).'),
          const LegalBlock.li(
              'Vercel — pengehosan aplikasi, API, log pelayan, dan storan fail yang dimuat naik (seperti foto menu dan imej QR DuitNow).'),
          const LegalBlock.li(
              'Turso — pengehosan pangkalan data terurus bagi data Perkhidmatan.'),
          const LegalBlock.li(
              'Perkhidmatan tolak pelayar anda (contohnya Google, Mozilla atau Apple, bergantung pada pelayar anda) — menghantar pemberitahuan tolak jika anda mengaktifkannya.'),
          const LegalBlock.p(
              'Kami tidak berkongsi data peribadi anda dengan sesiapa yang lain, kecuali jika dikehendaki oleh undang-undang atau untuk melindungi Perkhidmatan dan penggunanya.'),
        ]),
        LegalSection('6. Pemindahan antarabangsa', [
          const LegalBlock.p(
              'Pembekal kami mungkin menyimpan dan memproses data pada pelayan yang terletak di luar Malaysia. Apabila data peribadi dipindahkan ke luar Malaysia, kami menggunakan pembekal yang bereputasi dan mengambil langkah munasabah supaya ia terus dilindungi selaras dengan PDPA dan notis ini.'),
        ]),
        LegalSection('7. Kuki dan storan pelayar', [
          const LegalBlock.li(
              'Perkhidmatan menggunakan satu kuki penting: kuki sesi HttpOnly yang bertandatangan untuk mengekalkan log masuk anda. Ia tidak digunakan untuk pengiklanan atau analitik.'),
          const LegalBlock.li(
              'Storan setempat pelayar anda menyimpan keutamaan seperti bahasa dan tema, dan pekerja perkhidmatan (service worker) didaftarkan jika anda mengaktifkan pemberitahuan tolak.'),
          const LegalBlock.li(
              'Jika anda menyekat kuki sesi, Perkhidmatan tidak dapat mengekalkan log masuk anda.'),
        ]),
        LegalSection('8. Cara kami melindungi data anda', [
          const LegalBlock.li(
              'Semua trafik menggunakan HTTPS. Token log masuk disahkan pada pelayan kami, dan sesi menggunakan kuki HttpOnly yang bertandatangan.'),
          const LegalBlock.li(
              'Peraturan akses memastikan data sesi makan hanya dipaparkan kepada penganjur dan peserta sesi berkenaan.'),
          const LegalBlock.li(
              'Tiada perkhidmatan dalam talian yang dapat menjamin keselamatan mutlak — sila pastikan akaun Google anda juga selamat (kami syorkan pengesahan dua faktor) dan berhati-hati dengan siapa anda berkongsi pautan jemputan.'),
        ]),
        LegalSection('9. Tempoh kami menyimpan data', [
          const LegalBlock.li('Data akaun dan profil — selagi akaun anda wujud.'),
          const LegalBlock.li(
              'Data sesi makan — sehingga penganjur memadamkan sesi itu, atau akaun serta data berkaitan dipadamkan.'),
          const LegalBlock.li(
              'Langganan tolak — sehingga anda menyahaktifkan pemberitahuan pada peranti itu atau akaun anda dipadamkan.'),
          const LegalBlock.li(
              'Apabila data tidak lagi diperlukan bagi tujuan di atas, ia dipadamkan. Salinan mungkin kekal seketika dalam sandaran pembekal sebelum disingkirkan.'),
        ]),
        LegalSection('10. Hak anda', [
          const LegalBlock.li(
              'Di bawah PDPA, anda boleh memohon akses kepada dan pembetulan data peribadi anda, menarik balik persetujuan, dan mengehadkan pemprosesan data anda. Kami mungkin perlu mengesahkan identiti anda, dan kami akan memberi maklum balas dalam tempoh yang dikehendaki oleh undang-undang.'),
          const LegalBlock.li(
              'Anda boleh menyunting profil dan kaedah bayaran yang disimpan dalam aplikasi, dan penganjur boleh memadamkan sesi makan mereka dalam aplikasi.'),
          const LegalBlock.li(
              'Untuk memadamkan akaun anda serta data berkaitan, atau untuk melaksanakan apa-apa hak lain, hubungi kami menggunakan butiran di bawah.'),
          const LegalBlock.li(
              'Penarikan balik persetujuan bagi data yang kami perlukan untuk mengendalikan akaun anda mungkin bermakna kami tidak lagi dapat menyediakan Perkhidmatan kepada anda.'),
          const LegalBlock.li(
              'Jika anda tidak berpuas hati dengan maklum balas kami, anda boleh membuat aduan kepada Pesuruhjaya Perlindungan Data Peribadi Malaysia (JPDP).'),
        ]),
        LegalSection('11. Kanak-kanak', [
          const LegalBlock.p(
              'Perkhidmatan tidak ditujukan kepada kanak-kanak bawah 13 tahun. Pengguna bawah 18 tahun hanya patut menggunakan Perkhidmatan dengan persetujuan ibu bapa atau penjaga. Kami tidak dengan sengaja mengumpul data kanak-kanak — jika anda percaya seorang kanak-kanak telah memberikan data peribadi kepada kami, hubungi kami dan kami akan memadamkannya.'),
        ]),
        LegalSection('12. Perubahan pada notis ini', [
          const LegalBlock.p(
              'Kami boleh mengemas kini Dasar Privasi ini dari semasa ke semasa. Tarikh "Kemas kini terakhir" di atas menunjukkan versi semasa, dan kami akan menandakan perubahan material dalam Perkhidmatan.'),
        ]),
        LegalSection('13. Bahasa', [
          const LegalBlock.p(
              'Notis ini dikeluarkan dalam bahasa Inggeris, Melayu dan Cina. Jika terdapat percanggahan antara versi, versi bahasa Inggeris diguna pakai.'),
        ]),
        LegalSection('14. Hubungi kami', [
          LegalBlock.p(
              'Untuk pertanyaan privasi, pelaksanaan hak anda, atau permohonan pemadaman akaun, e-mel kami di $kLegalContactEmail.'),
        ]),
      ],
    );

LegalDocument privacyZh() => LegalDocument(
      title: '隐私政策',
      updated: '最后更新：2026年7月18日',
      intro: [
        '本隐私政策说明 MakanKira 运营者（“MakanKira”、“我们”）在您使用 MakanKira 网页应用（“本服务”）时，如何依照马来西亚《2010年个人资料保护法》（“PDPA”）收集、使用、披露和保护您的个人资料。',
        '简而言之：我们只收集组织聚餐所必需的信息，不投放广告，也绝不出售您的个人资料。',
      ],
      sections: [
        LegalSection('1. 我们是谁', [
          const LegalBlock.p(
              '就 PDPA 而言，MakanKira 的运营者是您个人资料的“资料使用者”（即数据控制者）。联系方式见下方“联系我们”一节。'),
        ]),
        LegalSection('2. 我们收集的个人资料', [
          const LegalBlock.li(
              '账号资料 — 您使用 Google 登录时：姓名、电子邮箱、头像及 Google 账号标识符。'),
          const LegalBlock.li('个人资料 — 显示名称、手机号码（选填）和首选语言。'),
          const LegalBlock.li(
              '您保存的收款信息（通常作为组织者）：账户持有人姓名、银行名称、账号、DuitNow ID、上传的 DuitNow 二维码图片及付款说明。我们绝不会索取网上银行密码、银行卡号、PIN 或 OTP。'),
          const LegalBlock.li(
              '聚餐资料 — 聚餐详情（餐厅、日期时间、座位）、菜单（包括上传的菜单照片和文件）、点单及备注、参与者姓名及选填的手机号码、账单金额及调整，以及付款状态记录。'),
          const LegalBlock.li(
              '他人提供的资料 — 组织者可能代您将您的姓名和电话号码填入某次聚餐。'),
          const LegalBlock.li(
              '技术资料 — 登录会话 Cookie；若您开启通知，还包括推送订阅（端点、密钥和浏览器 User-Agent）；以及托管服务商出于安全和运维目的保存的基础服务器日志（如 IP 地址和请求信息）。'),
          const LegalBlock.li('本地偏好 — 您的语言和主题选择保存在您自己浏览器的存储中。'),
        ]),
        LegalSection('3. 我们如何使用您的资料', [
          const LegalBlock.li(
              '提供本服务 — 账号与登录、聚餐、菜单、点单、账单计算、付款请求，以及向该聚餐的参与者展示组织者的收款信息。'),
          const LegalBlock.li(
              '发送您开启的或由组织者触发的通知和邮件 — 例如点单提醒和餐厅点单汇总表。'),
          const LegalBlock.li('记住您的偏好（语言和主题）。'),
          const LegalBlock.li('保障服务安全 — 防止滥用、排查故障并维护日志。'),
          const LegalBlock.li('履行法律义务。'),
          const LegalBlock.p('我们不出售个人资料，本服务也不含第三方广告或跨站跟踪。'),
        ]),
        LegalSection('4. 谁能在本服务内看到您的资料', [
          const LegalBlock.li(
              '聚餐是共享空间。组织者可以看到参与者的姓名、联系电话和点单；参与者可以看到菜单、自己的点单和金额、组织者的姓名和联系方式，以及组织者的收款信息。'),
          const LegalBlock.li(
              '参与者姓名可能对该聚餐的其他成员可见，例如出现在点单列表或账单页面上。'),
          const LegalBlock.li(
              '组织者可以导出点单汇总表（含参与者姓名、点单和备注）或通过邮件发送，包括发送给餐厅。'),
          const LegalBlock.p('请只填写您愿意与该群组分享的信息，并只加入您信任的人的聚餐。'),
        ]),
        LegalSection('5. 我们使用的服务商', [
          const LegalBlock.p(
              '我们使用少量服务商（“资料处理者”）来运行本服务，它们代表我们处理数据：'),
          const LegalBlock.li(
              'Google — 登录（Google 账号验证）和邮件发送（我们的邮件通过 Gmail 发出）。'),
          const LegalBlock.li(
              'Vercel — 应用托管、API、服务器日志，以及上传文件的存储（如菜单照片和 DuitNow 二维码图片）。'),
          const LegalBlock.li('Turso — 本服务数据的托管数据库。'),
          const LegalBlock.li(
              '您浏览器的推送服务（视浏览器而定，例如 Google、Mozilla 或 Apple）— 在您开启推送通知时负责送达。'),
          const LegalBlock.p(
              '除法律要求或为保护本服务及其用户外，我们不会与其他任何人分享您的个人资料。'),
        ]),
        LegalSection('6. 跨境传输', [
          const LegalBlock.p(
              '我们的服务商可能在马来西亚境外的服务器上存储和处理数据。当个人资料被传输至马来西亚境外时，我们会选择信誉良好的服务商并采取合理措施，使其依照 PDPA 和本政策继续受到保护。'),
        ]),
        LegalSection('7. Cookie 与浏览器存储', [
          const LegalBlock.li(
              '本服务只使用一个必要 Cookie：经签名的 HttpOnly 会话 Cookie，用于保持您的登录状态，不用于广告或分析。'),
          const LegalBlock.li(
              '浏览器本地存储保存语言、主题等偏好；若您开启推送通知，还会注册一个 Service Worker。'),
          const LegalBlock.li('如果您屏蔽会话 Cookie，本服务将无法保持您的登录状态。'),
        ]),
        LegalSection('8. 我们如何保护您的资料', [
          const LegalBlock.li(
              '全部流量均使用 HTTPS。登录令牌在我们的服务器上验证，会话使用经签名的 HttpOnly Cookie。'),
          const LegalBlock.li('访问规则确保聚餐数据仅对该聚餐的组织者和参与者可见。'),
          const LegalBlock.li(
              '任何在线服务都无法保证绝对安全 — 请同时保管好您的 Google 账号（建议开启两步验证），并谨慎选择邀请链接的分享对象。'),
        ]),
        LegalSection('9. 资料保存期限', [
          const LegalBlock.li('账号和个人资料 — 在您的账号存续期间保存。'),
          const LegalBlock.li('聚餐资料 — 保存至组织者删除该聚餐，或相关账号及数据被删除。'),
          const LegalBlock.li('推送订阅 — 保存至您在该设备上关闭通知或账号被删除。'),
          const LegalBlock.li(
              '当资料不再为上述目的所需要时即被删除。副本可能会在服务商备份中短暂留存后清除。'),
        ]),
        LegalSection('10. 您的权利', [
          const LegalBlock.li(
              '根据 PDPA，您可以申请查阅和更正您的个人资料、撤回同意，以及限制对您资料的处理。我们可能需要核实您的身份，并将在法律要求的期限内答复。'),
          const LegalBlock.li(
              '您可以在应用内编辑个人资料和已保存的收款方式；组织者可以在应用内删除自己的聚餐。'),
          const LegalBlock.li(
              '如需删除账号及相关数据，或行使其他权利，请通过下方联系方式与我们联系。'),
          const LegalBlock.li(
              '若您撤回我们运行您账号所必需的资料的同意，我们可能无法继续为您提供本服务。'),
          const LegalBlock.li(
              '如果您对我们的答复不满意，可以向马来西亚个人资料保护专员（JPDP）投诉。'),
        ]),
        LegalSection('11. 儿童', [
          const LegalBlock.p(
              '本服务不面向 13 岁以下儿童。18 岁以下用户应在父母或监护人同意下使用本服务。我们不会有意收集儿童资料 — 如果您认为有儿童向我们提供了个人资料，请联系我们，我们会予以删除。'),
        ]),
        LegalSection('12. 本政策的变更', [
          const LegalBlock.p(
              '我们可能不时更新本隐私政策。上方的“最后更新”日期即为当前版本；重大变更会在本服务中提示。'),
        ]),
        LegalSection('13. 语言', [
          const LegalBlock.p(
              '本政策以英文、马来文和中文发布。如各版本之间存在不一致，以英文版本为准。'),
        ]),
        LegalSection('14. 联系我们', [
          LegalBlock.p(
              '如有隐私相关问题、需要行使权利或申请删除账号，请发送邮件至 $kLegalContactEmail。'),
        ]),
      ],
    );
