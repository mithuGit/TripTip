import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: GameChooser()));
}

class GameWidgetReturn extends StatelessWidget {
  const GameWidgetReturn({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: GameChooser());
  }
}

class GameChooser extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(TapScreen());
  }
}

class TapScreen extends PositionComponent with DragCallbacks {
  TapScreen() : super(anchor: Anchor.center);

  static final farbe = Paint()..color = Colors.white;
  Map<int, FingerCircle> circles = {};
  Timer countdown = Timer(3, autoStart: false);
  bool tappable = true;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = Colors.black);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (this.size.x < 100 || this.size.y < 100) {
      this.size = size * 0.9;
    }
    position = size / 2;
  }

  @override
  void update(double dt) {
    countdown.update(dt);
    if (countdown.finished) {
      tappable = false;
      var winner = Random().nextInt(circles.length);
      var temp = circles.keys.last;
      for (var i = circles.keys.first; i < temp; i += 1) {
        if (i != winner) {
          circles.remove(i)!.release();
        }
      }
      circles[winner]!.ring.winner();
      countdown.pause();
      countdown.reset();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (tappable) {
      super.onDragStart(event);
      final circle =
          FingerCircle(event.localPosition, countdown, event.pointerId);
      if (circles.isEmpty) {
        countdown.start();
      }
      circles[event.pointerId] = circle;
      add(circle);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (tappable) {
      circles[event.pointerId]!.updatePos(event.localEndPosition);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (tappable) {
      super.onDragEnd(event);
      if (circles.containsKey(event.pointerId)) {
        circles.remove(event.pointerId)!.release();
        if (circles.isEmpty) {
          countdown.reset();
          countdown.stop();
        }
      }
    }
  }
}

class FingerCircle extends Component {
  FingerCircle(this.center, this.countdown, this.id);
  List<double> colors = [0, 26, 48, 89, 151, 180, 204, 219, 267, 299, 339];
  int id;
  Vector2 center;
  Timer countdown;
  late final Color baseColor =
      HSLColor.fromAHSL(1, colors[id % colors.length], 1, 0.6).toColor();

  bool released = false;
  double radius = 30;

  late final paint = Paint()
    ..style = PaintingStyle.fill
    ..color = baseColor;

  late Ring ring = Ring(center, baseColor, countdown);
  void release() => released = true;

  @override
  void onLoad() {
    add(ring);
  }

  void updatePos(Vector2 pos) {
    center = pos;
    ring.center = pos;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(center.toOffset(), radius, paint);
  }

  @override
  void update(double dt) {
    if (released) {
      removeFromParent();

      ring.release();
    } else {
      ring.update(dt);
    }
  }
}

class Ring extends PositionComponent {
  Ring(this.center, this.baseColor, this.countdown);
  Vector2 center;
  Color baseColor;
  Timer countdown;
  double degree = 0;
  final double radius = 85;
  final double width = 15;
  late final paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = baseColor
    ..strokeWidth = width;

  void release() => removeFromParent();

  @override
  void update(dt) {
    print(countdown.finished);
    if (countdown.finished) {
      degree = 360;
    } else {
      degree = (countdown.current / 3) * pi * 2;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawArc(
        Rect.fromCenter(
            center: center.toOffset(), width: radius, height: radius),
        pi * 1.5,
        degree,
        false,
        paint);
  }

  void winner() {
    add(ScaleEffect.by(
      Vector2(10, 10),
      EffectController(duration: 0.5, curve: Curves.easeIn),
    ));
  }
}
