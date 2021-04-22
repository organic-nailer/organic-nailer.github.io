import 'dart:async';

import 'package:flutter/material.dart';

abstract class GameObject {
	String name;
	void update(Size size);
	void paint(Canvas canvas);
	bool isInCanvas(Size canvasSize);
}

class LogoObject extends GameObject {
	final double width;
	double partWidth;
	double partOffset;
	double positionX, positionY;
	double velocityX, velocityY;
	Function reflectedListener;
	Color color;
	LogoObject(this.width, this.positionX, this.positionY, this.velocityX, this.velocityY) {
		partWidth = width * 4 / 9;
		partOffset = width * 5 / 9;
	}
	@override
	set name(String _name) => "logo";
	@override
	void update(Size size) {
		//print("$positionX $positionY");
		positionX += velocityX;
		positionY += velocityY;
		var reflected = false;
		if(positionX <= 0 || positionX >= size.width - width) {
			velocityX = -velocityX;
			reflected = true;
		}
		if(positionY <= 0 || positionY >= size.height - width) {
			velocityY = -velocityY;
			reflected = true;
		}
		if(reflected && reflectedListener != null) {
			reflectedListener();
		}
	}
	@override
	void paint(Canvas canvas) {
		var paint = Paint();
		paint.color = color;
		var path1 = Path();
		path1.moveTo(positionX, positionY);
		path1.lineTo(positionX + partWidth, positionY);
		path1.lineTo(positionX + partWidth, positionY + partWidth);
		path1.lineTo(positionX, positionY + partWidth);
		path1.close();
		canvas.drawPath(path1, paint);
		var path2 = Path();
		path2.moveTo(positionX, positionY + partOffset);
		path2.lineTo(positionX + partWidth, positionY + partOffset);
		path2.lineTo(positionX + partWidth, positionY + partOffset + partWidth);
		path2.lineTo(positionX, positionY + partOffset + partWidth);
		path2.close();
		canvas.drawPath(path2, paint);
		var path3 = Path();
		path3.moveTo(positionX + partOffset, positionY + partOffset);
		path3.lineTo(positionX + partOffset + partWidth, positionY + partOffset + partWidth);
		path3.lineTo(positionX + partOffset, positionY + partOffset + partWidth);
		path3.close();
		canvas.drawPath(path3, paint);
		canvas.drawCircle(Offset(positionX + partOffset + partWidth * 0.5, positionY + partWidth * 0.5), partWidth * 0.5, paint);
	}
	@override
	bool isInCanvas(Size canvasSize) => true;
}

typedef UpdateListener = void Function(Timer timer, List<GameObject> objects, Size canvasSize);

class GameCanvasEngine with ChangeNotifier {
	List<GameObject> gameObjects = [];
	Size canvasSize;

	Timer _updateTimer;
	final UpdateListener updateListener;

	GameCanvasEngine(this.updateListener);

	void notify() {
		notifyListeners();
	}

	void setCanvasSize(Size size) {
		canvasSize = size;
	}

	void update(Timer timer) {
		updateListener(timer, gameObjects, canvasSize);
		notifyListeners();
	}

	void addObject(GameObject obj) {
		gameObjects.add(obj);
		notifyListeners();
	}

	void cancelEngine() {
		print("engine canceled ${this.hashCode}");
		_updateTimer?.cancel();
		gameObjects.clear();
	}

	void pauseEngine() {
		print("engine paused ${this.hashCode}");
		_updateTimer?.cancel();
	}

	void resumeEngine() {
		print("engine resumed ${this.hashCode}");
		_updateTimer = Timer.periodic(const Duration(milliseconds: 33), update);
	}
}