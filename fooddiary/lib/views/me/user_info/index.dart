import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:free_fitness/main/float_view.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/global/constants.dart';
import '../../../common/utils/db_user_helper.dart';
import '../../../common/utils/tool_widgets.dart';
import '../../../common/utils/tools.dart';
import '../../../main/themes/cus_font_size.dart';
import '../../../models/cus_app_localizations.dart';
import '../../../models/user_state.dart';
import 'modify_user/index.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final DBUserHelper _userHelper = DBUserHelper();

  late User user;
  // 用户头像路径
  String _avatarPath = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _queryLoginedUserInfo();
  }

  _queryLoginedUserInfo() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    // 查询登录用户的信息一定会有的
    var tempUser = (await _userHelper.queryUser(userId: CacheUser.userId))!;

    setState(() {
      user = tempUser;
      if (tempUser.avatar != null) {
        _avatarPath = tempUser.avatar!;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(CusAL.of(context).settingLabels("0")),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ModifyUserPage(user: user),
          //       ),
          //     ).then((value) {
          //       // 确认新增成功后重新加载当前日期的条目数据
          //       _queryLoginedUserInfo();
          //     });
          //   },
          //   child: Text(
          //     CusAL.of(context).eidtLabel(""),
          //     style: const TextStyle(color: Colors.white),
          //   ),
          // ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModifyUserPage(user: user),
                ),
              ).then((value) {
                // 确认新增成功后重新加载当前日期的条目数据
                _queryLoginedUserInfo();
              });
            },
            icon: const Icon(Icons.edit),
          )
        ],
      ),
      body: isLoading
          ? buildLoader(isLoading)
          : ListView(
              children: [
                SizedBox(height: 10.sp),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 没有修改头像，就用默认的
                    if (_avatarPath.isEmpty)
                      CircleAvatar(
                        maxRadius: 60.sp,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            const AssetImage(defaultAvatarImageUrl),
                        child: InkWell(
                          onTap: (){
                            _pickImage(ImageSource.gallery);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2.sp),
                            ),
                          ),
                        ),
                      ),
                    if (_avatarPath.isNotEmpty)
                      InkWell(
                        onTap: (){
                          _pickImage(ImageSource.gallery);
                        },
                        child: CircleAvatar(
                          maxRadius: 60.sp,
                          backgroundImage: FileImage(File(_avatarPath)),
                        ),
                      ),
                    Visibility(
                      visible: false,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  CusAL.of(context).changeAvatarLabels('1'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.camera);
                                    },
                                    child: Text(
                                      CusAL.of(context).changeAvatarLabels('2'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.gallery);
                                    },
                                    child: Text(
                                      CusAL.of(context).changeAvatarLabels('3'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          CusAL.of(context).changeAvatarLabels('0'),
                          style: TextStyle(fontSize: CusFontSizes.flagTiny),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("0"),
                      user.userName,
                    ),
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("1"),
                      user.userCode ?? "",
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("2"),
                      showCusLableMapLabel(
                        context,
                        genderOptions.firstWhere((e) => e.value == user.gender),
                      ),
                    ),
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("3"),
                      user.dateOfBirth ?? "",
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("4"),
                      '${cusDoubleTryToIntString(user.height ?? 0)} ${CusAL.of(context).unitLabels("4")}',
                    ),
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("5"),
                      '${cusDoubleTryToIntString(user.currentWeight ?? 0)} ${CusAL.of(context).unitLabels("5")}',
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildListItem(
                      CusAL.of(context).userGoalLabels("0"),
                      '${user.rdaGoal ?? ""} ${CusAL.of(context).unitLabels("2")}',
                    ),
                    _buildListItem(
                      CusAL.of(context).userGoalLabels("1"),
                      '${user.actionRestTime ?? ""} ${CusAL.of(context).unitLabels("6")}',
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildListItem(
                      CusAL.of(context).userInfoLabels("6"),
                      user.description ?? "",
                    ),
                  ],
                ),
              ],
            ),
    );
  }
// 修改头像
  // 选择图片来源
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });

      var temp = user;
      temp.avatar = _avatarPath;
      await _userHelper.updateUser(temp);
      eventBus.fire('updateAvatar');
    }
  }
  Widget _buildListItem(String title, String value) {
    return Expanded(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
