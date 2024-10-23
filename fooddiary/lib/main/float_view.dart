import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fit_track/common/components/draggable_float/enum_state_event.dart';
import 'package:fit_track/views/base_view.dart';
import 'package:get/get.dart';

import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class HomeEvent {
  // final String value;
  HomeEvent();
}

class RefreshEvent {
  // final String value;
  RefreshEvent();
}
class ChangeEvent {
  // final String value;
  ChangeEvent();
}
class FloatLogic extends GetxController{
  var width = 26.0.obs;
  var isOpen = false.obs;
  var edgeWith = 0.0.obs;
  var canMoveBottom = false.obs;
  late StreamController<OperateEvent>? eventStreamController;
  void toggleWidth() {
    isOpen.value = false;
    width.value = (width.value == 26.0) ? 200.0 : 26.0;
  }
  @override
  void onInit() {
    eventStreamController = StreamController();
    super.onInit();

  }
  @override
  void onClose() {
    eventStreamController?.close();
    super.onClose();
  }

}

class FloatButtonView extends StatefulWidget {
  const FloatButtonView({super.key,this.eventStreamController});
  final StreamController<OperateEvent>? eventStreamController;
  @override
  State<FloatButtonView> createState() => _FloatButtonViewState();
}

class _FloatButtonViewState extends State<FloatButtonView> {
  bool isOpen = false;
  StreamController<OperateEvent>? eventStreamController;
   FloatLogic logic = Get.find<FloatLogic>();

  @override
  void initState() {
    super.initState();
    eventStreamController = widget.eventStreamController;
  }
  void homeAction() {
    if (Get.isRegistered<WebviewGetxLogic>()) {
      WebviewGetxLogic logic = Get.find<WebviewGetxLogic>();
      logic.loadHomePage();

      // eventBus.fire(HomeEvent());
    }
  }

  void backAction() {
    if (Get.isRegistered<WebviewGetxLogic>()) {
      WebviewGetxLogic logic = Get.find<WebviewGetxLogic>();
      logic.controller.goBack();
      // eventBus.fire(RefreshEvent());

    }
  }

  void cleanAction(){
    if (Get.isRegistered<WebviewGetxLogic>()) {
      WebviewGetxLogic logic = Get.find<WebviewGetxLogic>();

      logic.cleanCookies();
      // logic.loadHomePage();
      logic.loadHomePage();
      // eventBus.fire(RefreshEvent());

    }
  }

  void refreshAction() {
    if (Get.isRegistered<WebviewGetxLogic>()) {
      WebviewGetxLogic logic = Get.find<WebviewGetxLogic>();
      logic.controller.reload();
      // eventBus.fire(RefreshEvent());
    }
  }
  void changeAction() {
    if (Get.isRegistered<WebviewGetxLogic>()) {
      eventBus.fire(ChangeEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        logic.toggleWidth();
      },
      child: Obx(
            () => AnimatedContainer(
          width: logic.width.value,
          height: 45.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          onEnd: () {
            if (200 == logic.width.value) {
              logic.isOpen.value = true;
              // eventStreamController?.add(OperateEvent.OPERATE_SHOW);
            } else {
              logic.isOpen.value = false;
              // eventStreamController?.add(OperateEvent.OPERATE_HIDE);
            }
          },
          decoration:  BoxDecoration(
              color: const Color(0xff5f60b1).withOpacity(0.9),
              borderRadius:  const BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  logic.toggleWidth();
                },
                child: SizedBox(
                  width: 26,
                  height: 30,
                  child: logic.isOpen.value
                      ? const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  )
                      : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                ),

              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (logic.isOpen.value)
                      GestureDetector(
                          onTap: () {
                            homeAction();
                            logic.width.value = 26;
                          },
                          child:  Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.asset('assets/covers/icon_home.png'),
                          ),
                      ),
                    if (logic.isOpen.value)
                      GestureDetector(
                        onTap: () {
                          refreshAction();
                          logic.width.value = 26;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Image.asset('assets/covers/icon_refresh.png'),
                        ),
                      ),
                    // if (logic.isOpen.value)
                    //   GestureDetector(
                    //     onTap: () {
                    //       changeAction();
                    //     },
                    //     child: const Icon(Icons.cleaning_services_rounded,color:Colors.white,size: 30,),
                    //   ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
