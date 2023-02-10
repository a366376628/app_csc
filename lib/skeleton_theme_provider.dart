import 'package:flutter/cupertino.dart';
import 'package:laundrivr/src/model/provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonThemeProvider extends Provider<SkeletonTheme> {
  Widget materialApp;

  SkeletonThemeProvider({required this.materialApp});

  @override
  void initialize() {
    // TODO: implement initialize
  }

  @override
  SkeletonTheme provide() {
    return SkeletonTheme(
      darkShimmerGradient: const LinearGradient(
        colors: [
          Color(0xff0F162A),
          Color(0xff14223D),
          Color(0xff14223D),
          Color(0xff0F162A),
        ],
        stops: [
          0.0,
          0.3,
          1,
          1,
        ],
        begin: Alignment(-1, 0),
        end: Alignment(1, 0),
      ),
      child: materialApp,
    );
  }
}
