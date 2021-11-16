import 'dart:math';

import 'package:flutter/material.dart';

import 'chart_style.dart';
import 'entity/depth_entity.dart';

/// 買賣量深度表
class DepthChart extends StatefulWidget {
  final List<DepthEntity> bids, asks;
  final DepthStyle style;

  const DepthChart({
    Key? key,
    required this.bids,
    required this.asks,
    this.style = const DepthStyle.light(),
  }) : super(key: key);

  @override
  _DepthChartState createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> {
  Offset? pressOffset;
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        pressOffset = details.globalPosition;
        isLongPress = true;
        setState(() {});
      },
      onLongPressMoveUpdate: (details) {
        pressOffset = details.globalPosition;
        isLongPress = true;
        setState(() {});
      },
      onTap: () {
        if (isLongPress) {
          isLongPress = false;
          setState(() {});
        }
      },
      child: CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: DepthChartPainter(
          style: widget.style,
          buyData: widget.bids,
          sellData: widget.asks,
          pressOffset: pressOffset,
          isLongPress: isLongPress,
        ),
      ),
    );
  }
}

class DepthChartPainter extends CustomPainter {
  final DepthStyle style;

  //买入//卖出
  List<DepthEntity> buyData, sellData;
  Offset? pressOffset;
  bool isLongPress;

  double mPaddingBottom = 18.0;
  double mWidth = 0.0, mDrawHeight = 0.0, mDrawWidth = 0.0;

  late double mBuyPointWidth, mSellPointWidth;

  //最大的委托量
  late double mMaxVolume, mMultiple;

  //右侧绘制个数
  int mLineCount = 4;

  late Path mBuyPath, mSellPath;

  //买卖出区域边线绘制画笔  //买卖出取悦绘制画笔
  late Paint mBuyLinePaint, mSellLinePaint, mBuyPathPaint, mSellPathPaint;

  DepthChartPainter({
    required this.style,
    required this.buyData,
    required this.sellData,
    this.pressOffset,
    required this.isLongPress,
  }) {
    mBuyLinePaint = Paint()
      ..isAntiAlias = true
      ..color = style.buyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    mSellLinePaint = Paint()
      ..isAntiAlias = true
      ..color = style.sellColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    mBuyPathPaint = Paint()
      ..isAntiAlias = true
      ..color = style.buyColor.withOpacity(0.2);
    mSellPathPaint = Paint()
      ..isAntiAlias = true
      ..color = style.sellColor.withOpacity(0.2);
    mBuyPath = Path();
    mSellPath = Path();

    selectPaint = Paint()
      ..isAntiAlias = true
      ..color = style.tooltipBgColor;
    selectBorderPaint = Paint()
      ..isAntiAlias = true
      ..color = style.tooltipBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    init();
  }

  void init() {
    if (buyData.isEmpty || sellData.isEmpty) return;
    mMaxVolume = buyData[0].amount;
    mMaxVolume = max(mMaxVolume, sellData.last.amount);
    mMaxVolume = mMaxVolume * 1.05;
    mMultiple = mMaxVolume / mLineCount;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (buyData.isEmpty || sellData.isEmpty) return;
    mWidth = size.width;
    mDrawWidth = mWidth / 2;
    mDrawHeight = size.height - mPaddingBottom;
//    canvas.drawColor(Colors.black, BlendMode.color);
    canvas.save();
    //绘制买入区域
    drawBuy(canvas);
    //绘制卖出区域
    drawSell(canvas);

    //绘制界面相关文案
    drawText(canvas);
    canvas.restore();
  }

  void drawBuy(Canvas canvas) {
    mBuyPointWidth =
        (mDrawWidth / (buyData.length - 1 == 0 ? 1 : buyData.length - 1));
    mBuyPath.reset();
    double y;
    for (int i = 0; i < buyData.length; i++) {
      if (i == 0) {
        mBuyPath.moveTo(0, getY(buyData[0].amount));
      }
      y = getY(buyData[i].amount);
      if (i >= 1) {
        canvas.drawLine(
            Offset(mBuyPointWidth * (i - 1), getY(buyData[i - 1].amount)),
            Offset(mBuyPointWidth * i, y),
            mBuyLinePaint);
      }
      if (i != buyData.length - 1) {
        mBuyPath.quadraticBezierTo(mBuyPointWidth * i, y,
            mBuyPointWidth * (i + 1), getY(buyData[i + 1].amount));
      }

      if (i == buyData.length - 1) {
        mBuyPath.quadraticBezierTo(
            mBuyPointWidth * i, y, mBuyPointWidth * i, mDrawHeight);
        mBuyPath.quadraticBezierTo(
            mBuyPointWidth * i, mDrawHeight, 0, mDrawHeight);
        mBuyPath.close();
      }
    }
    canvas.drawPath(mBuyPath, mBuyPathPaint);
  }

  void drawSell(Canvas canvas) {
    mSellPointWidth =
        (mDrawWidth / (sellData.length - 1 == 0 ? 1 : sellData.length - 1));
    mSellPath.reset();
    double y;
    for (int i = 0; i < sellData.length; i++) {
      if (i == 0) {
        mSellPath.moveTo(mDrawWidth, getY(sellData[0].amount));
      }
      y = getY(sellData[i].amount);
      if (i >= 1) {
        canvas.drawLine(
            Offset((mSellPointWidth * (i - 1)) + mDrawWidth,
                getY(sellData[i - 1].amount)),
            Offset((mSellPointWidth * i) + mDrawWidth, y),
            mSellLinePaint);
      }
      if (i != sellData.length - 1) {
        mSellPath.quadraticBezierTo(
            (mSellPointWidth * i) + mDrawWidth,
            y,
            (mSellPointWidth * (i + 1)) + mDrawWidth,
            getY(sellData[i + 1].amount));
      }
      if (i == sellData.length - 1) {
        mSellPath.quadraticBezierTo(
            mWidth, y, (mSellPointWidth * i) + mDrawWidth, mDrawHeight);
        mSellPath.quadraticBezierTo((mSellPointWidth * i) + mDrawWidth,
            mDrawHeight, mDrawWidth, mDrawHeight);
        mSellPath.close();
      }
    }
    canvas.drawPath(mSellPath, mSellPathPaint);
  }

  // int mLastPosition;

  void drawText(Canvas canvas) {
    double value;
    String str;
    for (int j = 0; j < mLineCount; j++) {
      value = mMaxVolume - mMultiple * j;
      str = value.toStringAsFixed(2);
      var tp = getTextPainter(str);
      tp.layout();
      tp.paint(
          canvas,
          Offset(
              mWidth - tp.width, mDrawHeight / mLineCount * j + tp.height / 2));
    }
    var startText = buyData.first.price.toStringAsFixed(2);
    TextPainter startTP = getTextPainter(startText);
    startTP.layout();
    startTP.paint(canvas, Offset(0, getBottomTextY(startTP.height)));

    var center =
        ((buyData.last.price + sellData.first.price) / 2).toStringAsFixed(2);
    TextPainter centerTP = getTextPainter(center);
    centerTP.layout();
    centerTP.paint(
        canvas,
        Offset(
            mDrawWidth - centerTP.width / 2, getBottomTextY(centerTP.height)));

    var endText = sellData.last.price.toStringAsFixed(2);
    TextPainter endTP = getTextPainter(endText);
    endTP.layout();
    endTP.paint(
        canvas, Offset(mWidth - endTP.width, getBottomTextY(endTP.height)));

    if (isLongPress == true) {
      if (pressOffset!.dx <= mDrawWidth) {
        int index =
            _indexOfTranslateX(pressOffset!.dx, 0, buyData.length, getBuyX);
        drawSelectView(canvas, index, true);
      } else {
        int index =
            _indexOfTranslateX(pressOffset!.dx, 0, sellData.length, getSellX);
        drawSelectView(canvas, index, false);
      }
    }
  }

  late Paint selectPaint;
  late Paint selectBorderPaint;

  void drawSelectView(Canvas canvas, int index, bool isLeft) {
    DepthEntity entity = isLeft ? buyData[index] : sellData[index];
    double dx = isLeft ? getBuyX(index) : getSellX(index);

    double radius = 8.0;
    if (dx < mDrawWidth) {
      canvas.drawCircle(Offset(dx, getY(entity.amount)), radius / 3,
          mBuyLinePaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(dx, getY(entity.amount)), radius,
          mBuyLinePaint..style = PaintingStyle.stroke);
    } else {
      canvas.drawCircle(Offset(dx, getY(entity.amount)), radius / 3,
          mSellLinePaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(dx, getY(entity.amount)), radius,
          mSellLinePaint..style = PaintingStyle.stroke);
    }

    //画底部
    TextPainter priceTP = getTextPainter(entity.price.toStringAsFixed(2));
    priceTP.layout();
    double left;
    if (dx <= priceTP.width / 2) {
      left = 0;
    } else if (dx >= mWidth - priceTP.width / 2) {
      left = mWidth - priceTP.width;
    } else {
      left = dx - priceTP.width / 2;
    }
    Rect bottomRect = Rect.fromLTRB(left - 3, mDrawHeight + 3,
        left + priceTP.width + 3, mDrawHeight + mPaddingBottom);
    canvas.drawRect(bottomRect, selectPaint);
    canvas.drawRect(bottomRect, selectBorderPaint);
    priceTP.paint(
        canvas,
        Offset(bottomRect.left + (bottomRect.width - priceTP.width) / 2,
            bottomRect.top + (bottomRect.height - priceTP.height) / 2));
    //画左边
    TextPainter amountTP = getTextPainter(entity.amount.toStringAsFixed(2));
    amountTP.layout();
    double y = getY(entity.amount);
    double rightRectTop;
    if (y <= amountTP.height / 2) {
      rightRectTop = 0;
    } else if (y >= mDrawHeight - amountTP.height / 2) {
      rightRectTop = mDrawHeight - amountTP.height;
    } else {
      rightRectTop = y - amountTP.height / 2;
    }
    Rect rightRect = Rect.fromLTRB(mWidth - amountTP.width - 6,
        rightRectTop - 3, mWidth, rightRectTop + amountTP.height + 3);
    canvas.drawRect(rightRect, selectPaint);
    canvas.drawRect(rightRect, selectBorderPaint);
    amountTP.paint(
        canvas,
        Offset(rightRect.left + (rightRect.width - amountTP.width) / 2,
            rightRect.top + (rightRect.height - amountTP.height) / 2));
  }

  ///二分查找当前值的index
  int _indexOfTranslateX(double translateX, int start, int end, Function getX) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid, getX);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end, getX);
    } else {
      return mid;
    }
  }

  double getBuyX(int position) => position * mBuyPointWidth;

  double getSellX(int position) => position * mSellPointWidth + mDrawWidth;

  getTextPainter(String text) => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: style.textColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

  double getBottomTextY(double textHeight) =>
      (mPaddingBottom - textHeight) / 2 + mDrawHeight;

  double getY(double volume) =>
      mDrawHeight - (mDrawHeight) * volume / mMaxVolume;

  @override
  bool shouldRepaint(DepthChartPainter oldDelegate) {
//    return oldDelegate.mBuyData != mBuyData ||
//        oldDelegate.mSellData != mSellData ||
//        oldDelegate.isLongPress != isLongPress ||
//        oldDelegate.pressOffset != pressOffset;
    return true;
  }
}
