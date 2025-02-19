import 'package:flutter/material.dart';
import 'package:infinite_creation/models/item.dart';
import 'package:infinite_creation/services/api_service.dart';
import 'package:infinite_creation/widgets/item_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Item>> itemsFuture;
  // Change to 60 FPS
  // List<Item> itemsCurrent = [];
  late Future<Item> combinedItem;
  List<Item> buttonLabels = [];
  List<Offset> buttonPositions = [];

  @override
  void initState() {
    super.initState();
    itemsFuture = apiService.getListItem();
  }

  final Map<String, String> recipes = {
    'Water+Water': 'Lake',
    'Water+Fire': 'Steam',
    'Water+Wind': 'Rain',
    'Water+Earth': 'Mud',
    'Fire+Fire': 'Volcano',
    'Fire+Wind': 'Smoke',
    'Fire+Earth': 'Lava',
    'Wind+Wind': 'Tornado',
    'Wind+Earth': 'Dust',
    'Earth+Earth': 'Mountain',
  };

  List<String> discovered = [];

  // Hàm kiểm tra xem vị trí thả có nằm trong màn chơi không
  bool _isInGameArea(Offset position, BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Kiểm tra nếu vị trí nằm trong khu vực màn chơi
    return position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= size.width &&
        position.dy <= size.height;
  }

  void checkTrigger(int index, Offset position) async {
    if (buttonPositions.isNotEmpty) {
      int combinedElementIndex = -1;
      List<Offset> buttonPositionsTemp = [...buttonPositions];
      buttonPositionsTemp.removeAt(index);
      List<Item> buttonLabelsTemp = [...buttonLabels];
      buttonLabelsTemp.removeAt(index);

      for (var coordinate in buttonPositionsTemp) {
        if ((position - coordinate).distance < 100) {
          var firstElement = buttonLabels[index].label;
          var secondElement = buttonLabelsTemp[buttonPositionsTemp.indexOf(coordinate)].label;

          try {
            final elementCombination = await apiService.combineItems(firstElement, secondElement);

            // Create new button between the combined twos
            var newButtonPosition = Offset((position.dx + coordinate.dx) / 2, (position.dy + coordinate.dy) / 2);

            setState(() {
              buttonPositions.removeAt(index);
              buttonLabels.removeAt(index);

              buttonPositions.add(newButtonPosition);
              buttonLabels.add(elementCombination);

              combinedElementIndex = buttonPositions.indexOf(coordinate);
            });
          } catch (exception) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(exception.toString())),
            );
          }

          break;
        }
      }

      if (combinedElementIndex > -1) {
        buttonPositions.removeAt(combinedElementIndex);
        buttonLabels.removeAt(combinedElementIndex);

        setState(() {
          // Change to 60 FPS
          // itemsFutureCurrent = itemsFuture;
          itemsFuture = apiService.getListItem();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.maxFinite,
        color: Colors.white,
        child: FutureBuilder<List<Item>>(
            // Change to 60 FPS
            // initialData: itemsFutureCurrent,
            future: itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No Item Found'),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end, // Căn chỉnh theo chiều dọc
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Khu vực màn chơi
                          DragTarget<Offset>(
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                color: Colors.white, // Khu vực màn chơi
                                width: double.infinity,
                                height: double.infinity,
                                child: Stack(
                                  children: [
                                    // Hiển thị tất cả các button đã được thả vào màn chơi
                                    for (var position in buttonPositions)
                                      Positioned(
                                        left: position.dx,
                                        top: position.dy,
                                        child: Draggable(
                                          data: position,
                                          feedback: ItemButton(
                                              item: buttonPositions.isNotEmpty &&
                                                  buttonLabels.isNotEmpty ?
                                              buttonLabels[buttonPositions.indexOf(position)] :
                                              snapshot.data!.first
                                          ), // Nút khi đang kéo
                                          childWhenDragging: Container(), // Nút khi bị kéo
                                          child: ItemButton(
                                              item: buttonPositions.isNotEmpty &&
                                                  buttonLabels.isNotEmpty ?
                                              buttonLabels[buttonPositions.indexOf(position)] :
                                              snapshot.data!.first
                                          ), // Nút ban đầu
                                          onDragEnd: (details) {
                                            // Kiểm tra nếu button bị kéo ra ngoài màn chơi
                                            var index = buttonPositions.indexOf(position);

                                            if (!_isInGameArea(details.offset, context)) {
                                              setState(() {
                                                buttonPositions.remove(position);
                                                buttonLabels.remove(buttonLabels[index]);
                                              });
                                            } else {
                                              setState(() {
                                                buttonPositions[index] = details.offset;
                                              });

                                              checkTrigger(index, details.offset);
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                            onWillAccept: (data) {
                              // Kiểm tra nếu button được kéo gần button cố định
                              return true;
                            },
                            onAccept: (data) {
                              // Khi button được kéo thả lên button cố định
                              // checkTrigger();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: discovered.isEmpty, // Visible nếu chưa discover item mới
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Căn chỉnh theo chiều ngang
                        children: [
                          Image.asset(
                            'assets/icons/point.png',
                            width: 25,
                            height: 25,
                          ),
                          Text(
                            "Drag an item onto the board",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(10), // Khoảng cách bên trong Container
                    margin: EdgeInsets.only(
                      top: 7,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Search items...', // Text gợi ý bên trong trường nhập liệu
                            prefixIcon: Icon(Icons.search, size: 30,), // Icon tìm kiếm bên trái
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)
                            ), // Đường viền cho TextField
                            fillColor: Theme.of(context).colorScheme.surface, // Màu nền tự động theo hệ thống
                            filled: true, // Đảm bảo background được hiển thị
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children: snapshot.data!.map((item) {
                                  return Draggable<int>(
                                    data: 1,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: ItemButton(item: item),
                                    ),
                                    childWhenDragging: ItemButton(item: item),
                                    child: ItemButton(item: item),
                                    onDragEnd: (details) {
                                      if (_isInGameArea(details.offset, context)) {
                                        setState(() {
                                          buttonPositions.add(details.offset);
                                          buttonLabels.add(item);
                                        });

                                        checkTrigger(buttonPositions.indexOf(buttonPositions.last), details.offset);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}