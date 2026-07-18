import 'legal_document.dart';

/// Terms of Service — full text in the three app languages.
///
/// Drafted for what MakanKira actually is: a free Malaysian shared-meal
/// organizer that CALCULATES who owes what but never touches money. The
/// load-bearing clauses are §3 (not a payment service), §5 (invite-link
/// visibility) and §6 (consent when entering other people's details).
/// The English version is the master; MS/ZH mirror it section-for-section
/// and the prevailing-language clause lives in §17.

LegalDocument termsEn() => LegalDocument(
      title: 'Terms of Service',
      updated: 'Last updated: 18 July 2026',
      intro: [
        'Welcome to MakanKira. These Terms of Service ("Terms") are an agreement between you and the operator of MakanKira ("MakanKira", "we", "us" or "our"), and they govern your use of the MakanKira web application and related services (the "Service").',
        'By signing in to or using the Service, you agree to these Terms and to our Privacy Policy. If you do not agree, please do not use the Service.',
      ],
      sections: [
        LegalSection('1. About the Service', [
          const LegalBlock.p(
              'MakanKira helps a group organize a shared meal. An organizer creates a meal session, shares the menu, collects everyone’s orders and records the final bill, and the Service calculates how much each participant owes. Payment is then made directly between participants and the organizer — for example by DuitNow or bank transfer.'),
          const LegalBlock.p(
              'The Service is provided free of charge for personal, non-commercial use. It is designed primarily for users in Malaysia, and amounts are shown in Malaysian Ringgit (RM).'),
        ]),
        LegalSection('2. Your account', [
          const LegalBlock.li(
              'You sign in with a Google account, which is the only sign-in method. By signing in, you authorize us to receive your basic Google profile information (name, email address and profile photo).'),
          const LegalBlock.li('Keep the information in your profile accurate and up to date.'),
          const LegalBlock.li(
              'You are responsible for activity that happens under your account and for keeping your Google account secure. Tell us promptly if you believe your account has been used without your permission.'),
          const LegalBlock.li(
              'You must be at least 18 years old to use the Service, or at least 13 with the consent and supervision of a parent or guardian who agrees to these Terms on your behalf.'),
        ]),
        LegalSection('3. MakanKira is not a payment service', [
          const LegalBlock.p('This section is important — please read it carefully.'),
          const LegalBlock.li(
              'MakanKira only calculates and records who owes what. We do not hold, receive, transfer, process or settle money, and we have no access to anyone’s funds.'),
          const LegalBlock.li(
              'All payments are made directly between participants and organizers, outside the Service — for example by DuitNow transfer, bank transfer or cash. We are not a party to those payments.'),
          const LegalBlock.li(
              'We are not a bank, e-money issuer, remittance provider or payment system operator, and we are not licensed or regulated by Bank Negara Malaysia. Nothing in the Service is financial advice.'),
          const LegalBlock.li(
              'Payment details shown in a meal session (bank account, DuitNow ID, QR code and similar) are entered by the organizer. Always verify the payment details and the amount before transferring money. We are not responsible for payments made to a wrong account or based on incorrect details.'),
          const LegalBlock.li(
              'Marking an amount as "paid" in the Service is a record-keeping feature only. It does not prove that a transfer actually took place.'),
          const LegalBlock.li(
              'Any dispute about amounts owed, payments made or refunds is a matter between the organizer and the participants involved.'),
        ]),
        LegalSection('4. Organizers and participants', [
          const LegalBlock.li(
              'Organizers are responsible for the accuracy of the menu, prices, the final bill and any tax, service charge, discount or claim adjustments, as well as their own payment details — and for handling participants’ information responsibly.'),
          const LegalBlock.li(
              'Participants are responsible for their own orders and remarks, and for paying the organizer what they owe.'),
          const LegalBlock.li(
              'Calculations are only as accurate as the numbers entered. We do not verify bills, receipts or prices, and estimated menu prices may differ from the restaurant’s final prices.'),
        ]),
        LegalSection('5. Invite links', [
          const LegalBlock.li(
              'Participants join a meal session through an invite link. Anyone who has the link can open it and, after signing in, join the session and see its details — including the menu, participant names, amounts and the organizer’s payment details.'),
          const LegalBlock.li(
              'Share invite links only with the people you intend to invite. We are not responsible for access that results from a link being forwarded beyond the intended group.'),
        ]),
        LegalSection('6. Your content', [
          const LegalBlock.li(
              'You and your participants provide the content in a meal session: menus, menu photos and files, orders and remarks, names and contact numbers, payment receiving details and notes ("your content").'),
          const LegalBlock.li(
              'Your content remains yours. You grant us a non-exclusive, worldwide, royalty-free licence to host, store, process, display and transmit it solely to operate, maintain and improve the Service.'),
          const LegalBlock.li(
              'You are responsible for your content. When you enter another person’s information (for example a participant’s name and phone number), you confirm that you have their permission to share it with us and with the other members of that meal session.'),
          const LegalBlock.li(
              'Only upload material you are allowed to share. Restaurant menus, logos and trade marks belong to their owners; upload them only as a reference for your group’s ordering.'),
          const LegalBlock.li(
              'We may remove content that we reasonably believe breaks these Terms or the law.'),
        ]),
        LegalSection('7. Acceptable use', [
          const LegalBlock.p('You agree not to:'),
          const LegalBlock.li(
              'use the Service for anything unlawful, fraudulent or misleading — including fake payment requests or misrepresenting amounts owed;'),
          const LegalBlock.li(
              'upload malicious code, or probe, overload or disrupt the Service or its infrastructure;'),
          const LegalBlock.li(
              'attempt to access other users’ data or sessions without permission;'),
          const LegalBlock.li(
              'scrape, bulk-extract, resell or commercially exploit the Service or its data;'),
          const LegalBlock.li('impersonate any person, or use the Service to send spam.'),
          const LegalBlock.p('We may suspend or terminate accounts that break these rules.'),
        ]),
        LegalSection('8. Notifications and email', [
          const LegalBlock.li(
              'The Service can send browser push notifications and emails, such as order reminders and order sheets. You control push notifications through your browser settings and the in-app notification settings, and reminders per meal session.'),
          const LegalBlock.li(
              'Delivery of notifications and emails is not guaranteed. Do not rely on them as your only reminder to order or pay.'),
        ]),
        LegalSection('9. Third-party services', [
          const LegalBlock.li(
              'Signing in is provided by Google and subject to Google’s own terms. Hosting, storage, database and email delivery are provided by our infrastructure providers, described in the Privacy Policy.'),
          const LegalBlock.li(
              'Payments between users are handled entirely by banks and payment apps (such as DuitNow) under their own terms. Menu links added by users lead to external sites we do not control or endorse.'),
          const LegalBlock.li('We are not responsible for third-party services.'),
        ]),
        LegalSection('10. Intellectual property', [
          const LegalBlock.li(
              'The Service — including its software, design, logo and the MakanKira name — belongs to us or our licensors. We grant you a personal, non-exclusive, non-transferable, revocable right to use the Service under these Terms.'),
          const LegalBlock.li(
              'Open-source components included in the Service remain under their own licences.'),
          const LegalBlock.li(
              'If you send us feedback or suggestions, we may use them to improve the Service without any obligation to you.'),
        ]),
        LegalSection('11. Availability, changes and termination', [
          const LegalBlock.li(
              'The Service is a free product and is provided "as available". We may add, change or remove features, or suspend or discontinue the Service. Where a change materially reduces the Service, we will make reasonable efforts to give advance notice in the app so you can export your data.'),
          const LegalBlock.li(
              'You may stop using the Service at any time and may request deletion of your account and data as described in the Privacy Policy.'),
          const LegalBlock.li(
              'We may suspend or terminate your access if you materially breach these Terms, use the Service unlawfully, or put the Service or other users at risk.'),
        ]),
        LegalSection('12. Disclaimers', [
          const LegalBlock.li(
              'To the maximum extent permitted by law, the Service is provided "as is" and "as available", without warranties of any kind — including that it will be uninterrupted or error-free, or that calculations will always be correct.'),
          const LegalBlock.li(
              'Always verify final amounts before paying or requesting payment. The Service does not provide financial, tax, accounting or legal advice; features such as company-claim splitting are conveniences, not advice.'),
        ]),
        LegalSection('13. Limitation of liability', [
          const LegalBlock.li(
              'To the maximum extent permitted by law, we are not liable for indirect or consequential loss, loss of profits, data or goodwill, or for payments made between users, user content, or third-party services.'),
          const LegalBlock.li(
              'To the maximum extent permitted by law, our total aggregate liability for all claims relating to the Service is limited to RM100, or the amount you paid us for the Service in the past 12 months (currently zero), whichever is greater.'),
          const LegalBlock.li(
              'Nothing in these Terms excludes or limits liability that cannot be excluded under applicable law, including under the Consumer Protection Act 1999 where it applies.'),
        ]),
        LegalSection('14. Indemnity', [
          const LegalBlock.p(
              'To the extent permitted by law, you agree to indemnify us against claims by third parties (including other users) that arise from your content, from your use of the Service in breach of these Terms, or from your violation of any law or the rights of another person.'),
        ]),
        LegalSection('15. Changes to these Terms', [
          const LegalBlock.p(
              'We may update these Terms from time to time. The "Last updated" date above shows the current version. For material changes we will give notice in the Service; your continued use after a change takes effect means you accept the updated Terms.'),
        ]),
        LegalSection('16. Governing law', [
          const LegalBlock.p(
              'These Terms are governed by the laws of Malaysia, and the courts of Malaysia have jurisdiction over any dispute — though we would appreciate the chance to resolve any issue informally first, so please contact us.'),
        ]),
        LegalSection('17. General', [
          const LegalBlock.li(
              'These Terms, together with the Privacy Policy, are the entire agreement between you and us about the Service.'),
          const LegalBlock.li(
              'If part of these Terms is found unenforceable, the rest remains in effect. If we do not enforce a provision, that is not a waiver.'),
          const LegalBlock.li(
              'You may not transfer your rights under these Terms. We may transfer ours to a successor operator of the Service, with notice to you.'),
          const LegalBlock.li(
              'These Terms are published in English, Malay and Chinese. If the versions are inconsistent, the English version prevails.'),
        ]),
        LegalSection('18. Contact', [
          LegalBlock.p('Questions about these Terms: $kLegalContactEmail.'),
        ]),
      ],
    );

LegalDocument termsMs() => LegalDocument(
      title: 'Terma Perkhidmatan',
      updated: 'Kemas kini terakhir: 18 Julai 2026',
      intro: [
        'Selamat datang ke MakanKira. Terma Perkhidmatan ini ("Terma") merupakan perjanjian antara anda dengan pengendali MakanKira ("MakanKira", "kami"), dan ia mengawal penggunaan aplikasi web MakanKira serta perkhidmatan berkaitan ("Perkhidmatan").',
        'Dengan log masuk atau menggunakan Perkhidmatan, anda bersetuju dengan Terma ini dan Dasar Privasi kami. Jika anda tidak bersetuju, sila jangan gunakan Perkhidmatan.',
      ],
      sections: [
        LegalSection('1. Tentang Perkhidmatan', [
          const LegalBlock.p(
              'MakanKira membantu kumpulan menganjurkan makan bersama. Penganjur mewujudkan sesi makan, berkongsi menu, mengumpul pesanan semua orang dan merekodkan bil akhir, dan Perkhidmatan mengira jumlah yang perlu dibayar oleh setiap peserta. Bayaran kemudiannya dibuat secara terus antara peserta dan penganjur — contohnya melalui DuitNow atau pindahan bank.'),
          const LegalBlock.p(
              'Perkhidmatan disediakan secara percuma untuk kegunaan peribadi dan bukan komersial. Ia direka terutamanya untuk pengguna di Malaysia, dan jumlah dipaparkan dalam Ringgit Malaysia (RM).'),
        ]),
        LegalSection('2. Akaun anda', [
          const LegalBlock.li(
              'Anda log masuk dengan akaun Google, iaitu satu-satunya kaedah log masuk. Dengan log masuk, anda membenarkan kami menerima maklumat asas profil Google anda (nama, alamat e-mel dan gambar profil).'),
          const LegalBlock.li('Pastikan maklumat dalam profil anda tepat dan terkini.'),
          const LegalBlock.li(
              'Anda bertanggungjawab atas aktiviti di bawah akaun anda dan atas keselamatan akaun Google anda. Maklumkan kami dengan segera jika anda percaya akaun anda telah digunakan tanpa kebenaran.'),
          const LegalBlock.li(
              'Anda mestilah berumur sekurang-kurangnya 18 tahun untuk menggunakan Perkhidmatan, atau sekurang-kurangnya 13 tahun dengan kebenaran dan pengawasan ibu bapa atau penjaga yang bersetuju dengan Terma ini bagi pihak anda.'),
        ]),
        LegalSection('3. MakanKira bukan perkhidmatan pembayaran', [
          const LegalBlock.p('Bahagian ini penting — sila baca dengan teliti.'),
          const LegalBlock.li(
              'MakanKira hanya mengira dan merekodkan jumlah yang perlu dibayar oleh setiap orang. Kami tidak memegang, menerima, memindahkan, memproses atau menyelesaikan wang, dan kami tiada akses kepada dana sesiapa.'),
          const LegalBlock.li(
              'Semua bayaran dibuat secara terus antara peserta dan penganjur, di luar Perkhidmatan — contohnya melalui pindahan DuitNow, pindahan bank atau tunai. Kami bukan pihak dalam bayaran tersebut.'),
          const LegalBlock.li(
              'Kami bukan bank, pengeluar e-wang, penyedia kiriman wang atau pengendali sistem pembayaran, dan kami tidak dilesenkan atau dikawal selia oleh Bank Negara Malaysia. Tiada apa-apa dalam Perkhidmatan yang merupakan nasihat kewangan.'),
          const LegalBlock.li(
              'Butiran bayaran yang dipaparkan dalam sesi makan (akaun bank, ID DuitNow, kod QR dan seumpamanya) dimasukkan oleh penganjur. Sentiasa sahkan butiran bayaran dan jumlah sebelum memindahkan wang. Kami tidak bertanggungjawab atas bayaran yang dibuat ke akaun yang salah atau berdasarkan butiran yang tidak tepat.'),
          const LegalBlock.li(
              'Menandakan sesuatu jumlah sebagai "dibayar" dalam Perkhidmatan hanyalah ciri penyimpanan rekod. Ia tidak membuktikan bahawa pemindahan benar-benar berlaku.'),
          const LegalBlock.li(
              'Sebarang pertikaian tentang jumlah terhutang, bayaran yang dibuat atau bayaran balik adalah urusan antara penganjur dan peserta yang berkenaan.'),
        ]),
        LegalSection('4. Penganjur dan peserta', [
          const LegalBlock.li(
              'Penganjur bertanggungjawab atas ketepatan menu, harga, bil akhir dan sebarang pelarasan cukai, caj perkhidmatan, diskaun atau tuntutan, serta butiran bayaran mereka sendiri — dan atas pengendalian maklumat peserta secara bertanggungjawab.'),
          const LegalBlock.li(
              'Peserta bertanggungjawab atas pesanan dan catatan mereka sendiri, serta membayar jumlah yang terhutang kepada penganjur.'),
          const LegalBlock.li(
              'Pengiraan hanya setepat angka yang dimasukkan. Kami tidak mengesahkan bil, resit atau harga, dan harga anggaran menu mungkin berbeza daripada harga akhir restoran.'),
        ]),
        LegalSection('5. Pautan jemputan', [
          const LegalBlock.li(
              'Peserta menyertai sesi makan melalui pautan jemputan. Sesiapa yang mempunyai pautan itu boleh membukanya dan, selepas log masuk, menyertai sesi serta melihat butirannya — termasuk menu, nama peserta, jumlah dan butiran bayaran penganjur.'),
          const LegalBlock.li(
              'Kongsi pautan jemputan hanya dengan orang yang anda ingin jemput. Kami tidak bertanggungjawab atas akses yang berlaku akibat pautan dipanjangkan di luar kumpulan yang dimaksudkan.'),
        ]),
        LegalSection('6. Kandungan anda', [
          const LegalBlock.li(
              'Anda dan peserta anda membekalkan kandungan dalam sesi makan: menu, foto dan fail menu, pesanan dan catatan, nama dan nombor telefon, butiran penerimaan bayaran serta nota ("kandungan anda").'),
          const LegalBlock.li(
              'Kandungan anda kekal milik anda. Anda memberi kami lesen tidak eksklusif, seluruh dunia dan bebas royalti untuk menghos, menyimpan, memproses, memaparkan dan menghantarnya semata-mata untuk mengendalikan, menyenggara dan menambah baik Perkhidmatan.'),
          const LegalBlock.li(
              'Anda bertanggungjawab atas kandungan anda. Apabila anda memasukkan maklumat orang lain (contohnya nama dan nombor telefon peserta), anda mengesahkan bahawa anda mempunyai kebenaran mereka untuk berkongsi maklumat itu dengan kami dan dengan ahli lain sesi makan tersebut.'),
          const LegalBlock.li(
              'Muat naik hanya bahan yang anda dibenarkan berkongsi. Menu, logo dan tanda dagangan restoran adalah milik pemiliknya; muat naiknya hanya sebagai rujukan pesanan kumpulan anda.'),
          const LegalBlock.li(
              'Kami boleh mengalih keluar kandungan yang kami percaya secara munasabah melanggar Terma ini atau undang-undang.'),
        ]),
        LegalSection('7. Penggunaan yang dibenarkan', [
          const LegalBlock.p('Anda bersetuju untuk tidak:'),
          const LegalBlock.li(
              'menggunakan Perkhidmatan untuk apa-apa yang menyalahi undang-undang, bersifat penipuan atau mengelirukan — termasuk permintaan bayaran palsu atau menyalahnyatakan jumlah terhutang;'),
          const LegalBlock.li(
              'memuat naik kod berniat jahat, atau menduga, membebankan atau mengganggu Perkhidmatan atau infrastrukturnya;'),
          const LegalBlock.li(
              'cuba mengakses data atau sesi pengguna lain tanpa kebenaran;'),
          const LegalBlock.li(
              'mengikis (scrape), mengekstrak secara pukal, menjual semula atau mengeksploitasi Perkhidmatan atau datanya secara komersial;'),
          const LegalBlock.li(
              'menyamar sebagai mana-mana individu, atau menggunakan Perkhidmatan untuk menghantar spam.'),
          const LegalBlock.p(
              'Kami boleh menggantung atau menamatkan akaun yang melanggar peraturan ini.'),
        ]),
        LegalSection('8. Pemberitahuan dan e-mel', [
          const LegalBlock.li(
              'Perkhidmatan boleh menghantar pemberitahuan tolak (push) pelayar dan e-mel, seperti peringatan pesanan dan helaian pesanan. Anda mengawal pemberitahuan tolak melalui tetapan pelayar dan tetapan pemberitahuan dalam aplikasi, serta peringatan bagi setiap sesi makan.'),
          const LegalBlock.li(
              'Penghantaran pemberitahuan dan e-mel tidak dijamin. Jangan bergantung padanya sebagai satu-satunya peringatan untuk memesan atau membayar.'),
        ]),
        LegalSection('9. Perkhidmatan pihak ketiga', [
          const LegalBlock.li(
              'Log masuk disediakan oleh Google dan tertakluk pada terma Google sendiri. Pengehosan, storan, pangkalan data dan penghantaran e-mel disediakan oleh pembekal infrastruktur kami, seperti yang diterangkan dalam Dasar Privasi.'),
          const LegalBlock.li(
              'Bayaran antara pengguna dikendalikan sepenuhnya oleh bank dan aplikasi pembayaran (seperti DuitNow) di bawah terma masing-masing. Pautan menu yang ditambah oleh pengguna menuju ke laman luaran yang tidak kami kawal atau sokong.'),
          const LegalBlock.li('Kami tidak bertanggungjawab atas perkhidmatan pihak ketiga.'),
        ]),
        LegalSection('10. Harta intelek', [
          const LegalBlock.li(
              'Perkhidmatan — termasuk perisian, reka bentuk, logo dan nama MakanKira — adalah milik kami atau pemberi lesen kami. Kami memberi anda hak peribadi, tidak eksklusif, tidak boleh pindah milik dan boleh dibatalkan untuk menggunakan Perkhidmatan menurut Terma ini.'),
          const LegalBlock.li(
              'Komponen sumber terbuka dalam Perkhidmatan kekal di bawah lesen masing-masing.'),
          const LegalBlock.li(
              'Jika anda menghantar maklum balas atau cadangan, kami boleh menggunakannya untuk menambah baik Perkhidmatan tanpa sebarang kewajipan kepada anda.'),
        ]),
        LegalSection('11. Ketersediaan, perubahan dan penamatan', [
          const LegalBlock.li(
              'Perkhidmatan ialah produk percuma dan disediakan "sebagaimana tersedia". Kami boleh menambah, mengubah atau membuang ciri, atau menggantung atau memberhentikan Perkhidmatan. Jika sesuatu perubahan mengurangkan Perkhidmatan secara material, kami akan berusaha secara munasabah untuk memberi notis awal dalam aplikasi supaya anda boleh mengeksport data anda.'),
          const LegalBlock.li(
              'Anda boleh berhenti menggunakan Perkhidmatan pada bila-bila masa dan boleh memohon pemadaman akaun serta data anda seperti yang diterangkan dalam Dasar Privasi.'),
          const LegalBlock.li(
              'Kami boleh menggantung atau menamatkan akses anda jika anda melanggar Terma ini secara material, menggunakan Perkhidmatan secara menyalahi undang-undang, atau membahayakan Perkhidmatan atau pengguna lain.'),
        ]),
        LegalSection('12. Penafian', [
          const LegalBlock.li(
              'Setakat maksimum yang dibenarkan oleh undang-undang, Perkhidmatan disediakan "seadanya" dan "sebagaimana tersedia", tanpa sebarang jaminan — termasuk jaminan bahawa ia tidak akan terganggu atau bebas ralat, atau bahawa pengiraan sentiasa betul.'),
          const LegalBlock.li(
              'Sentiasa sahkan jumlah akhir sebelum membayar atau meminta bayaran. Perkhidmatan tidak memberikan nasihat kewangan, cukai, perakaunan atau undang-undang; ciri seperti pembahagian tuntutan syarikat adalah kemudahan, bukan nasihat.'),
        ]),
        LegalSection('13. Had liabiliti', [
          const LegalBlock.li(
              'Setakat maksimum yang dibenarkan oleh undang-undang, kami tidak bertanggungjawab atas kerugian tidak langsung atau berbangkit, kehilangan keuntungan, data atau nama baik, atau atas bayaran antara pengguna, kandungan pengguna, atau perkhidmatan pihak ketiga.'),
          const LegalBlock.li(
              'Setakat maksimum yang dibenarkan oleh undang-undang, jumlah agregat liabiliti kami bagi semua tuntutan berkaitan Perkhidmatan adalah terhad kepada RM100, atau jumlah yang anda bayar kepada kami untuk Perkhidmatan dalam tempoh 12 bulan yang lalu (buat masa ini sifar), mengikut mana-mana yang lebih tinggi.'),
          const LegalBlock.li(
              'Tiada apa-apa dalam Terma ini yang mengecualikan atau mengehadkan liabiliti yang tidak boleh dikecualikan di bawah undang-undang terpakai, termasuk di bawah Akta Perlindungan Pengguna 1999 jika berkenaan.'),
        ]),
        LegalSection('14. Tanggung rugi', [
          const LegalBlock.p(
              'Setakat yang dibenarkan oleh undang-undang, anda bersetuju untuk menanggung rugi kami terhadap tuntutan pihak ketiga (termasuk pengguna lain) yang timbul daripada kandungan anda, daripada penggunaan Perkhidmatan oleh anda yang melanggar Terma ini, atau daripada pelanggaran mana-mana undang-undang atau hak orang lain oleh anda.'),
        ]),
        LegalSection('15. Perubahan pada Terma ini', [
          const LegalBlock.p(
              'Kami boleh mengemas kini Terma ini dari semasa ke semasa. Tarikh "Kemas kini terakhir" di atas menunjukkan versi semasa. Bagi perubahan material, kami akan memberi notis dalam Perkhidmatan; penggunaan berterusan anda selepas perubahan berkuat kuasa bermakna anda menerima Terma yang dikemas kini.'),
        ]),
        LegalSection('16. Undang-undang yang mentadbir', [
          const LegalBlock.p(
              'Terma ini ditadbir oleh undang-undang Malaysia, dan mahkamah Malaysia mempunyai bidang kuasa atas sebarang pertikaian — namun kami menghargai peluang untuk menyelesaikan sebarang isu secara tidak formal terlebih dahulu, jadi sila hubungi kami.'),
        ]),
        LegalSection('17. Am', [
          const LegalBlock.li(
              'Terma ini, bersama-sama Dasar Privasi, merupakan keseluruhan perjanjian antara anda dan kami mengenai Perkhidmatan.'),
          const LegalBlock.li(
              'Jika mana-mana bahagian Terma ini didapati tidak boleh dikuatkuasakan, bahagian yang selebihnya kekal berkuat kuasa. Jika kami tidak menguatkuasakan sesuatu peruntukan, ia bukanlah penepian.'),
          const LegalBlock.li(
              'Anda tidak boleh memindahkan hak anda di bawah Terma ini. Kami boleh memindahkan hak kami kepada pengendali pengganti Perkhidmatan, dengan notis kepada anda.'),
          const LegalBlock.li(
              'Terma ini diterbitkan dalam bahasa Inggeris, Melayu dan Cina. Jika terdapat percanggahan antara versi, versi bahasa Inggeris diguna pakai.'),
        ]),
        LegalSection('18. Hubungi kami', [
          LegalBlock.p('Soalan mengenai Terma ini: $kLegalContactEmail.'),
        ]),
      ],
    );

LegalDocument termsZh() => LegalDocument(
      title: '服务条款',
      updated: '最后更新：2026年7月18日',
      intro: [
        '欢迎使用 MakanKira。本服务条款（“本条款”）是您与 MakanKira 运营者（“MakanKira”、“我们”）之间的协议，约束您对 MakanKira 网页应用及相关服务（“本服务”）的使用。',
        '登录或使用本服务，即表示您同意本条款及我们的隐私政策。如果您不同意，请勿使用本服务。',
      ],
      sections: [
        LegalSection('1. 关于本服务', [
          const LegalBlock.p(
              'MakanKira 帮助一群人组织聚餐：组织者创建聚餐、分享菜单、收集每个人的点单并录入最终账单，本服务随后计算每位参与者应付的金额。付款由参与者与组织者直接完成，例如通过 DuitNow 或银行转账。'),
          const LegalBlock.p(
              '本服务免费提供，仅限个人及非商业用途，主要面向马来西亚用户，金额以马来西亚令吉（RM）显示。'),
        ]),
        LegalSection('2. 您的账号', [
          const LegalBlock.li(
              '您使用 Google 账号登录（唯一的登录方式）。登录即表示您授权我们获取您的基本 Google 个人资料（姓名、电子邮箱和头像）。'),
          const LegalBlock.li('请确保您的个人资料准确并保持更新。'),
          const LegalBlock.li(
              '您须对账号下发生的活动负责，并妥善保管您的 Google 账号。如发现账号被未经授权使用，请及时告知我们。'),
          const LegalBlock.li(
              '您须年满 18 周岁方可使用本服务；13 至 17 周岁的用户须在父母或监护人同意并监督下使用，并由其代表您接受本条款。'),
        ]),
        LegalSection('3. MakanKira 不是支付服务', [
          const LegalBlock.p('本节内容重要，请仔细阅读。'),
          const LegalBlock.li(
              'MakanKira 仅计算并记录每人应付的金额。我们不持有、不收取、不转移、不处理也不结算任何款项，也无法接触任何人的资金。'),
          const LegalBlock.li(
              '所有付款均由参与者与组织者在本服务之外直接完成，例如 DuitNow 转账、银行转账或现金。我们不是这些付款的当事方。'),
          const LegalBlock.li(
              '我们不是银行、电子货币发行方、汇款服务商或支付系统运营者，也未获得马来西亚国家银行（Bank Negara Malaysia）的许可或监管。本服务中的任何内容均不构成理财建议。'),
          const LegalBlock.li(
              '聚餐中显示的收款信息（银行账户、DuitNow ID、二维码等）由组织者填写。转账前请务必核实收款信息和金额。对于因信息有误或转错账户而造成的付款损失，我们不承担责任。'),
          const LegalBlock.li(
              '在本服务中将某笔金额标记为“已付”仅是记录功能，并不能证明转账确已发生。'),
          const LegalBlock.li(
              '有关应付金额、已付款项或退款的任何争议，均由组织者与相关参与者自行解决。'),
        ]),
        LegalSection('4. 组织者与参与者', [
          const LegalBlock.li(
              '组织者负责菜单、价格、最终账单，以及税费、服务费、折扣或报销调整的准确性，并对自己的收款信息负责；同时应妥善处理参与者的信息。'),
          const LegalBlock.li('参与者对自己的点单及备注负责，并应向组织者支付应付款项。'),
          const LegalBlock.li(
              '计算结果取决于所输入的数字。我们不核实账单、收据或价格，菜单的预估价格可能与餐厅的最终价格不同。'),
        ]),
        LegalSection('5. 邀请链接', [
          const LegalBlock.li(
              '参与者通过邀请链接加入聚餐。任何持有链接的人都可以打开它，并在登录后加入该聚餐、查看其详情，包括菜单、参与者姓名、金额及组织者的收款信息。'),
          const LegalBlock.li(
              '请仅将邀请链接分享给您想邀请的人。对于链接被转发到目标群体之外所导致的访问，我们不承担责任。'),
        ]),
        LegalSection('6. 您的内容', [
          const LegalBlock.li(
              '聚餐中的内容由您和您的参与者提供：菜单、菜单照片与文件、点单及备注、姓名与联系电话、收款信息及备注（“您的内容”）。'),
          const LegalBlock.li(
              '您的内容归您所有。您授予我们一项非独占、全球性、免版税的许可，仅用于托管、存储、处理、展示和传输这些内容，以运营、维护和改进本服务。'),
          const LegalBlock.li(
              '您对您的内容负责。当您填写他人的信息（例如参与者的姓名和电话号码）时，您确认已获得对方许可，可以将该信息提供给我们及该聚餐的其他成员。'),
          const LegalBlock.li(
              '请仅上传您有权分享的材料。餐厅的菜单、标志和商标归其所有者所有，上传仅可作为您的群组点餐时的参考。'),
          const LegalBlock.li('对于我们有合理理由认为违反本条款或法律的内容，我们可以将其移除。'),
        ]),
        LegalSection('7. 使用规范', [
          const LegalBlock.p('您同意不进行以下行为：'),
          const LegalBlock.li(
              '将本服务用于任何违法、欺诈或误导性用途，包括虚假付款请求或谎报应付金额；'),
          const LegalBlock.li('上传恶意代码，或探测、过载、干扰本服务或其基础设施；'),
          const LegalBlock.li('试图未经许可访问其他用户的数据或聚餐；'),
          const LegalBlock.li('抓取、批量提取、转售或以商业方式利用本服务或其数据；'),
          const LegalBlock.li('冒充他人，或利用本服务发送垃圾信息。'),
          const LegalBlock.p('对违反上述规则的账号，我们可以暂停或终止其使用。'),
        ]),
        LegalSection('8. 通知与电子邮件', [
          const LegalBlock.li(
              '本服务可发送浏览器推送通知和电子邮件，例如点单提醒和点单汇总表。您可以通过浏览器设置和应用内的通知设置控制推送通知，并按聚餐设置提醒。'),
          const LegalBlock.li('通知和电子邮件的送达无法保证，请勿将其作为点单或付款的唯一提醒。'),
        ]),
        LegalSection('9. 第三方服务', [
          const LegalBlock.li(
              '登录功能由 Google 提供，受 Google 自身条款约束。托管、存储、数据库和邮件发送由我们的基础设施服务商提供，详见隐私政策。'),
          const LegalBlock.li(
              '用户之间的付款完全由银行和支付应用（如 DuitNow）按其各自条款处理。用户添加的菜单链接指向我们无法控制且不为其背书的外部网站。'),
          const LegalBlock.li('我们不对第三方服务承担责任。'),
        ]),
        LegalSection('10. 知识产权', [
          const LegalBlock.li(
              '本服务（包括其软件、设计、标志及 MakanKira 名称）归我们或我们的许可方所有。我们授予您一项个人的、非独占、不可转让且可撤销的使用权，供您按照本条款使用本服务。'),
          const LegalBlock.li('本服务中包含的开源组件仍受其各自许可证约束。'),
          const LegalBlock.li(
              '如果您向我们提交反馈或建议，我们可以将其用于改进本服务，而对您不承担任何义务。'),
        ]),
        LegalSection('11. 服务可用性、变更与终止', [
          const LegalBlock.li(
              '本服务是免费产品，按“现状可用”提供。我们可能新增、更改或移除功能，或暂停、停止本服务。若某项变更实质性削减了本服务，我们会尽合理努力提前在应用内发出通知，以便您导出数据。'),
          const LegalBlock.li(
              '您可以随时停止使用本服务，并可按照隐私政策所述申请删除您的账号和数据。'),
          const LegalBlock.li(
              '如果您严重违反本条款、以违法方式使用本服务，或危及本服务或其他用户，我们可以暂停或终止您的访问。'),
        ]),
        LegalSection('12. 免责声明', [
          const LegalBlock.li(
              '在法律允许的最大范围内，本服务按“现状”和“现有可用性”提供，不作任何形式的保证，包括不保证服务不中断、无错误，或计算始终正确。'),
          const LegalBlock.li(
              '在付款或发起付款请求之前，请务必核实最终金额。本服务不提供理财、税务、会计或法律建议；公司报销分摊等功能仅为便利工具，并非专业意见。'),
        ]),
        LegalSection('13. 责任限制', [
          const LegalBlock.li(
              '在法律允许的最大范围内，我们不对间接或后果性损失、利润损失、数据或商誉损失负责，也不对用户之间的付款、用户内容或第三方服务负责。'),
          const LegalBlock.li(
              '在法律允许的最大范围内，我们就与本服务相关的全部索赔所承担的责任总额以 RM100 为限，或以您在过去 12 个月内为本服务向我们支付的金额（目前为零）为限，以较高者为准。'),
          const LegalBlock.li(
              '本条款不排除或限制依适用法律不可排除的责任，包括适用时的《1999年消费者保护法》。'),
        ]),
        LegalSection('14. 赔偿', [
          const LegalBlock.p(
              '在法律允许的范围内，若第三方（包括其他用户）因您的内容、您违反本条款使用本服务，或您违反法律或他人权利而向我们提出索赔，您同意就此向我们作出赔偿。'),
        ]),
        LegalSection('15. 条款变更', [
          const LegalBlock.p(
              '我们可能不时更新本条款。上方的“最后更新”日期即为当前版本。对于重大变更，我们会在本服务中发出通知；变更生效后您继续使用即表示接受更新后的条款。'),
        ]),
        LegalSection('16. 适用法律', [
          const LegalBlock.p(
              '本条款受马来西亚法律管辖，任何争议由马来西亚法院管辖。不过我们更希望先以非正式的方式解决问题，欢迎先与我们联系。'),
        ]),
        LegalSection('17. 一般条款', [
          const LegalBlock.li('本条款连同隐私政策，构成您与我们之间关于本服务的完整协议。'),
          const LegalBlock.li(
              '如本条款的某一部分被认定为不可执行，其余部分仍然有效。我们未执行某项条款并不构成弃权。'),
          const LegalBlock.li(
              '您不得转让您在本条款下的权利。我们可以在通知您的情况下，将我们的权利转让给本服务的继任运营者。'),
          const LegalBlock.li(
              '本条款以英文、马来文和中文发布。如各版本之间存在不一致，以英文版本为准。'),
        ]),
        LegalSection('18. 联系我们', [
          LegalBlock.p('有关本条款的问题，请发送邮件至 $kLegalContactEmail。'),
        ]),
      ],
    );
