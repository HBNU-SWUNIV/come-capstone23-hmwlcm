import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:TravelRoutePlanner/api.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';

late List<int> durationtime = [];
late List<int> durationtimetmap = [];
List<Map<String, dynamic>> finlocations = [];
final apiKey = 'secret';
String tester = "";
String sellocal_1 = "";
String sellocal_2 = "";
String selname = "";
List<String> finname = ["현위치"];
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> cities = [];
  List<String> placename = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(API.tester));
    final data = json.decode(response.body);
    setState(() {
      cities = List<String>.from(data['local_1']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Builder(
        builder: (context) {
          // 3초 대기 후 인터넷 연결을 확인하고 팝업 메시지를 표시
          Future.delayed(Duration(seconds: 3), () {
            if (cities.isEmpty) {
              showNoInternetConnectionPopup(context);
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: Text('지역 선택'),
            ),
            body: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: cities.map((city) {
                    return SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          // 선택한 도시로 화면 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TesterScreen(city: city),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 40),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            city,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.flight),
                  label: '내 여행지',
                ),
              ],
              currentIndex: 1,
              selectedItemColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}

void showNoInternetConnectionPopup(BuildContext context) {
  // 인터넷 연결이 없을 때 팝업 메시지 표시
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('인터넷 연결 없음'),
      content: Text('인터넷 연결을 확인해주세요.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // 애플리케이션 종료
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          child: Text(' 종료'),
        ),
      ],
    ),
  );
}

class TesterScreen extends StatefulWidget {
  final String city;

  TesterScreen({required this.city}) {
    tester = city;
  }

  @override
  _TesterScreenState createState() => _TesterScreenState();
}

class _TesterScreenState extends State<TesterScreen> {
  List<String> placenames = [];
  List<String> imgfile = [];
  @override
  void initState() {
    super.initState();
    sendDataToPHP();
  }

  Future<void> sendDataToPHP() async {
    final url_2 = Uri.parse(API.getname);
    final response_2 = await http.post(url_2, body: {'city': widget.city});
    final data = jsonDecode(response_2.body);
    sellocal_1 = widget.city;

    setState(() {
      for (int i = 0; i < data.length; i++) {
        placenames.add(data[i]['name']);
        imgfile.add(data[i]['img']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter 2page',
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(sellocal_1),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (finname.length > 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('경고'),
                        content: Text('확인을 누르면 초기화됩니다. 계속하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 경고창 닫기
                              finname = [finname.first]; // 첫 값만 남기고 초기화
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyApp(), // MyApp으로 화면 전환
                                ),
                              );
                            },
                            child: Text('확인'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 경고창 닫기
                            },
                            child: Text('취소'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(), // MyApp으로 화면 전환
                    ),
                  );
                }
              },
            ),
          ),
          body: ListView.builder(
            itemCount: placenames.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(
                  imgfile[index], // 이미지 URL
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  placenames[index],
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TesterScreen_2(placename: placenames[index]),
                    ),
                  );
                },
                trailing: ElevatedButton(
                  onPressed: () {
                    if (finname.contains(placenames[index])) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("에러 메시지"),
                            content: Text("해당 값은 이미 존재합니다."),
                            actions: <Widget>[
                              TextButton(
                                child: Text("확인"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TesterScreen3(namelink: placenames[index]),
                        ),
                      );
                    }
                  },
                  child: Text("선택"),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flight),
                label: '내 여행지',
              ),
            ],
            currentIndex: 1,
            selectedItemColor: Colors.blue,
            onTap: (int index) {
              if (index == 0) {
                if (finname.length > 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('경고'),
                        content: Text('확인을 누르면 초기화됩니다. 계속하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              finname = [finname.first];
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyApp(),
                                ),
                              );
                            },
                            child: Text('확인'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('취소'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
                }
              }
              if (index == 1) {
                if (finname.length > 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TesterScreen3(namelink: "MOVE"),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class TesterScreen_2 extends StatefulWidget {
  final String placename;

  TesterScreen_2({required this.placename});

  @override
  _TesterScreen_2State createState() => _TesterScreen_2State();
}

class _TesterScreen_2State extends State<TesterScreen_2> {
  String imglink = "";
  String expllink = "";
  String namelink = "";
  String local_2link = "";
  double placequalitylink = 0.0;
  double restaurantlink = 0.0;
  double historicallink = 0.0;
  double trafficlink = 0.0;
  double commodationlink = 0.0;
  double naturalviewlink = 0.0;
  bool isLoading = true;
  bool ischatbotvisible = false;
  @override
  void initState() {
    super.initState();
    sendDataToPHP();
  }

  Future<void> sendDataToPHP() async {
    final url_2 = Uri.parse(API.local_2img_gpt);
    final response_2 =
        await http.post(url_2, body: {'placename': widget.placename});
    final data = json.decode(response_2.body);
    final String img = data['img'];
    final String expl = data['expl'];
    final String name = data['name'];
    final String local_2 = data['local_2'];
    final String placequality = data['placequality'];
    final String restaurant = data['restaurant'];
    final String historical = data['historical'];
    final String traffic = data['traffic'];
    final String commodation = data['commodation'];
    final String naturalview = data['naturalview'];
    setState(() {
      expllink = expl.trim();
      imglink = img.trim();
      namelink = name.trim();
      local_2link = local_2.trim();
      placequalitylink = double.parse(placequality) / 10.0;
      restaurantlink = double.parse(restaurant) / 10.0;
      historicallink = double.parse(historical) / 10.0;
      trafficlink = double.parse(traffic) / 10.0;
      commodationlink = double.parse(commodation) / 10.0;
      naturalviewlink = double.parse(naturalview) / 10.0;

      isLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter 2page',
      home: Scaffold(
        backgroundColor: ischatbotvisible ? Colors.grey : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TesterScreen(city: sellocal_1),
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      namelink,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Image.network(
                            imglink,
                            width: 400,
                            height: 400,
                          ),
                  ),
                  Text(
                    expllink,
                    textAlign: TextAlign.left,
                  ),
                  Text("주소: " + local_2link, textAlign: TextAlign.left),
                  Center(
                    child: HexagonContainer(
                      sideLength: 200.0,
                      borderWidth: 2.0,
                      borderColor: Colors.black,
                      linePercentages: [
                        trafficlink,
                        commodationlink,
                        naturalviewlink,
                        restaurantlink,
                        placequalitylink,
                        historicallink
                      ],
                      children: [
                        HexagonContainer(
                          sideLength: 200.0 * 0.8,
                          borderWidth: 2.0,
                          borderColor: Colors.grey,
                          linePercentages: [],
                          children: [
                            HexagonContainer(
                              sideLength: 200.0 * 0.6,
                              borderWidth: 2.0,
                              borderColor: Colors.grey,
                              linePercentages: [],
                              children: [
                                HexagonContainer(
                                  sideLength: 200.0 * 0.4,
                                  borderWidth: 2.0,
                                  borderColor: Colors.grey,
                                  linePercentages: [],
                                  children: [
                                    HexagonContainer(
                                      sideLength: 200.0 * 0.2,
                                      borderWidth: 2.0,
                                      borderColor: Colors.grey,
                                      linePercentages: [],
                                      children: [],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(""),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (finname.contains(namelink)) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('알림'),
                                    content: Text('이미 선택된 항목입니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('닫기'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TesterScreen3(namelink: namelink),
                                ),
                              );
                            }
                          },
                          child: Text('여행지 선택'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height / 2,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    ischatbotvisible = true;
                  });
                  // 버튼이 눌렸을 때 수행할 동작 추가
                },
                child: Text('Chat'),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500), // 애니메이션의 지속 시간 설정
              curve: Curves.easeInOut, // 애니메이션의 곡선 설정 (선택사항)
              right: ischatbotvisible
                  ? 0
                  : -MediaQuery.of(context).size.width * 0.8, // 챗봇의 오른쪽 위치 설정
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.8, // 전체 화면 너비의 80%
              child: ChatBotWidget(namelink: namelink), // Chatbot 클래스 또는 위젯 추가
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: '내 여행지',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: Colors.blue,
          onTap: (int index) {
            if (index == 0) {
              if (finname.length > 1) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('경고'),
                      content: Text('확인을 누르면 초기화됩니다. 계속하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            finname = [finname.first];
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyApp(),
                              ),
                            );
                          },
                          child: Text('확인'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('취소'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
              }
            }
            if (index == 1) {
              if (finname.length > 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TesterScreen3(namelink: "MOVE"),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class TesterScreen3 extends StatefulWidget {
  final String namelink;

  TesterScreen3({
    required this.namelink,
  }) {
    if (namelink != "MOVE") {
      finname.add(namelink);
    }
  }

  @override
  _TesterScreen3State createState() => _TesterScreen3State();
}

class _TesterScreen3State extends State<TesterScreen3> {
  int selectedHour = 0;
  int selectedMinute = 0;
  List<double> currentlatlng = [];
  final AnotherClass anotherClass = AnotherClass();
  bool loading = false;

  void removeLocation(int index) {
    setState(() {
      finname.removeAt(index); // 선택된 위치 제거
    });
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('끝내시겠습니까?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('끝내기')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('아니요')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _onBackKey();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('선택된 여행지'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: finname.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(finname[index]),
                        trailing: finname[index] != '현위치'
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  removeLocation(index); // 삭제 버튼 눌렸을 때의 동작
                                },
                              )
                            : null,
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '출발시간을 입력해주세요:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      // 아래로 슬라이드할 때 시간 증가
                      if (details.delta.dy > 0) {
                        setState(() {
                          selectedHour = (selectedHour + 1) % 24;
                        });
                      }
                      // 위로 슬라이드할 때 시간 감소
                      else if (details.delta.dy < 0) {
                        setState(() {
                          selectedHour = (selectedHour - 1) % 24;
                        });
                      }
                    },
                    child: Text(
                      '${selectedHour.toString().padLeft(2, '0')}시',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      // 아래로 슬라이드할 때 분 증가
                      if (details.delta.dy > 0) {
                        setState(() {
                          selectedMinute = (selectedMinute + 1) % 60;
                        });
                      }
                      // 위로 슬라이드할 때 분 감소
                      else if (details.delta.dy < 0) {
                        setState(() {
                          selectedMinute = (selectedMinute - 1) % 60;
                        });
                      }
                    },
                    child: Text(
                      '${selectedMinute.toString().padLeft(2, '0')}분',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (finname.length <= 8) // 조건을 검사하여 5보다 작거나 같으면 버튼을 표시
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TesterScreen(city: tester),
                        ),
                      );
                    },
                    child: Text('여행지 추가'),
                  )
                else // 5를 초과하면 에러 메시지를 표시
                  Text(
                    '더는 여행지를 추가할 수 없습니다',
                    style: TextStyle(
                      color: Colors.red,
                    ), // 에러 메시지를 빨간색으로 표시
                  ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinScreen(
                          hour: selectedHour,
                          min: selectedMinute,
                          currentfinlatlng: currentlatlng,
                        ),
                      ),
                    );
                  },
                  child: Text('완료'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 여기에서 '로딩 중' 상태로 변경
                    setState(() {
                      loading = true;
                    });
                    anotherClass.fetchAndAddLocation(currentlatlng).then((_) {
                      // 데이터가 로드되면 '현위치 탐색 완료' 상태로 변경
                      setState(() {
                        loading = false;
                      });
                    });
                  },
                  child: Text('현위치'),
                ),
                Text(
                  loading
                      ? "로딩 중.."
                      : currentlatlng.isNotEmpty
                          ? "현위치 탐색 완료"
                          : "",
                  style: TextStyle(fontSize: 16),
                )
              ],
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: '내 여행지',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: Colors.blue,
          onTap: (int index) {
            if (index == 0) {
              if (finname.length > 1) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('경고'),
                      content: Text('확인을 누르면 초기화됩니다. 계속하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 경고창 닫기
                            finname = [finname.first]; // 첫 값만 남기고 초기화
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyApp(), // MyApp으로 화면 전환
                              ),
                            );
                          },
                          child: Text('확인'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 경고창 닫기
                          },
                          child: Text('취소'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(), // MyApp으로 화면 전환
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class AnotherClass {
  Future<void> fetchAndAddLocation(List<double> currentlatlng) async {
    Location location = Location();
    LocationData? locationData;

    try {
      locationData = await location.getLocation();
      if (currentlatlng.length >= 1) {
        currentlatlng.clear(); // 기존 값들 삭제
      }
      if (locationData != null) {
        if (currentlatlng.length == 2) {
          currentlatlng.clear(); // 기존 값들 삭제
        }

        if (locationData.latitude != null && locationData.longitude != null) {
          currentlatlng.add(locationData.longitude!);
          currentlatlng.add(locationData.latitude!);
        } else {
          // 위도 또는 경도 값이 null인 경우 기본값 추가
          currentlatlng.add(127.3845475); // 기본 경도 값
          currentlatlng.add(36.3504119); // 기본 위도 값
        }
      } else {
        // 위치를 가져올 수 없는 경우 기본값 추가
        currentlatlng.add(127.3845475); // 기본 경도 값
        currentlatlng.add(36.3504119); // 기본 위도 값
      }
    } catch (e) {
      print("위치를 가져올 수 없습니다.");
      currentlatlng.add(127.3845475); // 기본 경도 값
      currentlatlng.add(36.3504119);
    }
  }

  // 다른 코드와 메서드들...
}

class FinScreen extends StatefulWidget {
  late int hour;
  late int min;
  late List<double> currentfinlatlng;
  FinScreen(
      {required this.hour, required this.min, required this.currentfinlatlng});

  @override
  _FinScreenState createState() => _FinScreenState();
}

class _FinScreenState extends State<FinScreen> {
  List<Map<String, dynamic>> finallocations = [];

  late List<String> data = [];
  late String responser;
  int selcount = 1;
  List<int> selcountarr = [];
  List<int> selcountarr_2 = [];
  bool isLoading = true;
  int itemCount = 0;
  int daycount = 1;
  List<Map<String, dynamic>> locations = [];
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<String> routeInfoList = [];
  @override
  void initState() {
    super.initState();
    finlocations.clear();
    fetchData();
  }

  ///x_lat은 string값
  Future<void> fetchData() async {
    final url = Uri.parse(API.timedata);

    final response =
        await http.post(url, body: {'data': finname.sublist(1).join(',')});
    print(finname);

    final decodedData = json.decode(response.body);
    final extracteddata_lat = (decodedData as List<dynamic>).map((item) {
      final xLatValue = double.tryParse(item['X_lat'] as String);
      print(xLatValue);
      return xLatValue ?? 0.0;
    }).toList();
    final extracteddata_lng = (decodedData as List<dynamic>).map((item) {
      final yLngValue = double.tryParse(item['Y_lng'] as String);
      print(yLngValue);
      return yLngValue ?? 0.0;
    }).toList();
    final extracteddata = (decodedData as List<dynamic>)
        .map((item) => item['time'] as String)
        .toList();
    setState(() {
      data = extracteddata;

      locations = [
        {
          'name': '현위치',
          'latlng':
              '${widget.currentfinlatlng[1]}, ${widget.currentfinlatlng[0]}',
          'time': 0
        },
      ];

      for (int i = 0; i < finname.length; i++) {
        if (i < extracteddata_lat.length && i < extracteddata_lng.length) {
          locations.add({
            'name': finname[i + 1],
            'latlng': '${extracteddata_lng[i]}, ${extracteddata_lat[i]}',
            'time': int.tryParse(extracteddata[i])
          });
        }
      }
      print(locations);
      tspfullish();

      processFetchedData();
    });
  }

  Future<void> tspfullish() async {
    List<List<double>> distances =
        await generateDistanceMatrix(apiKey, locations);
    distances.forEach((row) {
      print(row);
    });
    durationtime.clear();
    durationtimetmap.clear();
    //////////에러시삭제
    var result = tspBruteForce(distances);
    List<int> shortestPath = result[0];
    double shortestDistance = result[1];
    print("최단 경로:");
    double totalDistance = 0;
    int totalDuration = 0;

    for (int i = 0; i < shortestPath.length - 1; i++) {
      int startIdx = shortestPath[i];
      int endIdx = shortestPath[i + 1];
      List<double> distanceAndDuration = await getDistanceAndDuration(
          apiKey, locations[startIdx]['latlng']!, locations[endIdx]['latlng']!);
      double distance = distanceAndDuration[0];
      int durationInMinutes = distanceAndDuration[1].toInt();
      durationtime.add(durationInMinutes);
      totalDistance += distance;
      totalDuration += durationInMinutes;
      String startName = locations[startIdx]['name']!;
      String endName = locations[endIdx]['name']!;
      print(
          '$startName -> $endName (${distance.toStringAsFixed(2)}km, ${formatDuration(durationInMinutes)})');

      // 새로운 맵을 생성하여 이름, 위도/경도, 시간 값을 저장
      Map<String, dynamic> locationInfo = {
        'name': startName,
        'latlng': locations[startIdx]['latlng']!,
        'time': locations[startIdx]['time']!,
      };

      finlocations.add(locationInfo);

      // 마지막 위치일 경우, 마지막 위치의 정보도 추가
      if (i == shortestPath.length - 2) {
        locationInfo = {
          'name': endName,
          'latlng': locations[endIdx]['latlng']!,
          'time': locations[endIdx]['time']!,
        };
        finlocations.add(locationInfo);
      }
    }

    print(durationtime);
    // 총   정보 출력
    print(
        '총(${totalDistance.toStringAsFixed(2)}km, ${formatDuration(totalDuration)} 소요)');
    finallocations = finlocations;
    if (finallocations.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    } else if (finallocations.isEmpty) {}
    print(finlocations);
    getRouteInfo();
    // finlocations 리스트에 저장된 정보 출력
    _addMarkers();
  }

  Future<void> getRouteInfo() async {
    String api_key = 'secret';
    for (var i = 0; i < finlocations.length - 1; i++) {
      double route = 0.0;
      int durationMinutes = 0;
      String startLatlng = finlocations[i]['latlng'];

      List<String> startLatlngList = startLatlng.split(',');
      String startX = startLatlngList[1];
      String startY = startLatlngList[0];
      String endLatlng = finlocations[i + 1]['latlng'];
      List<String> endLatlngList = endLatlng.split(',');
      String endX = endLatlngList[1];
      String endY = endLatlngList[0];
      String name = finlocations[i]['name'];
      String url =
          'https://apis.openapi.sk.com/tmap/routes?version=1&format=json&appKey=$api_key&startX=$startX&startY=$startY&endX=$endX&endY=$endY';
      try {
        final response = await http.get(Uri.parse(url));
        final data = json.decode(response.body);
        if (data.containsKey('features')) {
          route = data['features'][0]['properties']['totalDistance'].toDouble();
          int rawDuration = data['features'][0]['properties']['totalTime'];
          print(rawDuration);
          Duration duration = Duration(seconds: rawDuration);
          durationMinutes = (duration.inSeconds / 60).round();
          durationtimetmap.add(durationMinutes);
          routeInfoList.add(
              '$name -> ${finlocations[i + 1]['name']}: $route 미터, $durationMinutes 분');
        } else {
          routeInfoList.add("$name: API 응답에 'features' 항목이 없습니다.");
        }
      } catch (e) {
        routeInfoList.add("$name: 오류 발생: $e");
      }
      //print
    }
    setState(() {});
  }

  Future<List<List<double>>> generateDistanceMatrix(
      //이동시간 매트릭스 형성 ex)location1,2,3,4가잇고,location1->2 30분, 1->3 50분, 1->4 120분일시 첫행[0,30,50,120]와 같이설정, 다른행들도 동일
      String apiKey,
      List<Map<String, dynamic>> locations) async {
    int n = locations.length;
    List<List<double>> distances = List.generate(n, (_) => List.filled(n, 0.0));

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        String origin = locations[i]['latlng']!;
        String destination = locations[j]['latlng']!;
        List<double> distanceAndDuration =
            await getDistanceAndDuration(apiKey, origin, destination);
        double distance = distanceAndDuration[0];
        distances[i][j] = distance;
        distances[j][i] = distance;
      }
    }

    return distances;
  }

  String formatDuration(int minutes) {
    ///시간 형식 설정
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}시간 ${remainingMinutes}분';
  }

  Future<List<double>> getDistanceAndDuration(

      ///이동시간및 이동거리 데이터 가져올 함수
      String apiKey,
      String origin,
      String destination) async {
    String requestUrl =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=transit&origins=$origin&destinations=$destination&region=KR&key=$apiKey';
    http.Response response = await http.get(Uri.parse(requestUrl));
    Map<String, dynamic> data = json.decode(response.body);

    if (data['status'] == 'OK') {
      String distanceText = data['rows'][0]['elements'][0]['distance']['text'];
      String durationText = data['rows'][0]['elements'][0]['duration']['text'];
      double distance = double.parse(distanceText.split(' ')[0]);
      int durationInMinutes = parseDurationToMinutes(durationText);

      return [distance, durationInMinutes.toDouble()];
    } else {
      return [0.0, 0.0];
    }
  }

  int parseDurationToMinutes(String durationText) {
    ///시간대 변환
    int totalMinutes = 0;

    List<String> parts = durationText.split(' ');
    for (int i = 0; i < parts.length; i += 2) {
      if (parts[i + 1] == 'hour' || parts[i + 1] == 'hours') {
        totalMinutes += int.parse(parts[i]) * 60;
      } else if (parts[i + 1] == 'min' || parts[i + 1] == 'mins') {
        totalMinutes += int.parse(parts[i]);
      }
    }

    return totalMinutes;
  }

  List<dynamic> tspBruteForce(List<List<double>> distances2D) {
    int n = distances2D.length;
    double minDistance = double.infinity;
    List<int> minPath = [];

    for (List<int> path in permutations(n)) {
      double totalDistance = 0;
      for (int i = 0; i < n - 1; i++) {
        totalDistance += distances2D[path[i]][path[i + 1]];
      }

      if (totalDistance < minDistance) {
        //이 부분에서 최소 거리 및 경로 업데이트
        minDistance = totalDistance;
        minPath = List.from(path); //minpath=최적경로
      }
    }

    return [minPath, minDistance];
  }

  List<List<int>> permutations(int n) {
    ////가능한 도시 순열(경로) 생성,반환
    List<int> elements = List.generate(n, (index) => index);
    return _generatePermutations(elements);
  }

  List<List<int>> _generatePermutations(List<int> elements) {
    if (elements.length == 1) {
      return [elements];
    }

    List<List<int>> result = [];
    for (int i = 0; i < elements.length; i++) {
      int current = elements[i];
      List<int> remaining = List.from(elements)..removeAt(i);
      List<List<int>> permutationsOfRemaining =
          _generatePermutations(remaining);
      for (List<int> subPermutation in permutationsOfRemaining) {
        result.add([current, ...subPermutation]);
      }
    }
    return result;
  }

  void processFetchedData() {
    int cumulativeHours = widget.hour;
    int cumulativeMinutes = widget.min;
    late int ssi, mmi;

    bool reset = false;

    for (int i = 1; i < finname.length; i++) {
      int minutes = int.parse(data[i - 1]);
      ssi = minutes ~/ 60;
      mmi = minutes % 60;
      selcount++;
      if (reset) {
        daycount++;
        cumulativeHours = 9;
        cumulativeMinutes = 0;
        reset = false;
      }

      cumulativeHours += ssi;
      cumulativeMinutes += mmi;

      if (cumulativeMinutes >= 60) {
        cumulativeHours += 1;
        cumulativeMinutes -= 60;
      }

      if (cumulativeHours >= 19) {
        reset = true;
        selcountarr.add(selcount);
        selcount = 0;
      }
      if (i == (finname.length - 1) && reset == false) {
        selcountarr.add(selcount);
      }
      selcountarr.forEach((value) {
        print(value);
      });
    }
    int sum = 0;
    for (int i = 0; i < selcountarr.length; i++) {
      sum += selcountarr[i];
      selcountarr_2.add(sum);
    }
  }

  void _addMarkers() {
    //////////////////지도코드

    for (int i = 0; i < finlocations.length; i++) {
      final location = finlocations[i];
      final String latlngString = location['latlng'];
      final List<String> latlngSplit = latlngString.split(',');
      final double lat = double.parse(latlngSplit[0]);
      final double lng = double.parse(latlngSplit[1]);
      final LatLng position = LatLng(lat, lng);
      final String name = location['name'];
      final int time = location['time'];
      // Add marker
      _createCustomMarker(name, position, i + 1).then((marker) {
        setState(() {
          _markers.add(marker);
        });
      });
      // 경로 그리기
      if (i < finlocations.length - 1) {
        final nextLocation = finlocations[i + 1];
        final String nextLatlngString = nextLocation['latlng'];
        final List<String> nextLatlngSplit = nextLatlngString.split(',');
        final double nextLat = double.parse(nextLatlngSplit[0]);
        final double nextLng = double.parse(nextLatlngSplit[1]);
        final LatLng nextPosition = LatLng(nextLat, nextLng);
        _fetchAndDrawRoute(position, nextPosition);
      }
    }
  }

  Future<Marker> _createCustomMarker(
      String markerId, LatLng position, int number) async {
    final Uint8List markerIcon = await _createMarkerImage(number);

    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.fromBytes(markerIcon),
      infoWindow: InfoWindow(
        title: 'Location $number',
      ),
    );
  }

  Future<Uint8List> _createMarkerImage(int number) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(40.0, 40.0)));

    final Paint paint = Paint()..color = Colors.blue;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 25.0,
    );

    canvas.drawCircle(Offset(25.0, 25.0), 25.0, paint);

    textPainter.text = TextSpan(
      text: number.toString(),
      style: textStyle,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(20.0 - textPainter.width / 2, 20.0 - textPainter.height / 2),
    );

    final img = recorder.endRecording();
    final imgData = await img.toImage(60, 60);
    final ByteData? byteData =
        await imgData.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return Uint8List.sublistView(byteData.buffer.asUint8List());
    }
    return Uint8List(0);
  }

  void _fetchAndDrawRoutes() {
    for (int i = 0; i < _markers.length - 1; i++) {
      final LatLng start = _markers.elementAt(i).position;
      final LatLng end = _markers.elementAt(i + 1).position;
      _fetchAndDrawRoute(start, end);
    }
  }

  void _fetchAndDrawRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=transit&key=AIzaSyB-t4YgZGAY2YbqojAhr7ptWyAFt6DkNaw'));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final List<LatLng> routePoints = _decodePolyline(
          decodedResponse['routes'][0]['overview_polyline']['points']);

      _polylines.add(
        Polyline(
          polylineId: PolylineId('route${_polylines.length + 1}'),
          color: Colors.blue,
          width: 4,
          points: routePoints,
        ),
      );
      setState(() {});
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    } else {
      int dayCount = 1;
      int cumulativeHours = widget.hour;
      int cumulativeMinutes = widget.min;

      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('최적 경로'),
          ),
          body: Column(
            children: [
              SizedBox(height: 30),
              Expanded(
                flex: 1,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.5257, 126.9219),
                    zoom: 8.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: finallocations.length,
                  itemBuilder: (context, index) {
                    final location = finallocations[index];
                    final travelTime = index < durationtimetmap.length
                        ? durationtimetmap[index]
                        : null;

                    int hours = location['time'] ~/ 60;
                    int minutes = location['time'] % 60;
                    cumulativeHours += hours;
                    cumulativeMinutes += minutes;
                    final int travelHours =
                        (travelTime != null) ? (travelTime ~/ 60) : 0;
                    final int travelMinutes =
                        (travelTime != null) ? (travelTime % 60) : 0;
                    cumulativeHours += travelHours;
                    cumulativeMinutes += travelMinutes;
                    if (cumulativeMinutes >= 60) {
                      cumulativeHours++;
                      cumulativeMinutes -= 60;
                    }

                    if (cumulativeHours > 19) {
                      dayCount++;
                      cumulativeHours = 9;
                    }

                    List<Widget> dayWidgets = [];
                    if (index == 0 || cumulativeHours == 9) {
                      dayWidgets.add(
                        Row(
                          children: [
                            Text(
                              '${dayCount}일차',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (dayWidgets.isNotEmpty) ...dayWidgets,
                        ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                location['name'] +
                                    (location['time'] > 0
                                        ? "(${hours}시간 ${minutes}분 소요)"
                                        : ""),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: travelTime != null
                              ? Icon(Icons.arrow_downward)
                              : null,
                          title: travelTime != null
                              ? Text(
                                  travelHours > 0
                                      ? '${travelHours}시간 ${travelMinutes}분 이동'
                                      : '${travelMinutes}분 이동',
                                )
                              : null,
                        ),
                        if (index < finallocations.length - 1)
                          Divider(
                            thickness: 2.0,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flight),
                label: '내 여행지',
              ),
            ],
            currentIndex: 1,
            selectedItemColor: Colors.blue,
            onTap: (int index) {
              if (index == 0) {
                if (finname.length > 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('경고'),
                        content: Text('확인을 누르면 초기화됩니다. 계속하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 경고창 닫기
                              finname = [finname.first]; // 첫 값만 남기고 초기화
                              durationtime.clear();
                              durationtimetmap.clear();
                              finlocations.clear();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyApp(), // MyApp으로 화면 전환
                                ),
                              );
                            },
                            child: Text('확인'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 경고창 닫기
                            },
                            child: Text('취소'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(), // MyApp으로 화면 전환
                    ),
                  );
                }
              }
            },
          ),
        ),
      );
    }
  }
}

//여기서부터 육각형코드
class HexagonContainer extends StatelessWidget {
  final double sideLength;
  final double borderWidth;
  final Color borderColor;
  final List<double> linePercentages;
  final List<Widget> children;

  HexagonContainer({
    required this.sideLength,
    required this.borderWidth,
    required this.borderColor,
    required this.linePercentages,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sideLength + 180, // 좌우로 30씩 더 넓힌 크기
      height: sideLength + 130, // 상하로 30씩 더 넓힌 크기
      child: Stack(
        children: [
          CustomPaint(
            size: Size(sideLength + 400, sideLength + 130),
            painter: HexagonPainter(
              sideLength: sideLength,
              borderWidth: borderWidth,
              borderColor: borderColor,
              linePercentages: linePercentages,
            ),
          ),
          ..._buildTextWidgets(),
          ...children.map((child) {
            final childSize =
                child is HexagonContainer ? child.sideLength : sideLength;
            final childOffset = Offset(
                (sideLength - childSize) / 2, (sideLength - childSize) / 2);
            return Positioned(
              left: childOffset.dx,
              top: childOffset.dy,
              child: child,
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Widget> _buildTextWidgets() {
    List<String> eststandard = [
      '교통&이동성',
      '숙박시설',
      '자연환경&경치',
      '음식&식당',
      '관광지 품질',
      '문화&역사적 가치'
    ];
    final double centerX = sideLength / 2;
    final double centerY = sideLength / 2;
    final double radius = sideLength / 2;
    final double textRadius = radius + 25; // 텍스트가 표시될 반지름의 길이

    return linePercentages.asMap().entries.map((entry) {
      final int index = entry.key;
      final double percentage = entry.value;
      final double angle = math.pi / 3 * index;

      double textX = centerX + math.cos(angle) * textRadius;
      double textY = centerY + math.sin(angle) * textRadius + 40;

      // 가운데 2개 꼭지점은 왼쪽과 오른쪽으로 이동
      if (index == 3 || index == 0) {
        final double distance = 20.0; // 이동할 거리
        textX += (index == 3) ? distance - 40 : distance - 15;
        textX += 60.0;
        textY += 10.0;
      }

      // 아래 2개 꼭지점은 아래로 이동
      if (index == 1 || index == 2) {
        final double distance = 10.0; // 이동할 거리
        textY += distance;
        textX += 40.0;
      }
      if (index == 1) {
        textX += 8.0;
      }
      if (index == 3) {
        textX -= 5.0;
      }
      if (index == 4 || index == 5) {
        textY += 17;
        textX += 40;
      }
      if (percentage > 0) {
        return Positioned(
          left: textX,
          top: textY,
          child: Text(
            eststandard[index],
            style: TextStyle(fontSize: 16),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    }).toList();
  }
}

class HexagonPainter extends CustomPainter {
  final double sideLength;
  final double borderWidth;
  final Color borderColor;
  final List<double> linePercentages;

  HexagonPainter({
    required this.sideLength,
    required this.borderWidth,
    required this.borderColor,
    required this.linePercentages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = sideLength / 2;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final Paint linePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final Paint fillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final Path path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = math.pi / 3 * i;
      final double x = centerX + math.cos(angle) * radius;
      final double y = centerY + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      if (linePercentages.length > i && linePercentages[i] > 0) {
        final double lineLength = radius * linePercentages[i];
        final double lineX = centerX + math.cos(angle) * lineLength;
        final double lineY = centerY + math.sin(angle) * lineLength;
        canvas.drawLine(
            Offset(centerX, centerY), Offset(lineX, lineY), linePaint);
        final double nextAngle = math.pi / 3 * ((i + 1) % 6);
        final double nextLineLength = radius * linePercentages[(i + 1) % 6];
        final double nextLineX = centerX + math.cos(nextAngle) * nextLineLength;
        final double nextLineY = centerY + math.sin(nextAngle) * nextLineLength;
        canvas.drawLine(
            Offset(lineX, lineY), Offset(nextLineX, nextLineY), linePaint);
        final Path fillPath = Path();
        fillPath.moveTo(centerX, centerY);
        fillPath.lineTo(lineX, lineY);
        fillPath.lineTo(nextLineX, nextLineY);
        fillPath.close();
        canvas.drawPath(fillPath, fillPaint);
      }
    }
    path.close();
    canvas.drawPath(path, borderPaint);
    if (borderColor == Colors.black) {
      final TextSpan span = TextSpan(
        text: '※해당 지표는tripadvisor사이트의 리뷰(30개)를 CHATGPT API를 이용하여 매긴 점수',
        style: TextStyle(fontSize: 8.7, color: Colors.black),
      );
      final TextPainter textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final double textX = borderWidth + 5;
      final double textY = size.height - 300;
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(HexagonPainter oldPainter) =>
      borderWidth != oldPainter.borderWidth ||
      borderColor != oldPainter.borderColor ||
      linePercentages != oldPainter.linePercentages;

  @override
  bool shouldRebuildSemantics(HexagonPainter oldPainter) => false;
}

class ChatBotWidget extends StatefulWidget {
  final String namelink;
  ChatBotWidget({required this.namelink});

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _goback() {
    _animationController.reverse().then((_) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Stack(
            children: [
              TesterScreen_2(placename: widget.namelink),
              SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.2, 0.0),
                  end: Offset(1.0, 0.0),
                ).animate(animation1),
                child: ChatBotWidget(namelink: widget.namelink),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  TextEditingController _textEditingController = TextEditingController();
  List<String> _chatMessages = [];

  Future<String> sendMessage(String message) async {
    var url = Uri.parse('https://api.openai.com/v1/chat/completions');
    var apiKey = 'secret';
    var headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json'
    };
    var body = utf8.encode(jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': '너는' +
              widget.namelink +
              '여행지를 찾은 여행객들을 위한 여행 가이드야. 친절하게 가이드 부탁해!대답은 ~~요체로 부탁할게.'
        },
        {'role': 'user', 'content': message}
      ]
    }));

    var response = await http.post(url, headers: headers, body: body);
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    var reply = data['choices'][0]['message']['content'];
    return reply;
  }

  void _sendMessage() async {
    var userMessage = _textEditingController.text;
    setState(() {
      _chatMessages.add('사용자: $userMessage');
    });

    var response = await sendMessage(userMessage);
    setState(() {
      _chatMessages.add('AI: $response');
    });

    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.namelink.isNotEmpty && _chatMessages.isEmpty) {
      _chatMessages
          .add('AI: 저는 ${widget.namelink}의 여행가이드 ChatGPT입니다! 질문이 있으신가요?');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_chatMessages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
                ElevatedButton(
                  onPressed: _goback,
                  child: Text('뒤로가기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
