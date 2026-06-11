import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/tour_controller.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';

class TourOverlay extends StatefulWidget {
  const TourOverlay({super.key});

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay> {
  Timer? _timer;
  Offset _targetOffset = Offset.zero;
  Size _targetSize = Size.zero;
  int? _lastScrolledStep;

  // Intermediary popup states
  bool _showTransitionPopup = false;
  bool _showFinalPopup = false;
  bool _showSelectPagePopup = false;
  int _selectedRestartPage = 0; // 0: Home, 1: Relax, 2: Analytics, 3: Settings

  @override
  void initState() {
    super.initState();
    // Update coordinates dynamically at a low cost
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      final tour = TourController.instance;
      if (!tour.isTourActive) {
        _lastScrolledStep = null;
      }
      if (tour.isTourActive && !_showTransitionPopup && !_showFinalPopup && !_showSelectPagePopup) {
        final key = tour.targetKeys[tour.currentStep];
        if (key != null && key.currentContext != null) {
          // Auto-scroll to target widget once per step
          if (_lastScrolledStep != tour.currentStep) {
            _lastScrolledStep = tour.currentStep;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (key.currentContext != null) {
                Scrollable.ensureVisible(
                  key.currentContext!,
                  duration: const Duration(milliseconds: 300),
                  alignment: 0.5,
                );
              }
            });
          }
          final box = key.currentContext!.findRenderObject() as RenderBox?;
          if (box != null && box.attached) {
            final offset = box.localToGlobal(Offset.zero);
            if (offset != _targetOffset || box.size != _targetSize) {
              setState(() {
                _targetOffset = offset;
                _targetSize = box.size;
              });
            }
            return;
          }
        }
      }
      // If target context is missing or not active, reset bounds to prevent artifacts
      if (_targetSize != Size.zero && !TourController.instance.isTourActive) {
        setState(() {
          _targetOffset = Offset.zero;
          _targetSize = Size.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onNextPressed(TourController tour) {
    final step = tour.currentStep;
    // Show transition popups at the end of each screen's steps
    if (step == 2 || step == 5 || step == 7) {
      setState(() {
        _showTransitionPopup = true;
      });
    } else if (step == 10) {
      setState(() {
        _showFinalPopup = true;
      });
    } else {
      tour.nextStep();
    }
  }

  void _confirmTransition(TourController tour) {
    setState(() {
      _showTransitionPopup = false;
    });
    tour.nextStep();
  }

  void _confirmFinal(TourController tour) {
    setState(() {
      _showFinalPopup = false;
    });
    tour.completeTour();
  }

  void _restartTourAtPage(TourController tour, int pageIndex) {
    setState(() {
      _showSelectPagePopup = false;
      _showFinalPopup = false;
    });
    // Set appropriate start step based on selected page
    if (pageIndex == 0) {
      tour.setStep(0);
    } else if (pageIndex == 1) {
      tour.setStep(3);
    } else if (pageIndex == 2) {
      tour.setStep(6);
    } else if (pageIndex == 3) {
      tour.setStep(8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tour = context.watch<TourController>();
    if (!tour.isTourActive) return const SizedBox.shrink();

    final step = tour.currentStep;
    final title = context.t(tour.stepTitles[step] ?? '');
    final description = context.t(tour.stepDescriptions[step] ?? '');
    final totalSteps = tour.targetKeys.length;

    // Check if dialog should show on top or bottom
    final screenSize = MediaQuery.of(context).size;
    final isTargetInBottomHalf = (_targetOffset.dy + _targetSize.height / 2) > (screenSize.height / 2);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Spotlight Mask
          if (!_showTransitionPopup && !_showFinalPopup && !_showSelectPagePopup)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Absorb taps to block background interactions
                child: CustomPaint(
                  painter: SpotlightPainter(
                    offset: _targetOffset,
                    size: _targetSize,
                  ),
                ),
              ),
            ),

          // Dark overlay when transition/final popup is displayed
          if (_showTransitionPopup || _showFinalPopup || _showSelectPagePopup)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Absorb taps to block background interactions
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),

          // Intermediary Transition Popup ("Tiếp tục tour chứ?")
          if (_showTransitionPopup)
            Center(
              child: _GlassPopup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_run_outlined, color: RelaxColors.violet, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      context.t('Tiếp tục tour chứ?'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.t('Chúng ta sẽ chuyển sang trang tiếp theo để khám phá thêm nhiều chức năng thú vị nha ~'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() => _showTransitionPopup = false);
                              tour.stopTour();
                            },
                            child: Text(
                              context.t('Bỏ qua'),
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RelaxColors.violet,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _confirmTransition(tour),
                            child: Text(
                              context.t('Cho tui đi tiếp cái tour này đi'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Final Popup ("Tour du lịch tới đây đã hết tiền dồiii...")
          if (_showFinalPopup)
            Center(
              child: _GlassPopup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.celebration, color: RelaxColors.mint, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      context.t('Tour Kết Thúc 🎉'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.t('tour du lịch tới đây đã hết tiền dồiii ~, trải nghiệm tốt nha'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RelaxColors.violet,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _confirmFinal(tour),
                            child: Text(
                              context.t('Đã hiểu rùi nè ~'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _showSelectPagePopup = true;
                              });
                            },
                            child: Text(
                              context.t('đi lại lần nữa'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Page Selector Popup for restarting the tour
          if (_showSelectPagePopup)
            Center(
              child: _GlassPopup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined, color: RelaxColors.plum, size: 44),
                    const SizedBox(height: 16),
                    Text(
                      context.t('Chọn trang muốn quay lại'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(4, (index) {
                      final pages = ['Trang chủ', 'Thư giãn', 'Phân tích cảm xúc', 'Cài đặt'];
                      final isSelected = _selectedRestartPage == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRestartPage = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? RelaxColors.violet.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: isSelected ? RelaxColors.violet : Colors.white12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? RelaxColors.violet : Colors.white30,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  context.t(pages[index]),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() => _showSelectPagePopup = false);
                            },
                            child: Text(
                              context.t('Hủy'),
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RelaxColors.violet,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _restartTourAtPage(tour, _selectedRestartPage),
                            child: Text(
                              context.t('Đi thoaii'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Standard Spotlight Instruction Dialog
          if (!_showTransitionPopup && !_showFinalPopup && !_showSelectPagePopup)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: 20,
              right: 20,
              top: !isTargetInBottomHalf ? (_targetOffset.dy + _targetSize.height + 16) : null,
              bottom: isTargetInBottomHalf ? (screenSize.height - _targetOffset.dy + 16) : null,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B2E).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: RelaxColors.violet.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.t('Bước {current} / {total}', {
                              'current': '${step + 1}',
                              'total': '$totalSteps',
                            }),
                            style: const TextStyle(
                              color: RelaxColors.violet,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => tour.stopTour(),
                          child: const Icon(Icons.close, color: Colors.white30, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => tour.stopTour(),
                          child: Text(
                            context.t('Bỏ qua'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (step > 0) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => tour.prevStep(),
                            child: Text(
                              context.t('Trở lại'),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RelaxColors.violet,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () => _onNextPressed(tour),
                          child: Text(
                            step == totalSteps - 1 ? context.t('Hoàn thành') : context.t('Tiếp theo'),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SpotlightPainter extends CustomPainter {
  SpotlightPainter({required this.offset, required this.size});
  final Offset offset;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.75);

    if (size == Size.zero) {
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), paint);
      return;
    }

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    const padding = 6.0;
    final holeRect = Rect.fromLTWH(
      offset.dx - padding,
      offset.dy - padding,
      size.width + padding * 2,
      size.height + padding * 2,
    );
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(14)));

    final path = Path.combine(PathOperation.difference, backgroundPath, holePath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.size != size;
  }
}

class _GlassPopup extends StatelessWidget {
  const _GlassPopup({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
