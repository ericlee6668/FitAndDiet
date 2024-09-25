
import 'package:get/get.dart';


import 'package:permission_handler/permission_handler.dart';

class WaterLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  var total = 500.obs;

  var cost = 0.obs;

  var waterTotal = 2000.obs;

  var waterDrink = 0.obs;

  var calTotal = 500.obs;

  var afid = '';



  addTotalWater() {
    waterTotal.value = waterTotal.value + 100;
  }

  reduceTotalWater() {
    var value = waterTotal.value - 100;

    waterTotal.value = value > 0 ? value : 0;
  }

  addTotalcal() {
    calTotal.value = calTotal.value + 100;
  }

  reduceTotalcal() {
    var value = calTotal.value - 100;

    calTotal.value = value > 0 ? value : 0;
  }

  drinkwater(){
    waterDrink.value = waterDrink.value + 100;
  }


  reducewater(){
    var value = waterDrink.value - 100;

    waterDrink.value = value > 0 ? value : 0;

  }



  @override
  void onInit() {
    super.onInit();

  }

}
