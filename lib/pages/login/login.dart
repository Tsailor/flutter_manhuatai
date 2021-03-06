import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

import 'package:flutter_manhuatai/components/request_loading/request_loading.dart';
import 'package:flutter_manhuatai/routes/application.dart';
import 'package:flutter_manhuatai/utils/sp.dart';
import 'package:flutter_manhuatai/api/api.dart';
import 'package:flutter_manhuatai/common/const/app_const.dart';
import 'package:flutter_manhuatai/provider_store/user_info_model.dart';

import './components/input_phone.dart';
import './components/input_validate_code.dart';
import './components/img_code_dialog.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _phone = ''; // 手机号码
  var _validateCode = ''; // 短信验证码
  int _countSeconds = 60; // 倒计时
  bool _hasSendSms = false; // 是否已经发送了短信
  bool _isRequestValidateCode = false; // 是否正在请求验证码
  Uint8List imgCodeBytes; // 图形验证码
  String content = ''; // 图形验证码的文字
  Timer timer; // 短信验证码倒计时的定时器

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  void initState() {
    super.initState();
    _phoneController.value = TextEditingValue(text: _phone);
    _codeController.value = TextEditingValue(text: _validateCode);
  }

  void _showToast() {
    showToast(
      '无效的手机号码',
    );
  }

  // 登录操作
  void onPressLogin() async {
    // 无效的手机号码
    if (!AppConst.phoneReg.hasMatch(_phone)) {
      return _showToast();
    }
    // 验证手机验证码
    if (_validateCode.isEmpty) {
      showToast('验证码不能为空');
      return;
    }

    try {
      // // 显示请求的loading
      showLoading(context, message: '请稍候...');
      // 发送数据 获取用户登录所需的token
      var response = await Api.mobileBind(
        mobile: _phone,
        vcode: _validateCode,
      );
      print('获取token成功 $response');

      // 拿到返回的token即可进行登录获取用户信息
      if (response['status'] == 0) {
        String token = response['data']['appToken'];
        var userInfoMap = await Api.getUserInfo(token: token);
        print('获取用户信息成功， $userInfoMap');
        // 将登陆的用户信息存入缓存并放入 provider_store 中
        var userInfo = await SpUtils.saveUserInfo(userInfoMap);
        var userInfoModel = Provider.of<UserInfoModel>(context, listen: false);
        userInfoModel.setUserInfo(userInfo);

        print('存储用户成功 $userInfo');
        hideLoading(context);
        Application.router.pop(context);
      } else {
        showToast(
          response['msg'],
        );
        print(response);
        hideLoading(context);
      }
    } catch (e) {
      hideLoading(context);
    }
  }

  // 获取短信验证码
  _getValidateCode(BuildContext context) async {
    // 验证手机号码是否符合手机格式
    if (!AppConst.phoneReg.hasMatch(_phone)) {
      return _showToast();
    }

    // 正在发送请求，则直接返回
    if (_hasSendSms || _isRequestValidateCode) {
      return;
    }

    setState(() {
      _isRequestValidateCode = true;
    });

    try {
      // // 显示请求的loading
      showLoading(context, message: '正在发送。。。');
      var response = await Api.sendSms(
        mobile: _phone,
        refresh: '0',
      );

      print(response);
      hideLoading(context);

      setState(() {
        _isRequestValidateCode = false;
      });

      // 短信验证码获取成功，
      if (response['status'] == 0) {
        print(response);
        if (response['data'] is Map &&
            (response['data']['Image'] as String).isNotEmpty) {
          showToast(
            response['msg'],
            position: ToastPosition.bottom,
          );
        } else {
          return _countDownSms();
        }
      } else {
        if (response['data'] is Map &&
            (response['data']['Content'] as String).isNotEmpty) {
          setState(() {
            imgCodeBytes = base64.decode('${response['data']['Image']}');
            content = response['data']['Content'];
          });
          _showImgValidateDialog(context);
        }

        showToast(
          response['msg'],
          position: ToastPosition.bottom,
        );
      }
    } catch (e) {
      setState(() {
        _isRequestValidateCode = false;
      });
      hideLoading(context);
    }
  }

  // 显示图形验证码Dialog
  _showImgValidateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImgCodeDialog(
          imgCodeBytes: imgCodeBytes,
          content: content,
          phone: _phone,
          success: _validateSuccess,
        );
      },
    );
  }

  // 验证图形码成功
  _validateSuccess() {
    setState(() {
      _hasSendSms = true;
      imgCodeBytes = null;
      content = '';
    });
    _countDownSms();
  }

  // 短信倒计时
  void _countDownSms() {
    int i = 60;
    setState(() {
      _hasSendSms = true;
    });
    showToast('短信发送成功');

    timer = Timer.periodic(Duration(seconds: 1), (Timer _) {
      i--;
      setState(() {
        _countSeconds = i;
      });
      print(i);

      if (i == 0) {
        _.cancel();
        setState(() {
          _countSeconds = 60;
          _hasSendSms = false;
          _isRequestValidateCode = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _showImgValidateDialog(context);
                    },
                    child: Container(
                      width: 90.0,
                      height: 90.0,
                      margin: EdgeInsets.symmetric(vertical: 35.0),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(
                          'lib/images/ic_default_avatar.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 手机号
              InputPhone(
                phone: _phone,
                controller: _phoneController,
                onChange: (String val) {
                  setState(() {
                    _phone = val;
                  });
                },
              ),
              // 验证码
              InputValidateCode(
                validateCode: _validateCode,
                controller: _codeController,
                onChange: (String val) {
                  setState(() {
                    _validateCode = val;
                  });
                },
                getValidateCode: _getValidateCode,
                hasGetValidateCode: _hasSendSms,
                countSeconds: _countSeconds,
              ),
              // 登录按钮
              Container(
                margin: EdgeInsets.only(
                  top: 50.0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                width: MediaQuery.of(context).size.width,
                height: 45.0,
                // child: Text,
                child: FlatButton(
                  color: Colors.blue,
                  shape: StadiumBorder(),
                  child: Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    onPressLogin();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
