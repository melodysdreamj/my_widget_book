export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_svg/svg.dart';
export 'package:gap/gap.dart';
export 'package:styled_widget/styled_widget.dart';
import 'package:flutter/material.dart';

export 'util/_/shared_params/_/start_app_params.dart';
import 'app/home.dart';
import 'util/_/build_app/widget/run_app/_.dart';
export 'package:flutter/services.dart';
export 'util/_/build_app/widget/run_app/_.dart';
export 'package:june_flow_util/june_flow_util.dart';
import 'package:june_flow_util/june_flow_util.dart';

main() {
  return buildApp(home: HomeView());
}

class InitView extends StatelessWidget {
  const InitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Text(
            "New App",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          basicButton(context, "New Button", () {}),
        ],
      ),
    );
  }
}
