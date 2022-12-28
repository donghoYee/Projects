import 'package:pytorch_mobile/model.dart';
import 'package:pytorch_mobile/pytorch_mobile.dart';

Future<Model> load_resnet () async {
   return await PyTorchMobile.loadModel('assets/models/resnet.pt');
}




