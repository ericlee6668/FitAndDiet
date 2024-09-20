// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fit_track/main/float_view.dart';
import 'package:fit_track/views/base_view.dart';
import 'package:fit_track/views/me/us/us.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../../../common/utils/tool_widgets.dart';
import '../../common/global/constants.dart';
import '../../common/utils/db_user_helper.dart';
import '../../main/themes/cus_font_size.dart';
import '../../models/cus_app_localizations.dart';
import '../../models/user_state.dart';

// import '_feature_mock_data/me_page.dart';
import 'backup_and_restore/index.dart';
import 'intake_goals/intake_target.dart';
import 'more_settings/index.dart';
import 'training_setting/index.dart';
import 'user_info/index.dart';
import 'user_info/modify_user/index.dart';
import 'weight_change_record/index.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  final DBUserHelper _userHelper = DBUserHelper();

  // 用户头像路径
  String _avatarPath = "";

  // 这里有修改，暂时不用get
  int currentUserId = 1;

// ？？？登录用户信息，怎么在app中记录用户信息？缓存一个用户id每次都查？记住状态实时更新？……
  late User userInfo;

  bool isLoading = false;

// 切换用户时，选择的用户
  User? selectedUser;

  @override
  void initState() {
    super.initState();

    setState(() {
      currentUserId = CacheUser.userId;
    });

    _queryLoginedUserInfo();
    eventBus.on<String>().listen((event) {
       if(event=='updateAvatar'){
         _queryLoginedUserInfo();
       }
    });
  }

  _queryLoginedUserInfo() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    // 查询登录用户的信息一定会有的
    var tempUser = (await _userHelper.queryUser(userId: currentUserId))!;

    setState(() {
      userInfo = tempUser;
      if (tempUser.avatar != null) {
        _avatarPath = tempUser.avatar!;
      } else {
        // 不清空，切换用户可能还是之前用户的头像
        _avatarPath = "";
      }
      isLoading = false;
    });
  }

  // 弹窗切换用户
  _switchUser() async {
    var userList = await _userHelper.queryUserList();

    if (!mounted) return;
    if (userList != null && userList.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CusAL.of(context).tipLabel),
            content: Text(CusAL.of(context).noOtherUser),
            actions: [
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
                child: Text(CusAL.of(context).confirmLabel),
              ),
            ],
          );
        },
      );
    } else if (userList != null && userList.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CusAL.of(context).switchUser),
            content: DropdownButtonFormField<User>(
              value: userList.firstWhere((e) => e.userId == currentUserId),
              decoration: const InputDecoration(
                // 设置透明底色
                filled: true,
                fillColor: Colors.transparent,
              ),
              items: userList.map((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text(user.userName),
                );
              }).toList(),
              onChanged: (User? value) async {
                setState(() {
                  selectedUser = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context, false);
                },
                child: Text(CusAL.of(context).cancelLabel),
              ),
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
                child: Text(CusAL.of(context).confirmLabel),
              ),
            ],
          );
        },
      ).then((value) async {
        // 如果有返回值且为true，
        if (value != null && value == true) {
          // 修改缓存的用户编号
          CacheUser.updateUserId(selectedUser!.userId!);
          CacheUser.updateUserName(selectedUser!.userName);
          CacheUser.updateUserCode(selectedUser!.userCode ?? "");

          // 重新缓存当前用户编号和查询用户信息
          setState(() {
            currentUserId = CacheUser.userId;
            _queryLoginedUserInfo();
          });
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    // 计算屏幕剩余的高度
    // 设备屏幕的总高度
    //  - 屏幕顶部的安全区域高度，即状态栏的高度
    //  - 屏幕底部的安全区域高度，即导航栏的高度或者虚拟按键的高度
    //  - 应用程序顶部的工具栏（如 AppBar）的高度
    //  - 应用程序底部的导航栏的高度
    //  - 组件的边框间隔(不一定就是2)
    double screenBodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight -
        kBottomNavigationBarHeight;

    print("screenBodyHeight--------$screenBodyHeight");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          CusAL.of(context).moduleTitles('3'),
        ),
        actions: [
          // IconButton0
          // 切换用户(切换后缓存的用户编号也得修改)
          IconButton(
            onPressed: _switchUser,
            icon: const Icon(Icons.toggle_on),
          ),
          // 新增用户(默认就一个用户，保存多个用户的数据就需要可以新增其他用户)
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModifyUserPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? buildLoader(isLoading)
          : Container(
        color:  Color(box.read('mode')=='dark'?0xff232229:0xfff5f5f5),
            child: ListView(
                children: [
                  /// 用户基本信息展示区域(固定高度10+120+120=250)
                  ..._buildBaseUserInfoArea(userInfo),

                  /// 功能区，参看别的app大概留几个
                  /// 功能区的占位就是除去状态栏、标题、底部按钮、头像区域个人信息外的高度进行等分
                  /// 底部还预留20sp
                  // 基本信息和体重趋势
                  // SizedBox(
                  //   height: (screenBodyHeight - 250 - 20) / 3,
                  //   child: _buildInfoAndWeightChangeRow(),
                  // ),
                  //
                  // // 摄入目标和运动设置
                  // SizedBox(
                  //   height: (screenBodyHeight - 250 - 20) / 3,
                  //   child: _buildIntakeGoalAndRestTimeRow(),
                  // ),
                  //
                  // // 备份还原和更多设置
                  // SizedBox(
                  //   height: (screenBodyHeight - 250 - 20) / 3,
                  //   child: _buildBakAndRestoreAndMoreSettingRow(),
                  // ),
                  _buildFunctionArea(),
                  const SizedBox(height: 10,),
                  _buildInformation(),
                  const SizedBox(height: 20,)
                ],
              ),
          ),
    );
  }

  // 用户基本信息展示区域
  _buildBaseUserInfoArea(User userInfo) {
    return [
      SizedBox(height: 10.sp),
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/covers/bg.png',height: 140,width:MediaQuery.of(context).size.width,fit: BoxFit.cover,),
          // 没有修改头像，就用默认的
          Positioned(
            top: 90.sp,
            right: 0.5.sw - 70.sp,
            child: userInfo.gender == "male"
                ? Icon(
                    Icons.male,
                    size: CusIconSizes.iconBig,
                    color: Colors.red,
                  )
                : userInfo.gender == "female"
                    ? Icon(
                        Icons.female,
                        size: CusIconSizes.iconBig,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        size: CusIconSizes.iconNormal,
                        color: Theme.of(context).disabledColor,
                      ),
          ),
          Positioned(
            top: 0.sp,
            right: 0.sp,
            child: Text(
              '',
              style: TextStyle(fontSize: CusFontSizes.flagTiny),
            ),
          ),
        ],
      ),
      Container(
        decoration: BoxDecoration(
            color:Color(box.read('mode')=='dark'?0xff232229:0xffffffff),
            borderRadius: BorderRadius.circular(20)
        ),
        margin: EdgeInsets.all(10.w),
        height: 120.sp,
        child: Row(
          children: [
            if (_avatarPath.isEmpty)
              Positioned(
                child: Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(left: 20),
                  child: CircleAvatar(
                    maxRadius: 60.sp,
                    backgroundColor: Colors.transparent,
                    backgroundImage: const AssetImage(defaultAvatarImageUrl),
                    // y圆形头像的边框线
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_avatarPath.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // 这个直接弹窗显示图片可以缩放
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent, // 设置背景透明
                        child: PhotoView(
                          imageProvider: FileImage(File(_avatarPath)),
                          // 设置图片背景为透明
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          // 可以旋转
                          // enableRotation: true,
                          // 缩放的最大最小限制
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(left: 20),
                  child: CircleAvatar(
                    maxRadius: 60.sp,
                    backgroundImage: FileImage(File(_avatarPath)),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 用户名、代号、简述
                  ListTile(
                    title: Text(
                      userInfo.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: CusFontSizes.flagMediumBig,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "@${userInfo.userCode ?? 'unkown'}",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              
                  // 用户简介 description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.sp),
                    child: Text(
                      "${userInfo.description ?? 'no description'} ",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: CusFontSizes.pageContent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  _buildInfoAndWeightChangeRow() {
    return Row(
      children: [
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.account_circle_outlined,
            title: CusAL.of(context).settingLabels('0'),
            onTap: () {
              // 处理相应的点击事件
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserInfo(),
                ),
              ).then((value) {
                // 确认新增成功后重新加载当前日期的条目数据
                _queryLoginedUserInfo();
              });
            }, icon: '',
          ),
        ),
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.trending_down_outlined,
            title: CusAL.of(context).settingLabels('1'),
            onTap: () {
              // 处理相应的点击事件
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeightTrendRecord(userInfo: userInfo),
                ),
              ).then((value) {
                // 确认新增成功后重新加载当前日期的条目数据
                if (value != null && value == true) {
                  _queryLoginedUserInfo();
                }
              });
            }, icon: '',
          ),
        ),
      ],
    );
  }

  _buildIntakeGoalAndRestTimeRow() {
    return Row(
      children: [
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.golf_course_outlined,
            title: CusAL.of(context).settingLabels('2'),
            onTap: () {
              // 处理相应的点击事件
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntakeTargetPage(userInfo: userInfo),
                ),
              ).then((value) {
                // 确认新增成功后重新加载当前日期的条目数据
                _queryLoginedUserInfo();
              });
            }, icon: '',
          ),
        ),
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.run_circle_outlined,
            title: CusAL.of(context).settingLabels('3'),
            onTap: () {
              // 处理相应的点击事件
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainingSetting(userInfo: userInfo),
                ),
              ).then((value) {
                // 确认新增成功后重新加载当前日期的条目数据
                _queryLoginedUserInfo();
              });
            }, icon: '',
          ),
        ),
      ],
    );
  }

  _buildBakAndRestoreAndMoreSettingRow() {
    return Row(
      children: [
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.backup_outlined,
            title: CusAL.of(context).settingLabels('4'),
            onTap: () {
              // 处理相应的点击事件

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupAndRestore(),
                ),
              );
            }, icon: '',
          ),
        ),
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.more_horiz_outlined,
            title: CusAL.of(context).settingLabels('5'),
            onTap: () {
              // 处理相应的点击事件

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoreSettings(),
                ),
              );
            }, icon: '',
          ),
        ),
        NewCusSettingCard(
          leadingIcon: Icons.run_circle_outlined,
          title: CusAL.of(context).settingLabels('3'),
          onTap: () {
            // 处理相应的点击事件
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingSetting(userInfo: userInfo),
              ),
            ).then((value) {
              // 确认新增成功后重新加载当前日期的条目数据
              _queryLoginedUserInfo();
            });
          }, icon: '',
        ),
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.backup_outlined,
            title: CusAL.of(context).settingLabels('4'),
            onTap: () {
              // 处理相应的点击事件

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupAndRestore(),
                ),
              );
            }, icon: '',
          ),
        ),
        Expanded(
          child: NewCusSettingCard(
            leadingIcon: Icons.more_horiz_outlined,
            title: CusAL.of(context).settingLabels('5'),
            onTap: () {
              // 处理相应的点击事件
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoreSettings(),
                ),
              );
            }, icon: '',
          ),
        ),
        // Expanded(
        //   child: NewCusSettingCard(
        //     leadingIcon: Icons.privacy_tip_sharp,
        //     title: '常见问题(tbd)',
        //     onTap: () {
        //       // 处理相应的点击事件
        //     },
        //   ),
        // ),
      ],
    );
  }

  _buildFunctionArea() {
    List<Widget> list = [
      NewCusSettingCard(
        leadingIcon: Icons.account_circle_outlined,
        title: CusAL.of(context).settingLabels('0'),
        onTap: () {
          // 处理相应的点击事件
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserInfo(),
            ),
          ).then((value) {
            // 确认新增成功后重新加载当前日期的条目数据
            _queryLoginedUserInfo();
          });
        }, icon: '',
      ),
      NewCusSettingCard(
        leadingIcon: Icons.trending_down_outlined,
        title: CusAL.of(context).settingLabels('1'),
        onTap: () {
          // 处理相应的点击事件
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeightTrendRecord(userInfo: userInfo),
            ),
          ).then((value) {
            // 确认新增成功后重新加载当前日期的条目数据
            if (value != null && value == true) {
              _queryLoginedUserInfo();
            }
          });
        }, icon: '',
      ),
      NewCusSettingCard(
        leadingIcon: Icons.golf_course_outlined,
        title: CusAL.of(context).settingLabels('2'),
        onTap: () {
          // 处理相应的点击事件
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IntakeTargetPage(userInfo: userInfo),
            ),
          ).then((value) {
            // 确认新增成功后重新加载当前日期的条目数据
            _queryLoginedUserInfo();
          });
        }, icon: '',
      ),
    ];
    var listDatas = [
      {
        'icon': 'assets/me/base_info.png',
        'title': CusAL.of(context).settingLabels('0'),
        'page': const UserInfo()
      },
      {
        'icon': 'assets/me/weight_trend.png',
        'title': CusAL.of(context).settingLabels('1'),
        'page': WeightTrendRecord(userInfo: userInfo)
      },
      {
        'icon': 'assets/me/intake_goal.png',
        'title': CusAL.of(context).settingLabels('2'),
        'page': IntakeTargetPage(userInfo: userInfo)
      },
      {
        'icon': 'assets/me/training_setting.png',
        'title': CusAL.of(context).settingLabels('3'),
        'page': TrainingSetting(userInfo: userInfo)
      },
      {
        'icon': 'assets/me/backup.png',
        'title': CusAL.of(context).settingLabels('4'),
        'page': const BackupAndRestore()
      },
      {
        'icon': 'assets/me/more_setting.png',
        'title': CusAL.of(context).settingLabels('5'),
        'page': const MoreSettings()
      },
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20)
      ),
      margin: EdgeInsets.all(10.w),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 1.5),
          itemCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            return Material(
              child: NewCusSettingCard(
                leadingIcon: Icons.add,
                icon: listDatas[i]['icon'] as String,
                title: listDatas[i]['title'] as String,
                onTap: () {
                  // 处理相应的点击事件
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => listDatas[i]['page'] as Widget,
                    ),
                  ).then((value) {
                    // 确认新增成功后重新加载当前日期的条目数据
                    if (value != null && value == true) {
                      _queryLoginedUserInfo();
                    }
                  });
                },
              ),
            );
          }),
    );
  }

  _buildInformation() {
    var list = [
      {
        'title': 'Disclaimer',
        'subTitle': '',
        'icon':Icons.notification_important_rounded,
        'page': () {
          SmartDialog.compatible.show(
            backDismiss: true,
            clickBgDismissTemp: true,
              widget: Container(
                height: 600,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white
                ),
                child:Column(
                  children: [
                    Image.asset('assets/covers/disclaimer.jpg'),
                    ElevatedButton(onPressed: ()=>SmartDialog.dismiss(), child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.0),
                      child: Text('confirm'),
                    ))
                  ],
                ),
              ),
              alignmentTemp: Alignment.bottomCenter);
        }
      },
      {'title': 'About Us',
        'subTitle': '',
        'icon':Icons.person_add_sharp,
        'page': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UsPage(),
          ),
        );
      }
      },
      {'title': 'Contact us',
        'subTitle': 'ehansenj8u@gmx.com',
        'icon':Icons.contact_page_sharp,
        'page': () {}},
      {'title': 'Version',
        'subTitle': 'V1.0.0',
        'icon':Icons.verified_sharp,
        'page': () {}}
    ];
    return Container(
      decoration: BoxDecoration(
          color:  Color(box.read('mode')=='dark'?0xff232229:0xffffffff),
          borderRadius: BorderRadius.circular(20)
      ),
      margin: EdgeInsets.all(10.w),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: list.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return InkWell(
            onTap: list[i]['page'] as void Function(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              height: 50,
              child: Row(
                children: [
                  Icon(list[i]['icon'] as IconData,color:box.read('mode')=='dark'? Colors.grey:Colors.black38,),
                  const SizedBox(width: 5),
                  Text(list[i]['title'] as String),
                  const Spacer(),
                  Row(
                    children: [
                      Text(list[i]['subTitle'] as String),
                      const Icon(Icons.arrow_forward_ios_outlined,color: Colors.grey,),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 1,);
        },
      ),
    );
  }
}

// 每个设置card抽出来复用
class NewCusSettingCard extends StatelessWidget {
  final IconData leadingIcon;
  final String icon;
  final String title;
  final VoidCallback onTap;

  const NewCusSettingCard({
    super.key,
    required this.leadingIcon,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60.sp,
        color: Color(box.read('mode')=='dark'?0xff232229:0xffffffff),
        padding: EdgeInsets.all(2.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon,width: 24.w,height: 24.w,),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: CusFontSizes.pageAppendix,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
