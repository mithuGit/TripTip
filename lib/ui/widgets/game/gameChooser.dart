// ignore_for_file: file_names

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// this class is our one more thing => is a chooser game that is played by tapping on the screen

class GameWidgetReturn extends StatefulWidget {
  const GameWidgetReturn({super.key});

  @override
  State<GameWidgetReturn> createState() => _GameWidgetReturn();
}

///Game Widget to inbed into flutter
class _GameWidgetReturn extends State<GameWidgetReturn> {
  @override
  Widget build(BuildContext context) {
    return GameWidget(game: GameChooser(context: context, widget: this));
  }
}

///Main Game class
class GameChooser extends FlameGame {
  GameChooser({required this.context, required this.widget});
  // ignore: library_private_types_in_public_api
  _GameWidgetReturn widget;
  BuildContext context;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(TapScreen(context, widget));
  }
}

///Background of game which constantly checks for user input to display the circles, also handles game loop to update game state via countdown timer and then buttons
class TapScreen extends PositionComponent with DragCallbacks {
  TapScreen(this.context, this.widget) : super(anchor: Anchor.center);

  static final farbe = Paint()..color = Colors.white;
  Map<int, FingerCircle> circles = {};
  Timer countdown = Timer(3, autoStart: false);
  bool tappable = true;
  List<double> colors = [345, 240, 128, 52, 191, 268, 138, 0, 60, 25];
  int colorcounter = 0;
  BuildContext context;
  _GameWidgetReturn widget;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        size.toRect(), Paint()..color = const Color.fromARGB(255, 17, 17, 17));
  }

  ///Used to bring TapScreen to screen size
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (this.size.x < 100 || this.size.y < 100) {
      this.size = size * 0.9;
    }
    position = size / 2;
  }

  ///When player start placing finger on screen
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (tappable) {
      final circle = FingerCircle(event.localPosition, countdown,
          event.pointerId, colors[colorcounter % colors.length]);
      colorcounter++;
      if (circles.isEmpty) {
        countdown.start();
      }
      circles[event.pointerId] = circle;
      add(circle);
    }
  }

  ///Main game loop
  @override
  void update(double dt) {
    if (countdown.finished) {
      tappable = false;
      var winner = Random().nextInt(circles.length) + circles.keys.first;
      var temp = circles.keys.last;
      for (int i = circles.keys.first; i < temp + 1; i += 1) {
        if (i != winner) {
          remove(circles.remove(i)!);
        }
      }
      circles[circles.keys.first]!.winner();
      add(FinishButton(
          func: () {
            widget.setState(() {});
          },
          text: "Play Again",
          position: Vector2(size.x / 4, size.y / 4)));
      add(FinishButton(
          func: () {
            context.pop();
          },
          text: "Go Back",
          position: Vector2(size.x / 4, size.y / 4 + 50)));
      countdown.stop();
    } else {
      countdown.update(dt);
    }
  }

  ///When player drags finger
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (tappable) {
      circles[event.pointerId]!.updatePos(event.localEndPosition);
    }
  }

  ///When player removes his finger
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (tappable) {
      if (circles.containsKey(event.pointerId)) {
        remove(circles[event.pointerId]!);
        circles.remove(event.pointerId);
        if (circles.isEmpty) {
          countdown.stop();
        }
      }
    }
  }
}

///Circle under fingers, also handles the ring
class FingerCircle extends Component {
  FingerCircle(this.center, this.countdown, this.id, this.color);
  int id;
  Vector2 center;
  Timer countdown;
  double color;
  late final Color baseColor = HSLColor.fromAHSL(1, color, 1, 0.6).toColor();

  bool released = false;
  double radius = 30;

  late final paint = Paint()
    ..style = PaintingStyle.fill
    ..color = baseColor;

  late Ring ring = Ring(center, baseColor, countdown);

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

  void winner() {
    add(FinishEffect(center, baseColor));
  }
}

///Ring around the circle
class Ring extends PositionComponent {
  Ring(this.center, this.baseColor, this.countdown);
  Vector2 center;
  Color baseColor;
  Timer countdown;
  double degree = 0;
  double radius = 90;
  double width = 15;
  late final paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = baseColor
    ..strokeWidth = width;

  ///updates every frame
  @override
  void update(dt) {
    if (countdown.finished) {
      degree = 0;
    } else {
      degree = (countdown.current / 3) * pi * 2;
    }
  }

  ///renders circle every frame, also depending on countdown percent
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
}

///EndEffect when player wins, renders another circle that encloses into the point
class FinishEffect extends PositionComponent {
  FinishEffect(this.center, this.baseColor);
  Vector2 center;
  Color baseColor;
  double radius = 2000;
  double width = 100;
  late var paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = baseColor
    ..strokeWidth = width;

  ///When node is deleted

  ///renders every frame
  @override
  void render(Canvas canvas) {
    canvas.drawArc(
        Rect.fromCenter(
            center: center.toOffset(), width: radius, height: radius),
        0,
        360,
        false,
        paint);
  }

  ///updates every frame
  @override
  void update(dt) {
    if (width < radius - 100) {
      width += 100;
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = baseColor
        ..strokeWidth = width;
    }
  }
}

///End buttons that pop up when game is done
class FinishButton extends PositionComponent with DragCallbacks, TapCallbacks {
  FinishButton({super.position, required this.func, required this.text});
  Function func;
  String text;
  Paint paint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color.fromARGB(255, 17, 17, 17)
    ..strokeWidth = 100;

  @override
  double width = 300;
  @override
  double height = 70;

  late Rect rect = Rect.fromCenter(
      center: position.toOffset(), width: width, height: height);

  @override
  onLoad() {
    super.onLoad();
    add(TextComponent(
        text: text,
        textRenderer:
            TextPaint(style: const TextStyle(fontSize: 32, color: Colors.white)),
        anchor: Anchor.center,
        position: position));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    func();
  }

  @override
  bool containsLocalPoint(Vector2 point) => rect.contains(point.toOffset());

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);
  }
}
