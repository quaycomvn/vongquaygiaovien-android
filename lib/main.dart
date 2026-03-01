import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const String kStorageKey = 'teacher_wheel_v9';

void main() {
  runApp(const TeacherWheelApp());
}

/// ==================
/// Models
/// ==================

class ClassEvent {
  final int id;
  final String name;
  final List<String> items;

  const ClassEvent({required this.id, required this.name, required this.items});

  ClassEvent copyWith({int? id, String? name, List<String>? items}) {
    return ClassEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'items': items};

  static ClassEvent fromJson(Map<String, dynamic> j) {
    return ClassEvent(
      id: (j['id'] as num).toInt(),
      name: (j['name'] as String?) ?? '',
      items:
          ((j['items'] as List?) ?? const []).map((e) => e.toString()).toList(),
    );
  }
}

class AppStateModel {
  final String lang;
  final List<ClassEvent> classes;
  final int? currentId;

  const AppStateModel(
      {required this.lang, required this.classes, required this.currentId});

  AppStateModel copyWith(
      {String? lang, List<ClassEvent>? classes, int? currentId}) {
    return AppStateModel(
      lang: lang ?? this.lang,
      classes: classes ?? this.classes,
      currentId: currentId ?? this.currentId,
    );
  }

  ClassEvent? get current {
    if (currentId == null) return null;
    for (final c in classes) {
      if (c.id == currentId) return c;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'classes': classes.map((e) => e.toJson()).toList(),
        'currentId': currentId,
      };

  static AppStateModel fromJson(Map<String, dynamic> j) {
    final lang = (j['lang'] as String?) ?? 'vi';
    final classes = ((j['classes'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ClassEvent.fromJson)
        .toList();
    final currentId = (j['currentId'] as num?)?.toInt() ??
        (classes.isNotEmpty ? classes.first.id : null);
    return AppStateModel(lang: lang, classes: classes, currentId: currentId);
  }

  static AppStateModel initial() {
    final seed = [
      ClassEvent(
          id: 1,
          name: 'Lớp 5A',
          items: const ['An', 'Bình', 'Chi', 'Dũng', 'Hà', 'Lan']),
      ClassEvent(
          id: 2,
          name: 'Sự kiện 20/11',
          items: const ['Nam', 'Trang', 'Phúc', 'Minh', 'Thảo', 'Vy']),
    ];
    return AppStateModel(lang: 'vi', classes: seed, currentId: seed.first.id);
  }
}

/// ==================
/// i18n (from your app.js)
/// ==================

class Tr {
  final String docTitle;
  final String title;
  final String classSection;
  final String classPlaceholder;
  final String listSection;
  final String listPlaceholder;
  final String saveList;
  final String hint;
  final String spin;
  final String result;
  final String edit;
  final String deleteConfirm;
  final String remove;
  final String aboutTitle;
  final String aboutBody;
  final String privacyTitle;
  final String privacyBody;
  final String menuHome;
  final String menuAbout;
  final String menuPrivacy;
  final String menuOnline;

  const Tr({
    required this.docTitle,
    required this.title,
    required this.classSection,
    required this.classPlaceholder,
    required this.listSection,
    required this.listPlaceholder,
    required this.saveList,
    required this.hint,
    required this.spin,
    required this.result,
    required this.edit,
    required this.deleteConfirm,
    required this.remove,
    required this.aboutTitle,
    required this.aboutBody,
    required this.privacyTitle,
    required this.privacyBody,
    required this.menuHome,
    required this.menuAbout,
    required this.menuPrivacy,
    required this.menuOnline,
  });
}

const Map<String, Tr> i18n = {
  'vi': Tr(
    docTitle: 'Vòng quay cho Giáo viên',
    title: 'Vòng quay cho Giáo viên',
    classSection: 'Lớp / Sự kiện',
    classPlaceholder: 'Nhập lớp / sự kiện...',
    listSection: 'Danh sách (mỗi dòng 1 tên)',
    listPlaceholder: 'Nhập danh sách (mỗi dòng 1 tên)...',
    saveList: 'Lưu danh sách',
    hint: 'Chọn lớp/sự kiện ở trên để sửa danh sách tương ứng.',
    spin: 'QUAY',
    result: 'Kết quả',
    edit: 'Sửa tên lớp/sự kiện:',
    deleteConfirm: 'Xóa lớp/sự kiện này?',
    remove: 'Xóa',
    aboutTitle: 'Giới thiệu',
    aboutBody:
        'Ứng dụng “Vòng quay may mắn cho giáo viên” giúp thầy cô quản lý NHIỀU lớp hoặc sự kiện.\n\n'
        'Mỗi lớp/sự kiện có 1 danh sách riêng, giúp quay tên công bằng và nhanh chóng.\n\n'
        'Dữ liệu được lưu cục bộ trên thiết bị, hoạt động offline.',
    privacyTitle: 'Chính sách bảo mật',
    privacyBody: '• Ứng dụng không yêu cầu đăng nhập.\n'
        '• Dữ liệu lớp/sự kiện và danh sách được lưu cục bộ trên thiết bị.\n'
        '• Ứng dụng không thu thập hay gửi dữ liệu cá nhân ra ngoài.\n'
        '• Khi bạn bấm “Bản Online”, trình duyệt sẽ mở quay.com.vn.',
    menuHome: 'Trang chủ',
    menuAbout: 'Giới thiệu',
    menuPrivacy: 'Chính sách',
    menuOnline: 'Bản Online',
  ),
  'en': Tr(
    docTitle: 'Wheel for Teachers',
    title: 'Wheel for Teachers',
    classSection: 'Class / Event',
    classPlaceholder: 'Type class / event...',
    listSection: 'List (one per line)',
    listPlaceholder: 'Type items (one per line)...',
    saveList: 'Save list',
    hint: 'Select a class/event above to edit its list.',
    spin: 'SPIN',
    result: 'Result',
    edit: 'Edit class/event name:',
    deleteConfirm: 'Delete this class/event?',
    remove: 'Remove',
    aboutTitle: 'About',
    aboutBody:
        'Teacher Lucky Wheel is built for teachers who handle multiple classes/events.\n\n'
        'Key feature: save a separate list for each class/event, then spin fairly.\n\n'
        'All data stays on-device and works offline.',
    privacyTitle: 'Privacy Policy',
    privacyBody: '• No login required.\n'
        '• Class/event data is stored locally on your device.\n'
        '• The app does not collect or transmit personal data.\n'
        '• When you tap “Online Version”, your browser opens quay.com.vn.',
    menuHome: 'Home',
    menuAbout: 'About',
    menuPrivacy: 'Privacy',
    menuOnline: 'Online Version',
  ),
  'jp': Tr(
    docTitle: '教師用ルーレット',
    title: '教師用ルーレット',
    classSection: 'クラス / イベント',
    classPlaceholder: 'クラス / イベント名を入力...',
    listSection: '一覧（1行1件）',
    listPlaceholder: '1行に1つ入力...',
    saveList: '保存',
    hint: '上でクラス/イベントを選ぶと、対応する一覧を編集できます。',
    spin: '回す',
    result: '結果',
    edit: '名前を編集:',
    deleteConfirm: 'このクラス/イベントを削除しますか？',
    remove: '削除',
    aboutTitle: '紹介',
    aboutBody: '教師向けに作られたルーレットです。\n\n'
        '複数のクラス/イベントごとにリストを保存し、公平に抽選できます。\n\n'
        'データは端末内に保存され、オフラインで動作します。',
    privacyTitle: 'プライバシーポリシー',
    privacyBody: '• ログイン不要。\n'
        '• クラス/イベントと一覧は端末内に保存。\n'
        '• 個人データの収集・送信はしません。\n'
        '• 「オンライン版」を押すと quay.com.vn を開きます。',
    menuHome: 'ホーム',
    menuAbout: '紹介',
    menuPrivacy: 'プライバシー',
    menuOnline: 'オンライン版',
  ),
};

Tr trOf(String lang) => i18n[lang] ?? i18n['vi']!;

/// ==================
/// App shell + routing
/// ==================

enum AppPage { home, about, privacy }

class TeacherWheelApp extends StatefulWidget {
  const TeacherWheelApp({super.key});

  @override
  State<TeacherWheelApp> createState() => _TeacherWheelAppState();
}

class _TeacherWheelAppState extends State<TeacherWheelApp> {
  AppStateModel state = AppStateModel.initial();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kStorageKey);
    if (raw == null) {
      await prefs.setString(kStorageKey, jsonEncode(state.toJson()));
      return;
    }
    try {
      state = AppStateModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      setState(() {});
    } catch (_) {
      state = AppStateModel.initial();
      await prefs.setString(kStorageKey, jsonEncode(state.toJson()));
      setState(() {});
    }
  }

  Future<void> _save(AppStateModel next) async {
    state = next;
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kStorageKey, jsonEncode(next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final tr = trOf(state.lang);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: tr.docTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE10600)),
      ),
      home: HomePage(
        state: state,
        onChange: _save,
      ),
    );
  }
}

/// ==================
/// Home UI (native version of your HTML/CSS/JS)
/// ==================

class HomePage extends StatefulWidget {
  final AppStateModel state;
  final Future<void> Function(AppStateModel next) onChange;

  const HomePage({super.key, required this.state, required this.onChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AppPage page = AppPage.home;

  late AnimationController _controller;
  late Animation<double> _anim;
  double rotation = 0.0; // radians
  final TextEditingController classInput = TextEditingController();
  final TextEditingController bulkInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));
    _anim = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
        parent: _controller, curve: const Cubic(0.17, 0.67, 0.18, 1.0)))
      ..addListener(() => setState(() => rotation = _anim.value));

    _syncBulkFromState();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentId != widget.state.currentId ||
        oldWidget.state.classes != widget.state.classes) {
      _syncBulkFromState();
    }
  }

  void _syncBulkFromState() {
    final items = widget.state.current?.items ?? const <String>[];
    bulkInput.text = items.join('\n');
  }

  @override
  void dispose() {
    _controller.dispose();
    classInput.dispose();
    bulkInput.dispose();
    super.dispose();
  }

  Tr get tr => trOf(widget.state.lang);

  Future<void> setLang(String lang) async {
    await widget.onChange(widget.state.copyWith(lang: lang));
  }

  Future<void> setCurrent(int id) async {
    await widget.onChange(widget.state.copyWith(currentId: id));
  }

  Future<void> addClass() async {
    final name = classInput.text.trim();
    if (name.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch;
    final next = widget.state.copyWith(
      classes: [
        ...widget.state.classes,
        ClassEvent(id: id, name: name, items: const [])
      ],
      currentId: id,
    );
    classInput.clear();
    await widget.onChange(next);
  }

  Future<void> editClass(ClassEvent c) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: c.name);
        return AlertDialog(
          title: Text(tr.edit),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('OK')),
          ],
        );
      },
    );
    if (newName == null || newName.isEmpty) return;

    final nextClasses = widget.state.classes
        .map((x) => x.id == c.id ? x.copyWith(name: newName) : x)
        .toList();
    await widget.onChange(widget.state.copyWith(classes: nextClasses));
  }

  Future<void> deleteClass(ClassEvent c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK')),
        ],
      ),
    );
    if (ok != true) return;

    final nextClasses =
        widget.state.classes.where((x) => x.id != c.id).toList();
    final nextCurrent = nextClasses.isNotEmpty ? nextClasses.first.id : null;
    await widget.onChange(
        widget.state.copyWith(classes: nextClasses, currentId: nextCurrent));
  }

  Future<void> saveBulk() async {
    final cur = widget.state.current;
    if (cur == null) return;

    final arr = bulkInput.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final nextClasses = widget.state.classes
        .map((x) => x.id == cur.id ? x.copyWith(items: arr) : x)
        .toList();
    await widget.onChange(widget.state.copyWith(classes: nextClasses));
  }

  double mod2pi(double x) {
    const tw = math.pi * 2;
    return ((x % tw) + tw) % tw;
  }

  Future<void> spin() async {
    final cur = widget.state.current;
    final items = cur?.items ?? const <String>[];
    if (items.length < 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Need at least 2 items')));
      return;
    }

    final n = items.length;
    final anglePer = (math.pi * 2) / n;
    final idx = math.Random().nextInt(n);

    // Same as your JS:
    // pointer at top = -pi/2, centerAngle = idx*anglePer + anglePer/2
    const pointerAngle = -math.pi / 2;
    final centerAngle = idx * anglePer + anglePer / 2;

    final desiredMod = mod2pi(pointerAngle - centerAngle);
    final currentMod = mod2pi(rotation);
    final delta = mod2pi(desiredMod - currentMod);

    const extraTurns = 6 * math.pi * 2; // 6 full turns
    final finalRotation = rotation + extraTurns + delta;

    _anim = Tween<double>(begin: rotation, end: finalRotation).animate(
      CurvedAnimation(
          parent: _controller, curve: const Cubic(0.17, 0.67, 0.18, 1.0)),
    )..addListener(() => setState(() => rotation = _anim.value));

    await _controller.forward(from: 0);

    if (!mounted) return;
    final winner = items[idx];
    await _showWinnerDialog(winner);
  }

  Future<void> _showWinnerDialog(String winner) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.result),
        content: Text('🎉 $winner',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('OK')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.remove)),
        ],
      ),
    );

    if (remove == true) {
      final cur = widget.state.current;
      if (cur == null) return;
      final nextItems = cur.items.where((x) => x != winner).toList();
      final nextClasses = widget.state.classes
          .map((x) => x.id == cur.id ? x.copyWith(items: nextItems) : x)
          .toList();
      await widget.onChange(widget.state.copyWith(classes: nextClasses));
      _syncBulkFromState();
    }
  }

  Future<void> openOnline() async {
    final uri = Uri.parse('https://quay.com.vn');
    // ignore: deprecated_member_use
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _pageBody() {
    if (page == AppPage.about) {
      return _TextPage(title: tr.aboutTitle, body: tr.aboutBody);
    }
    if (page == AppPage.privacy) {
      return _TextPage(title: tr.privacyTitle, body: tr.privacyBody);
    }
    return _HomeBody(
      tr: tr,
      rotation: rotation,
      items: widget.state.current?.items ?? const <String>[],
      onSpin: spin,
      classInput: classInput,
      bulkInput: bulkInput,
      state: widget.state,
      onAddClass: addClass,
      onSelectClass: setCurrent,
      onEditClass: editClass,
      onDeleteClass: deleteClass,
      onSaveBulk: saveBulk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE10600),
        foregroundColor: Colors.white,
        title: Text(page == AppPage.home
            ? tr.title
            : (page == AppPage.about ? tr.aboutTitle : tr.privacyTitle)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.state.lang,
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: 'vi', child: Text('🇻🇳 Tiếng Việt')),
                  DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  DropdownMenuItem(value: 'jp', child: Text('🇯🇵 日本語')),
                ],
                onChanged: (v) => v == null ? null : setLang(v),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFE10600)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(tr.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(tr.menuHome),
              onTap: () {
                Navigator.pop(context);
                setState(() => page = AppPage.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(tr.menuAbout),
              onTap: () {
                Navigator.pop(context);
                setState(() => page = AppPage.about);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(tr.menuPrivacy),
              onTap: () {
                Navigator.pop(context);
                setState(() => page = AppPage.privacy);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(tr.menuOnline),
              subtitle: const Text('quay.com.vn'),
              onTap: () async {
                Navigator.pop(context);
                await openOnline();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _pageBody()),
            // footer "Powered by" + Online link (SEO purpose)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              alignment: Alignment.center,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text('Powered by',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w600)),
                  InkWell(
                    onTap: openOnline,
                    child: const Text('Quay.com.vn',
                        style: TextStyle(
                            color: Color(0xFFE10600),
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextPage extends StatelessWidget {
  final String title;
  final String body;

  const _TextPage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(fontSize: 16, height: 1.55)),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final Tr tr;
  final double rotation;
  final List<String> items;
  final Future<void> Function() onSpin;

  final AppStateModel state;
  final TextEditingController classInput;
  final TextEditingController bulkInput;
  final Future<void> Function() onAddClass;
  final Future<void> Function(int id) onSelectClass;
  final Future<void> Function(ClassEvent c) onEditClass;
  final Future<void> Function(ClassEvent c) onDeleteClass;
  final Future<void> Function() onSaveBulk;

  const _HomeBody({
    required this.tr,
    required this.rotation,
    required this.items,
    required this.onSpin,
    required this.state,
    required this.classInput,
    required this.bulkInput,
    required this.onAddClass,
    required this.onSelectClass,
    required this.onEditClass,
    required this.onDeleteClass,
    required this.onSaveBulk,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;

    final left = Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(top: 6, child: _Pointer()),
              Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  painter: WheelPainter(items: items),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE10600),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onSpin,
            child: Text(tr.spin,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );

    final right = Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.classSection,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: classInput,
                      decoration: InputDecoration(
                        hintText: tr.classPlaceholder,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE10600),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: onAddClass,
                      child: const Text('+',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 190),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = state.classes[i];
                    final active = c.id == state.currentId;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelectClass(c.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFFFE0E0)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: active
                              ? Border.all(color: const Color(0xFFE10600))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700))),
                            IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => onEditClass(c)),
                            IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => onDeleteClass(c)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.listSection,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              TextField(
                controller: bulkInput,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: tr.listPlaceholder,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE10600),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onSaveBulk,
                  child: Text(tr.saveList,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              Text(tr.hint,
                  style: TextStyle(color: Colors.black.withOpacity(0.6))),
            ],
          ),
        ),
      ],
    );

    if (isNarrow) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            left,
            const SizedBox(height: 16),
            right,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 24),
              SizedBox(width: 390, child: right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 10))
        ],
      ),
      child: child,
    );
  }
}

/// Pointer triangle like your CSS
class _Pointer extends StatelessWidget {
  const _Pointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(40, 40), painter: _PointerPainter());
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFD700);
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.75)
      ..close();
    canvas.drawShadow(path, Colors.black.withOpacity(0.25), 6, true);
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(size.width / 2, 10), 8,
        Paint()..color = const Color(0x66FFD700));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wheel painter: same spirit as your canvas drawWheel()
class WheelPainter extends CustomPainter {
  final List<String> items;
  WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    final r = math.min(size.width, size.height) / 2;

    // Base white circle
    canvas.drawCircle(center, r, Paint()..color = Colors.white);

    if (items.isEmpty) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.black.withOpacity(0.08);
      canvas.drawCircle(center, r - 2, ring);
      return;
    }

    final n = items.length;
    final sweep = 2 * math.pi / n;

    // Outer ring
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.black.withOpacity(0.08);
    canvas.drawCircle(center, r - 2, ring);

    for (int i = 0; i < n; i++) {
      final start = i * sweep;
      final color =
          HSVColor.fromAHSV(1.0, (i * 360.0 / n), 0.70, 0.85).toColor();

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
            Rect.fromCircle(center: center, radius: r - 6), start, sweep, false)
        ..close();
      canvas.drawPath(path, Paint()..color = color);

      // Text
      final raw = items[i];
      final label = raw.length > 14 ? '${raw.substring(0, 14)}…' : raw;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(start + sweep / 2);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xF2FFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: r - 70);

      tp.paint(canvas, Offset((r - 28) - tp.width, -tp.height / 2));
      canvas.restore();
    }

    // Center circles
    canvas.drawCircle(center, 42, Paint()..color = Colors.white);
    canvas.drawCircle(center, 32, Paint()..color = const Color(0xFFB80000));
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) =>
      oldDelegate.items != items;
}
