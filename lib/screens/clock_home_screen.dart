import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/analog_clock.dart';

const Color accent = Color(0xFF9B8AFF);
const Color panel = Color(0xFF151C30);
const Color muted = Color(0xFF9AA6C4);

class ClockHomeScreen extends StatefulWidget {
  const ClockHomeScreen({super.key});

  @override
  State<ClockHomeScreen> createState() => _ClockHomeScreenState();
}

class _ClockHomeScreenState extends State<ClockHomeScreen> {
  int _tab = 0;
  DateTime _now = DateTime.now();
  Timer? _clockTicker;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTicker;
  Duration _stopwatchElapsed = Duration.zero;
  Timer? _countdownTicker;
  Duration _remaining = const Duration(minutes: 5);
  Duration _chosenDuration = const Duration(minutes: 5);
  bool _countdownRunning = false;

  @override
  void initState() {
    super.initState();
    _clockTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    _stopwatchTicker?.cancel();
    _countdownTicker?.cancel();
    super.dispose();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _time(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}:${_two(value.second)}';

  String _date(DateTime value) {
    const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${weekdays[value.weekday - 1]}، ${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _durationText(Duration duration, {bool hundredths = false}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final centiseconds = (duration.inMilliseconds.remainder(1000) ~/ 10);
    final base = '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
    return hundredths ? '$base.${_two(centiseconds)}' : base;
  }

  void _toggleStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _stopwatchTicker?.cancel();
      setState(() => _stopwatchElapsed = _stopwatch.elapsed);
    } else {
      _stopwatch.start();
      _stopwatchTicker ??= Timer.periodic(const Duration(milliseconds: 30), (_) {
        if (mounted && _stopwatch.isRunning) {
          setState(() => _stopwatchElapsed = _stopwatch.elapsed);
        }
      });
    }
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch
      ..stop()
      ..reset();
    _stopwatchElapsed = Duration.zero;
    _stopwatchTicker?.cancel();
    _stopwatchTicker = null;
    setState(() {});
  }

  void _toggleCountdown() {
    if (_countdownRunning) {
      _countdownTicker?.cancel();
      setState(() => _countdownRunning = false);
      return;
    }
    if (_remaining.inSeconds <= 0) _remaining = _chosenDuration;
    setState(() => _countdownRunning = true);
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _countdownRunning = false;
        });
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _resetCountdown() {
    _countdownTicker?.cancel();
    setState(() {
      _countdownRunning = false;
      _remaining = _chosenDuration;
    });
  }

  Future<void> _chooseTimerDuration() async {
    if (_countdownRunning) return;
    int minutes = _chosenDuration.inMinutes;
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: panel,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ضبط المؤقت', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setSheetState(() => minutes = (minutes - 1).clamp(1, 180)),
                      icon: const Icon(Icons.remove_circle_outline, size: 34),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text('$minutes دقيقة', textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => setSheetState(() => minutes = (minutes + 1).clamp(1, 180)),
                      icon: const Icon(Icons.add_circle_outline, size: 34),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, minutes),
                    child: const Text('حفظ المدة'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _chosenDuration = Duration(minutes: result);
        _remaining = _chosenDuration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildClockPage(),
      _buildStopwatchPage(),
      _buildTimerPage(),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.schedule_rounded, color: accent, size: 27),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TEMPO', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          Text('وقتك بين يديك', style: TextStyle(color: muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20)),
                      child: const Row(children: [
                        Icon(Icons.circle, color: Color(0xFF5EE6A8), size: 8),
                        SizedBox(width: 6),
                        Text('مباشر', style: TextStyle(fontSize: 12, color: muted)),
                      ]),
                    )
                  ],
                ),
              ),
              Expanded(child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
              )),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF11182A),
            border: Border(top: BorderSide(color: Color(0xFF252E45))),
          ),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            backgroundColor: Colors.transparent,
            indicatorColor: accent.withValues(alpha: .20),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.access_time_rounded), selectedIcon: Icon(Icons.access_time_filled_rounded), label: 'الساعة'),
              NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'إيقاف'),
              NavigationDestination(icon: Icon(Icons.hourglass_bottom_rounded), selectedIcon: Icon(Icons.hourglass_full_rounded), label: 'المؤقت'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClockPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text('الوقت الآن', style: TextStyle(color: muted, fontSize: 15)),
          ),
          const SizedBox(height: 4),
          Text(_date(_now), style: const TextStyle(fontSize: 15, color: Color(0xFFD3D9EA))),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight, end: Alignment.bottomLeft,
                colors: [Color(0xFF20294A), Color(0xFF141B30), Color(0xFF11182A)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: .07)),
            ),
            child: Column(
              children: [
                SizedBox(height: 255, child: AnalogClock(time: _now)),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_time(_now), style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.w300, letterSpacing: 3,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )),
                ),
                const SizedBox(height: 4),
                const Text('كل ثانية تصنع فرقاً', style: TextStyle(color: muted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _infoCard(Icons.calendar_month_rounded, 'اليوم', _two(_now.day), 'من الشهر')),
              const SizedBox(width: 12),
              Expanded(child: _infoCard(Icons.public_rounded, 'المنطقة الزمنية', 'محلي', 'حسب جهازك')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: accent, size: 25),
                SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نصيحة اليوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('نظّم وقتك، وامنح كل مهمة حقها.', style: TextStyle(color: muted, fontSize: 13)),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(21)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStopwatchPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ساعة الإيقاف', style: TextStyle(color: muted, fontSize: 16)),
            const SizedBox(height: 32),
            Container(
              width: 270, height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: panel,
                border: Border.all(color: accent.withValues(alpha: .55), width: 2),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: .10), blurRadius: 35, spreadRadius: 5)],
              ),
              child: Center(
                child: Text(_durationText(_stopwatchElapsed, hundredths: true),
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w300, fontFeatures: [FontFeature.tabularFigures()])),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(Icons.restart_alt_rounded, 'إعادة', _resetStopwatch, outlined: true),
                const SizedBox(width: 18),
                _actionButton(_stopwatch.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  _stopwatch.isRunning ? 'إيقاف مؤقت' : 'ابدأ', _toggleStopwatch),
              ],
            ),
            const SizedBox(height: 25),
            const Text('ابدأ القياس أو أوقفه متى شئت', style: TextStyle(color: muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPage() {
    final total = _chosenDuration.inSeconds == 0 ? 1 : _chosenDuration.inSeconds;
    final progress = (_remaining.inSeconds / total).clamp(0.0, 1.0);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('المؤقت التنازلي', style: TextStyle(color: muted, fontSize: 16)),
            const SizedBox(height: 30),
            SizedBox(
              width: 270, height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFF29324A),
                      valueColor: const AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_bottom_rounded, color: accent, size: 28),
                      const SizedBox(height: 12),
                      Text(_durationText(_remaining),
                        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w300, fontFeatures: [FontFeature.tabularFigures()])),
                      const SizedBox(height: 8),
                      Text(_countdownRunning ? 'جارٍ العدّ' : (_remaining == Duration.zero ? 'انتهى الوقت' : 'جاهز للبدء'),
                        style: const TextStyle(color: muted, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: _countdownRunning ? null : _chooseTimerDuration,
              icon: const Icon(Icons.tune_rounded),
              label: Text('تغيير المدة (${_chosenDuration.inMinutes} دقيقة)'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(Icons.restart_alt_rounded, 'إعادة', _resetCountdown, outlined: true),
                const SizedBox(width: 18),
                _actionButton(_countdownRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  _countdownRunning ? 'إيقاف مؤقت' : 'ابدأ', _toggleCountdown),
              ],
            ),
            const SizedBox(height: 16),
            const Text('ابقَ مركزاً على ما يهمك', style: TextStyle(color: muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed, {bool outlined = false}) {
    return SizedBox(
      height: 52,
      child: outlined
          ? OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label))
          : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}
