import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tour_controller.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import 'models/tour_config.dart';
import 'widgets/spotlight_painter.dart';
import 'widgets/transition_popup.dart';
import 'widgets/final_popup.dart';
import 'widgets/page_selector_popup.dart';

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
    if (kTransitionSteps.contains(step)) {
      setState(() {
        _showTransitionPopup = true;
      });
    } else if (step == kFinalStep) {
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
    tour.setStep(startStepForPage(pageIndex));
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
            TransitionPopup(
              onSkip: () {
                setState(() => _showTransitionPopup = false);
                tour.stopTour();
              },
              onContinue: () => _confirmTransition(tour),
            ),

          // Final Popup ("Tour du lịch tới đây đã hết tiền dồiii...")
          if (_showFinalPopup)
            FinalPopup(
              onFinish: () => _confirmFinal(tour),
              onRestart: () {
                setState(() {
                  _showSelectPagePopup = true;
                });
              },
            ),

          // Page Selector Popup for restarting the tour
          if (_showSelectPagePopup)
            PageSelectorPopup(
              onCancel: () {
                setState(() => _showSelectPagePopup = false);
              },
              onSelect: (pageIndex) => _restartTourAtPage(tour, pageIndex),
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
