import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RoundButtonView extends StatefulWidget {
  final double? width;
  final double? height;
  final TextSpan buttonText;

  final Duration reversePlusDuration;
  final double reversePlusDistance;

  final Duration plusDuration;
  final double plusDistance;
  final double borderThickness;

  final Color buttonColor;

  RoundButtonView({
    Key? key,
    this.width,
    this.height,
    this.reversePlusDistance = 20,
    required this.buttonText,
    this.plusDuration = const Duration(milliseconds: 300),
    this.buttonColor = const Color(0xFF42bcb6),
    this.plusDistance = 4,
    this.borderThickness = 2,
    this.reversePlusDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _RoundButtonViewState createState() => _RoundButtonViewState();
}

class _RoundButtonViewState extends State<RoundButtonView>
    with TickerProviderStateMixin {
  late AnimationController plusAnimationController;
  late AnimationController reversePlusAnimationController;
  @override
  void initState() {
    plusAnimationController =
        AnimationController(vsync: this, duration: widget.plusDuration);
    reversePlusAnimationController =
        AnimationController(vsync: this, duration: widget.reversePlusDuration);

    plusAnimationController.addListener(() {
      if (plusAnimationController.isCompleted) {
        plusAnimationController.reverse();
      }
      if (plusAnimationController.isDismissed) {
        reversePlusAnimationController.forward();
        Future.delayed(Duration(seconds: 3), () {
          plusAnimationController.forward();
        });
      }
    });

    reversePlusAnimationController.addListener(() {
      if (reversePlusAnimationController.isCompleted) {
        reversePlusAnimationController.reset();
      }
    });

    plusAnimationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      child: _RoundButtonViewWidgetObject(
        state: this,
      ),
    );
  }
}

class _RoundButtonViewWidgetObject extends LeafRenderObjectWidget {
  _RoundButtonViewWidgetObject({
    required this.state,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RoundButtonViewRenderBox(state: state);
  }

  final _RoundButtonViewState state;

  @override
  void updateRenderObject(
      BuildContext context, covariant _RoundButtonViewRenderBox renderObject) {}
}

class _RoundButtonViewRenderBox extends RenderBox {
  final _RoundButtonViewState state;
  Animation plusAnimation;

  _RoundButtonViewRenderBox({
    required this.state,
  }) : plusAnimation = CurvedAnimation(
            parent: state.plusAnimationController, curve: Curves.ease);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(
      state.widget.width ??
          (constraints.hasBoundedWidth ? constraints.maxWidth : 140),
      state.widget.height ??
          (constraints.hasBoundedHeight ? constraints.maxHeight : 140),
    );
  }

  @override
  bool get sizedByParent => true;

  Path? path;
  Path? closePathFormGradient;
  @override
  void paint(PaintingContext context, Offset offset) {
    // //listen animaiton status
    // if (state.animationController.status == AnimationStatus.completed ||
    //     state.animationController.status == AnimationStatus.dismissed) {
    //   state.lastValue = value;
    //   state.lastProgress = precentage;
    // }

    Canvas canvas = context.canvas;

    canvas.translate(offset.dx, offset.dy);

    Rect rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height);

    double buttonRadius = size.width / 2 - state.widget.reversePlusDistance;

    Paint paint = Paint()
      ..color = state.widget.buttonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = state.widget.borderThickness;

    canvas.drawCircle(rect.center,
        buttonRadius - state.widget.plusDistance * plusAnimation.value, paint);

    if (state.reversePlusAnimationController.isAnimating) {
      canvas.drawCircle(
          rect.center,
          buttonRadius +
              state.widget.reversePlusDistance *
                  state.reversePlusAnimationController.value,
          paint
            ..color = state.widget.buttonColor
                .withOpacity(1 - state.reversePlusAnimationController.value));
    }

    final textPainter = TextPainter(
      text: state.widget.buttonText,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final xCenter = (textPainter.width) / 2;
    final yCenter = (textPainter.height) / 2;
    final textCenterOffset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, rect.center - textCenterOffset);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    state.plusAnimationController.addListener(markNeedsPaint);
    state.reversePlusAnimationController.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    state.plusAnimationController.removeListener(markNeedsPaint);
    state.reversePlusAnimationController.removeListener(markNeedsPaint);
    super.detach();
  }

  // @override
  // bool hitTestSelf(Offset position) => true;
}
