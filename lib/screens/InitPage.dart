import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:provider/provider.dart';

class InitPage extends StatefulWidget {
  static const routeName = "/InitPage";
  const InitPage();

  @override
  InitPageState createState() => InitPageState();
}

class InitPageState extends State<InitPage>
    with SingleTickerProviderStateMixin {
  late DashboardModel dashboardModel;
  late AnimationController _entryController;
  late Animation<double> _entryFade;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    Future.delayed(Duration.zero, () {
      Provider.of<DashboardModel>(context, listen: false).setContext(context);
      Provider.of<DashboardModel>(context, listen: false).loadItems();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);
    return Scaffold(
      body: FadeTransition(
        opacity: _entryFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4338ca), Color(0xFF6366f1), Color(0xFF818cf8)],
            ),
          ),
          child: SafeArea(
            child:
                dashboardModel.isError ? _errorView() : _loadingView(),
          ),
        ),
      ),
    );
  }

  Widget _loadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        // Ripple loader with brand icon at center
        _RippleLoader(
          rippleColor: Colors.white,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          t.appname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            t.initializingapp,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const Spacer(flex: 3),
        _BouncingDots(color: Colors.white.withValues(alpha: 0.55)),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _errorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          t.appname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            t.errorinitapp,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ),
        const Spacer(flex: 3),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => dashboardModel.loadItems(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4338ca),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                t.retry,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Expanding ripple rings ───────────────────────────────────────────────────

class _RippleLoader extends StatefulWidget {
  final Color rippleColor;
  final Widget child;

  const _RippleLoader({required this.rippleColor, required this.child});

  @override
  State<_RippleLoader> createState() => _RippleLoaderState();
}

class _RippleLoaderState extends State<_RippleLoader>
    with TickerProviderStateMixin {
  static const int _ringCount = 3;
  static const int _staggerMs = 580;
  static const int _durationMs = 1800;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _sizeAnims;
  late final List<Animation<double>> _opacityAnims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _ringCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _durationMs),
      ),
    );

    _sizeAnims = _controllers
        .map((c) => Tween<double>(begin: 90, end: 210).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _opacityAnims = _controllers
        .map((c) => Tween<double>(begin: 0.5, end: 0.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    for (int i = 0; i < _ringCount; i++) {
      Future.delayed(Duration(milliseconds: i * _staggerMs), () {
        if (mounted) _controllers[i].repeat();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(_ringCount, (i) {
            return AnimatedBuilder(
              animation: _controllers[i],
              builder: (_, __) {
                final size = _sizeAnims[i].value;
                final opacity = _opacityAnims[i].value.clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.rippleColor,
                        width: 1.8,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          widget.child,
        ],
      ),
    );
  }
}

// ─── Three staggered bouncing dots ───────────────────────────────────────────

class _BouncingDots extends StatefulWidget {
  final Color color;

  const _BouncingDots({required this.color});

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );

    _anims = _controllers
        .map((c) => Tween<double>(begin: 0, end: -11).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 155), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _anims[i].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
