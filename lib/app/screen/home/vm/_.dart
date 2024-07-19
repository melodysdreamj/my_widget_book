import 'package:june/june.dart';

import '../../../../../../../../../../../main.dart';

class HomeVM extends JuneState {
  bool _switchMobileMode = true;

  switchModel(bool value) {
    _switchMobileMode = value;
    print("switchModel: $_switchMobileMode");
    setState();
  }


  get switchMobileMode => _switchMobileMode;
}

/* usage
JuneBuilder(
  () => HomeVM(),
  builder: (vmHome) => widget
)
 */
