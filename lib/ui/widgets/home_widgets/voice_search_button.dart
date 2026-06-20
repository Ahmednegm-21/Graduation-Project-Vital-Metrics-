import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchButton extends StatefulWidget {
  final ValueChanged<String> onResult;
  final Color? idleColor;

  const VoiceSearchButton({
    super.key,
    required this.onResult,
    this.idleColor,
  });

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _stt = SpeechToText();

  bool _available  = false;
  bool _listening  = false;
  bool _finalReceived = false;
  String _lastWords = '';

  // عدد محاولات الـ retry
  int _retryCount = 0;
  static const int _maxRetries = 2;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await _stt.initialize(
      onError: (e) {
        debugPrint('[STT] error: ${e.errorMsg}');

        // error_speech_timeout أو error_no_match → retry
        final shouldRetry = (e.errorMsg == 'error_speech_timeout' ||
                e.errorMsg == 'error_no_match' ||
                e.errorMsg == 'error_network_timeout') &&
            _retryCount < _maxRetries &&
            _listening;

        if (shouldRetry) {
          debugPrint('[STT] retrying... attempt ${_retryCount + 1}');
          _retryCount++;
          // استنى شوية وابدأ تاني
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _listening) _startListenSession();
          });
          return;
        }

        // لو عندنا كلام ابعته
        if (_lastWords.isNotEmpty && !_finalReceived) {
          _finalReceived = true;
          widget.onResult(_lastWords);
          _lastWords = '';
        }
        _stopListening();
      },
      onStatus: (status) {
        debugPrint('[STT] status: $status');
        if (status == 'notListening' || status == 'done') {
          if (_lastWords.isNotEmpty && !_finalReceived) {
            _finalReceived = true;
            widget.onResult(_lastWords);
            _lastWords = '';
          }
          // متوقفش لو هنعمل retry
          if (_retryCount == 0) _stopListening();
        }
      },
    );

    if (mounted) setState(() => _available = ok);
    debugPrint('[STT] available: $ok');
  }

  Future<void> _toggleListening() async {
    if (!_available) {
      await _init();
      if (!_available) return;
    }

    HapticFeedback.mediumImpact();

    if (_listening) {
      _retryCount = _maxRetries; // منع أي retry
      await _stt.stop();
      if (_lastWords.isNotEmpty && !_finalReceived) {
        widget.onResult(_lastWords);
        _lastWords = '';
      }
      _stopListening();
      return;
    }

    // reset كل حاجة
    _lastWords      = '';
    _finalReceived  = false;
    _retryCount     = 0;
    _startListening();
    await _startListenSession();
  }

  Future<void> _startListenSession() async {
    try {
      await _stt.listen(
        localeId:      'ar_EG',
        listenFor:     const Duration(seconds: 30),
        partialResults: true,
        cancelOnError: false,
        onResult: (result) {
          debugPrint(
              '[STT] words="${result.recognizedWords}" final=${result.finalResult}');

          if (result.recognizedWords.isNotEmpty) {
            _lastWords = result.recognizedWords;
          }

          if (result.finalResult && !_finalReceived) {
            _finalReceived  = true;
            _retryCount     = _maxRetries; // وقف أي retry
            final words     = _lastWords;
            _lastWords      = '';
            if (words.isNotEmpty) widget.onResult(words);
            _stopListening();
          }
        },
        onSoundLevelChange: null,
      );
    } catch (e) {
      debugPrint('[STT] listen exception: $e');
      _stopListening();
    }
  }

  void _startListening() {
    if (!mounted) return;
    setState(() => _listening = true);
    _pulse.repeat(reverse: true);
  }

  void _stopListening() {
    if (!mounted) return;
    setState(() => _listening = false);
    _pulse
      ..stop()
      ..reset();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _stt.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idleColor = widget.idleColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white38
            : Colors.black38);

    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_listening)
                Transform.scale(
                  scale: 1.0 + _pulse.value * 0.55,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF3B30)
                          .withOpacity(0.12 + _pulse.value * 0.18),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _listening
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    key: ValueKey(_listening),
                    size: 20.sp,
                    color: !_available
                        ? idleColor.withOpacity(0.3)
                        : _listening
                            ? const Color(0xFFFF3B30)
                            : idleColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}