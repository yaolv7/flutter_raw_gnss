import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_raw_gnss/flutter_raw_gnss.dart';
import 'package:flutter_raw_gnss/gnss_status_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'gnss_status_constellation_enum.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Demo"),
        ),
        body: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _hasPermissions = false;

  @override
  void initState() {
    super.initState();

    Permission.location.request().then((value) {
      setState(() => _hasPermissions = value.isGranted);
      listenToLocationUpdates((v) {
        if (kDebugMode) {
          print(v);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) =>
      _hasPermissions ? buildSatelliteInfoPanel() : const Text('没有权限');

  /// 追踪位置
  Future<StreamSubscription<Position>?>? listenToLocationUpdates(
    ValueChanged<Position> callback,
  ) async {
    LocationSettings locationSettings = AndroidSettings(
      forceLocationManager: true,
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      // intervalDuration 主动更新位置时间间隔
      intervalDuration: const Duration(
        seconds: 5,
      ),
      // timeLimit 首次定位持续时间，超时未获取到就停止定位，在指定时间内获取到了就不会停止
      timeLimit: const Duration(
        minutes: 15,
      ),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: "测试APP",
        notificationText: "正在获取位置信息",
      ),
    );

    if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    }

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        callback.call(position);
      } else {
        // LogUtil.d("获取位置更新失败");
      }

      // print(position == null
      //     ? 'Unknown'
      //     : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
    return positionStream;
  }
}

/// 卫星信息
Widget buildSatelliteInfoPanel() {
  return SafeArea(
    minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child:
        // BackdropFilter( // 高斯模式效果
        //   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //   // 调整sigmaX和sigmaY的值来改变模糊程度
        //   child:
        Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A3878).withOpacity(0.9),
        borderRadius: const BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: StreamBuilder<GnssStatusModel>(
        builder: (context, snapshot) {
          var data = snapshot.data;
          var statusList = data?.status;

          if (data == null || statusList?.isNotEmpty != true) {
            return _satelliteSearchHint('当前卫星信号较差');
          } else {
            // 筛选正在使用中的卫星
            var list = statusList
                ?.where((element) => element.usedInFix == true)
                .toList();

            if (list?.isNotEmpty == true) {
              var beiDouList = list!.where((element) =>
                  element.constellationType ==
                  Constellation.BEIDOU.constellationType);

              var dataList = list;
              // 把北斗排在前面
              dataList.sort((left, right) {
                if (left.constellationType ==
                    Constellation.BEIDOU.constellationType) {
                  return -1;
                }

                if (right.constellationType ==
                    Constellation.BEIDOU.constellationType) {
                  return 1;
                }

                return (left.constellationType ?? 10)
                    .compareTo(right.constellationType ?? 10);
              });

              // 有正在使用的卫星
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 35, bottom: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '  当前共${dataList.length}颗卫星为您定位\n其中北斗卫星${beiDouList.length}颗',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2D73F9),
                          const Color(0xFF2D73F9).withOpacity(0.5),
                          const Color(0xFF2D73F9).withOpacity(0.1),
                          const Color(0xFF2D73F9).withOpacity(0.5),
                          const Color(0xFF2D73F9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.1, 0.3, 0.5, 0.7, 0.9],
                      ),
                    ),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        _getSatelliteTitle(
                          data: '类型',
                          fontSize: 26,
                        ),
                        _getSatelliteTitle(
                          data: '方位角',
                          fontSize: 26,
                        ),
                        _getSatelliteTitle(
                          data: '高度角',
                          fontSize: 26,
                        ),
                        _getSatelliteTitle(
                          flex: 2,
                          data: '信号强度',
                          fontSize: 26,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, position) {
                        var status = dataList[position];

                        var name = Constellation.getConstellationType(
                                status.constellationType)
                            .name;

                        double progress = status.cn0DbHz ?? 5;

                        return Container(
                          color: position % 2 == 0
                              ? const Color(0xFF4E75F4).withOpacity(0.13)
                              : Colors.transparent,
                          height: 56,
                          child: Row(
                            children: [
                              _getSatelliteTitle(
                                data: name,
                                fontSize: 22,
                              ),
                              _getSatelliteTitle(
                                data:
                                    status.azimuthDegrees?.toStringAsFixed(2) ??
                                        '',
                                fontSize: 22,
                              ),
                              _getSatelliteTitle(
                                data: status.elevationDegrees
                                        ?.toStringAsFixed(2) ??
                                    '',
                                fontSize: 22,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 25,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: LinearProgressIndicator(
                                    value: progress / 50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: dataList.length,
                    ),
                  ),
                ],
              );
            }

            // var length = statusList?.length ?? 0;

            return _satelliteSearchHint('当前卫星信号较差\n正在搜索中');
          }
        },
        stream: FlutterRawGnss().gnssStatusEvents,
      ),
    ),
    // ),
  );
}

/// 搜索卫星提示
Stack _satelliteSearchHint(String msg) {
  return Stack(
    children: [
      Center(
        child: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 2,
                fontSize: 24,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 20
                  ..color = Colors.black,
              ),
            ),
            // Solid text as fill.
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 2,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      )
    ],
  );
}

Expanded _getSatelliteTitle({
  int flex = 1,
  required String data,
  double fontSize = 14,
}) {
  return Expanded(
    flex: flex,
    child: Center(
      child: Text(
        data,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    ),
  );
}
