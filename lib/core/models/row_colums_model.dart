import 'package:flutter/material.dart';

class RowColumn {

  int row;
  int column;

  same(int row, int column) => row == this.row && column == this.column;

  RowColumn(this.row, this.column);

  maxSize (Size sizeBox) {
    double maxSize = calculateMaxSize(sizeBox);
    return Size(maxSize * column, maxSize * row);
  }

  calculateMaxSize(Size sizeBox) {
    double sizePerBox = sizeBox.width / column;

    while (sizePerBox * row > sizeBox.height || sizePerBox * column > sizeBox.width) {
      sizePerBox *= 0.95;
    }

    int maxSizeInt = sizePerBox.floor();

    return (maxSizeInt).toDouble();
  }

  Size calculateMaxSizeGame (Size biggest) {
    double totalRange = calculateMaxSize (biggest);
    return Size(totalRange * column, totalRange * row);
  }
  totalAllBox() => row * column;
}