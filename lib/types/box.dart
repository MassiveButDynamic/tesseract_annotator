class TessBox {
  int x;
  int y;
  int w;
  int h;
  String letter;

  TessBox({this.x = 0, this.y = 0, this.w = 0, this.h = 0, this.letter = ""});

  TessBox copyWith({int? x, int? y, int? w, int? h, String? letter}) {
    return TessBox(
        x: x ?? this.x,
        y: y ?? this.y,
        w: w ?? this.w,
        h: h ?? this.h,
        letter: letter ?? this.letter);
  }
}
