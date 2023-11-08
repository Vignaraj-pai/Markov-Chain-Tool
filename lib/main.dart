import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:markov_chain/Node_widget.dart';
import 'package:markov_chain/markov.dart';
import 'package:markov_chain/node_class.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int totalNodes = 50;
  List<NodeClass> graph = []; //stores all nodes
  List<Point> coordinates = []; //stores coordinates of all nodes
  Map<int, List<NodeClass>> adjList = {}; //stores adjacency list
  int currentNode = 0; //node to be added next
  NodeClass? lastDoubleTapNode; //stores the last node double tapped
  TextEditingController? descController;
  final formKey = GlobalKey<FormState>();
  bool descChanged = false;
  List<List<double>>? transitionMatrix;
  bool nodePresent = false;
  Offset? _tapPosition;
  NodeClass? startNode;
  TextEditingController startNodeController = TextEditingController();
  TextEditingController iterationController = TextEditingController();
  bool editMode = false;
  bool showDesc = false;
  NodeClass? longPressedNode;
  bool showStartText = false;
  bool animating = false;
  bool done = false;

  @override
  void initState() {
    descController = TextEditingController();
    transitionMatrix =
        List.generate(50, (index) => List.generate(50, (index) => 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: max(width, height) > 1000 && min(width, height) > 500
          ? Scaffold(
              floatingActionButton: !done
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        nodePresent
                            ? !showStartText
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                40)),
                                    child: FloatingActionButton.extended(
                                      backgroundColor: Colors.green,
                                      onPressed: () {
                                        setState(() {
                                          showStartText = true;
                                        });
                                      },
                                      label: const Text("Start"),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                40)),
                                    child: SizedBox(
                                      height: 170,
                                      width: 180,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            controller: startNodeController,
                                            decoration: InputDecoration(
                                              hintText: "Start Node",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(
                                                    15.0), // Adjust the radius as needed
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextField(
                                            controller: iterationController,
                                            decoration: InputDecoration(
                                              hintText: "Number of Iterations",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(
                                                    15.0), // Adjust the radius as needed
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          FloatingActionButton.extended(
                                            backgroundColor: Colors.green,
                                            onPressed: () {
                                              for (var i = 0;
                                                  i < graph.length;
                                                  i++) {
                                                if (graph[i].value ==
                                                    int.parse(
                                                        startNodeController
                                                            .text)) {
                                                  startNode = graph[i];
                                                }
                                              }
                                              setState(() {});

                                              List<double> initialState =
                                                  List.generate(graph.length,
                                                      (index) => 0);
                                              initialState[startNode!.value!] =
                                                  1;

                                              AbsorbingMarkov markovChain =
                                                  AbsorbingMarkov(graph.length);
                                              List<double>
                                                  oneDTransitionMatrix = [];

                                              int newSize = graph.length;

                                              List<List<double>> trimmedArray =
                                                  List.generate(newSize, (i) {
                                                return List.generate(newSize,
                                                    (j) {
                                                  return transitionMatrix![i]
                                                      [j];
                                                });
                                              });

                                              // //add self loop
                                              // for (var i = 0;
                                              //     i < graph.length;
                                              //     i++) {
                                              //   double count = 0;
                                              //   for (var j = 0;
                                              //       j < graph.length;
                                              //       j++) {
                                              //     if (i != j) {
                                              //       count +=
                                              //           transitionMatrix![i][j];
                                              //     }
                                              //   }
                                              //   transitionMatrix![i][i] =
                                              //       1 - count;
                                              // }
                                              // print(transitionMatrix);
                                              for (List<double> row
                                                  in trimmedArray) {
                                                oneDTransitionMatrix
                                                    .addAll(row);
                                              }
                                              int index = 0;
                                              double sum = 0;
                                              for (int i = 0;
                                                  i < pow(graph.length, 2);
                                                  i++) {
                                                sum += oneDTransitionMatrix[i];
                                                if ((i + 1) % graph.length ==
                                                    0) {
                                                  oneDTransitionMatrix[index] =
                                                      1 - sum;
                                                  sum = 0;
                                                  index = index +
                                                      graph.length.toInt() +
                                                      1;
                                                }
                                              }
                                              markovChain.setTransitionMatrix(
                                                  oneDTransitionMatrix);
                                              markovChain.displayAll();

                                              print(trimmedArray);
                                              print(oneDTransitionMatrix);

                                              List<double> finalState =
                                                  markovChain.calculateState(
                                                      initialState,
                                                      int.parse(
                                                          iterationController
                                                              .text
                                                              .toString()));
                                              print(
                                                  "\n\nInitial: ${initialState}");
                                              print(
                                                  "\n\n\nFinal: ${finalState}");
                                              print(trimmedArray);
                                              // double s = 0;
                                              // for (var i = 0;
                                              //     i < finalState.length;
                                              //     i++) {
                                              //   s += finalState[i];
                                              // }
                                              // for (var i = 0;
                                              //     i < finalState.length;
                                              //     i++) {
                                              //   finalState[i] =
                                              //       finalState[i] / s;
                                              // }
                                              // for (var i = 0;
                                              //     i < finalState.length;
                                              //     i++) {
                                              //   finalState[i] = double.parse(
                                              //       (finalState[i])
                                              //           .toStringAsFixed(4));
                                              // }
                                              setState(() {
                                                for (var i = 0;
                                                    i < graph.length;
                                                    i++) {
                                                  for (var j = 0;
                                                      j < graph.length;
                                                      j++) {
                                                    if (i == graph[j].value) {
                                                      // final r = Random();
                                                      // if (finalState[i] > 1) {
                                                      //   finalState[i] =
                                                      //       r.nextDouble();
                                                      // }
                                                      // finalState[i] = double
                                                      //     .parse((finalState[i])
                                                      //         .toStringAsFixed(
                                                      //             4));
                                                      graph[j].finalState =
                                                          finalState[i];
                                                      break;
                                                    }
                                                  }
                                                }
                                                done = true;
                                              });
                                            },
                                            label: const Text("Start"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                            : Container(),
                        showDesc && nodePresent
                            ? Padding(
                                padding: EdgeInsets.only(
                                    left: (MediaQuery.of(context).size.width /
                                        30)),
                                child: SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: descController,
                                    decoration: InputDecoration(
                                      hintText: 'Add a Description',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        showDesc && nodePresent
                            ? Padding(
                                padding: EdgeInsets.only(
                                    left: (MediaQuery.of(context).size.width /
                                        60)),
                                child: FloatingActionButton.extended(
                                  backgroundColor: Colors.green,
                                  onPressed: () {
                                    int index = graph.indexOf(longPressedNode ??
                                        NodeClass(value: -1));
                                    graph[index].description =
                                        descController?.text ?? "";
                                    descController?.clear();

                                    setState(() {
                                      showDesc = false;
                                    });
                                  },
                                  label: const Text("Update"),
                                ),
                              )
                            : Container(),
                        const Spacer(),
                        nodePresent
                            ? Padding(
                                padding: const EdgeInsets.only(right: 25.0),
                                child: FloatingActionButton.extended(
                                  backgroundColor: Colors.redAccent[200],
                                  onPressed: () {
                                    nodePresent = false;
                                    lastDoubleTapNode = null;
                                    currentNode = 0;
                                    setState(() {
                                      graph = [];
                                      adjList = {};
                                      coordinates = [];
                                      startNode = null;
                                      // _currentAnimatedWidget = _animatedWidget_1;
                                      showDesc = false;
                                    });
                                  },
                                  label: const Text("Reset"),
                                ),
                              )
                            : Container(),
                        nodePresent
                            ? Padding(
                                padding: const EdgeInsets.only(right: 30.0),
                                child: FloatingActionButton.extended(
                                  onPressed: () {
                                    lastDoubleTapNode = null;
                                    var deleteNode = graph.last;
                                    setState(() {
                                      if (deleteNode.value ==
                                          startNode?.value) {
                                        startNode = null;
                                      }
                                      graph.removeLast();
                                      coordinates.removeLast();
                                      adjList.remove(deleteNode.value);
                                      for (var element in adjList.values) {
                                        element.remove(deleteNode);
                                      }
                                      if (graph.isEmpty) {
                                        nodePresent = false;
                                      }
                                      currentNode--;
                                      showDesc = false;
                                    });
                                  },
                                  label: const Text("Undo"),
                                ),
                              )
                            : Container(),
                      ],
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          graph = [];
                          coordinates = [];
                          adjList = {};
                          currentNode = 0;
                          lastDoubleTapNode = null;
                          descController?.text = "";
                          descChanged = false;
                          transitionMatrix = [];
                          nodePresent = false;
                          _tapPosition = null;
                          startNode = null;
                          startNodeController.text = "";
                          iterationController.text = "";
                          editMode = false;
                          showDesc = false;
                          longPressedNode = null;
                          showStartText = false;
                          done = false;
                          setState(() {});
                        },
                        label: const Text("Clear"),
                      ),
                    ),
              body: Stack(
                children: [
                  InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      onTapDown: (details) {
                        setState(() {
                          showDesc = false;
                        });
                        _tapPosition = Offset(details.globalPosition.dx - 20,
                            details.globalPosition.dy - 20);
                      },
                      onTap: () {
                        descController?.clear();
                        lastDoubleTapNode = null;
                        coordinates.add(Point(
                            _tapPosition?.dx ?? 0, _tapPosition?.dy ?? 0));
                        setState(() {
                          graph.add(NodeClass(value: currentNode));
                          currentNode++;
                          nodePresent = true;
                        });
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      )),
                  nodePresent
                      ? Builder(builder: (context) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: CustomPaint(
                                painter: LinePainter(
                                    graph: graph,
                                    adjList: adjList,
                                    coordinates: coordinates,
                                    transitionMatrix: transitionMatrix!),
                                child: Stack(children: [
                                  ...graph
                                      .map((e) => Positioned(
                                            top: coordinates[e.value!]
                                                .y
                                                .toDouble(),
                                            left: coordinates[e.value!]
                                                .x
                                                .toDouble(),
                                            child: GestureDetector(
                                                onLongPress: () {
                                                  longPressedNode = e;
                                                  setState(() {
                                                    showDesc = true;
                                                    descController?.text =
                                                        e.description ?? "";
                                                  });
                                                },
                                                onTap: () {
                                                  if (lastDoubleTapNode ==
                                                      null) {
                                                    setState(() {
                                                      lastDoubleTapNode = e;
                                                    });
                                                  } else {
                                                    if (e.value !=
                                                        lastDoubleTapNode!
                                                            .value) {
                                                      setState(() {
                                                        if (adjList.containsKey(
                                                            lastDoubleTapNode!
                                                                .value)) {
                                                          adjList[lastDoubleTapNode!
                                                                  .value]!
                                                              .add(e);
                                                        } else {
                                                          adjList[
                                                              lastDoubleTapNode!
                                                                  .value!] = [
                                                            e
                                                          ];
                                                        }
                                                        lastDoubleTapNode =
                                                            null;
                                                      });
                                                    }
                                                  }
                                                },
                                                onDoubleTap: () {
                                                  setState(() {
                                                    lastDoubleTapNode = null;
                                                  });
                                                  List<Widget> pairs = [];
                                                  List<TextEditingController>
                                                      controllers =
                                                      List.generate(
                                                          adjList[e.value]
                                                                  ?.length ??
                                                              0,
                                                          (index) =>
                                                              TextEditingController());
                                                  int i = 0;
                                                  // final temp =
                                                  //     adjList[e.value];

                                                  // temp?.sort((e1, e2) {
                                                  //   return (e1.value)!
                                                  //       .compareTo(
                                                  //           e2.value!);
                                                  // });
                                                  // print(adjList[e.value]);
                                                  final temp = [];

                                                  adjList[e.value]
                                                      ?.forEach((element) {
                                                    temp.add(element);
                                                  });

                                                  // temp.sort((a, b) {
                                                  //   return ((a as NodeClass)
                                                  //           .value)!
                                                  //       .compareTo(
                                                  //           ((b as NodeClass)
                                                  //                   .value)!
                                                  //               .toInt());
                                                  // });

                                                  for (var element in temp) {
                                                    pairs.add(generatePair(
                                                        element.value ?? 0,
                                                        controllers[i]));
                                                    i++;
                                                  }
                                                  showGeneralDialog(
                                                      barrierColor:
                                                          Colors.transparent,
                                                      barrierDismissible: true,
                                                      barrierLabel: "Nodes",
                                                      context: context,
                                                      pageBuilder: (context,
                                                          anim1, anim2) {
                                                        return Dialog(
                                                          // insetPadding:
                                                          // EdgeInsets.zero,
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20.0))),
                                                          child: SizedBox(
                                                              width: 30,
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          20),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "For Node ${e.value}:",
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize: 16),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            16,
                                                                      ),
                                                                      Center(
                                                                        child: Wrap(
                                                                            runSpacing: 10,
                                                                            spacing: 20,
                                                                            // mainAxisAlignment:
                                                                            //     MainAxisAlignment
                                                                            //         .center,
                                                                            // crossAxisAlignment:
                                                                            //     CrossAxisAlignment
                                                                            //         .center,
                                                                            children: [
                                                                              ...pairs,
                                                                              // Row(
                                                                              //   mainAxisSize: MainAxisSize.min,
                                                                              //   mainAxisAlignment:
                                                                              //       MainAxisAlignment.end,
                                                                              //   children: [
                                                                              //     TextButton(
                                                                              //       onPressed: () {},
                                                                              //       child: Text("Cancel"),
                                                                              //     ),
                                                                              //     TextButton(
                                                                              //         onPressed: () {},
                                                                              //         child: Text("Done"))
                                                                              //   ],
                                                                              // )
                                                                            ]),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                        );
                                                      }).whenComplete(() {
                                                    for (var i = 0;
                                                        i < controllers.length;
                                                        i++) {
                                                      transitionMatrix?[
                                                              e.value!][
                                                          adjList[e.value]![i]
                                                              .value!] = double
                                                          .parse(controllers[i]
                                                              .text
                                                              .toString());
                                                    }
                                                    // print(transitionMatrix);
                                                  });
                                                },
                                                child: GraphNode(
                                                    isAbsorbing: done &&
                                                        checkIfAbsorbing(
                                                            e.value ?? -1),
                                                    done: done,
                                                    isStart: e.value ==
                                                        startNode?.value,
                                                    graph: e,
                                                    isSelected: e.value ==
                                                            lastDoubleTapNode
                                                                ?.value
                                                        ? true
                                                        : false)),
                                          ))
                                      .toList()
                                ]),
                              ));
                        })
                      : const Center(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline_sharp,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 20),
                            Text("Tap on the screen to add a node",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey)),
                          ],
                        ))
                ],
              ))
          : Container(
              color: Colors.black,
              child: const Center(
                child: Text("Please use a larger device"),
              ),
            ),
    );
  }

  bool checkIfAbsorbing(int i) {
    if (adjList[i] == null || adjList[i]!.isEmpty) return true;
    return false;
  }
}

double calculateArrowLength(Offset start, Offset end) {
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  return sqrt(dx * dx + dy * dy);
}

class LinePainter extends CustomPainter {
  final Map<int, List<NodeClass>> adjList;
  final List<Point> coordinates;
  final List<Path> _paths = [];
  final List<List<double>> transitionMatrix;
  final List<NodeClass> graph;
  LinePainter(
      {required this.adjList,
      required this.coordinates,
      required this.transitionMatrix,
      required this.graph});

  NodeClass? getNode(int e_1) {
    for (var i = 0; i < graph.length; i++) {
      if (graph[i].value == e_1) {
        return graph[i];
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    adjList.forEach((e_1, e_2) {
      for (var element in e_2) {
        Path path = Path();
        _paths.add(path);

        // int count = 0;
        // print(e_1);//0
        // print(element.value);//1
        // if (adjList[e_1]?.contains(element) ?? false) {
        //   count++;
        // } else if (adjList[element.value]?.contains(getNode(e_1)) ?? false) {
        //   count++;
        //   // print("Sdfsdfsfd");
        // }

        // print("AS $count");

        final start = Offset(coordinates[e_1].x.toDouble() + 20,
            coordinates[e_1].y.toDouble() + 20);
        final end = Offset(coordinates[element.value!].x.toDouble() + 10,
            coordinates[element.value!].y.toDouble() + 20);
        // // if (count == 2) {
        //   final linePaint = Paint()
        //     ..color = Colors.black
        //     ..strokeWidth = 2.0
        //     ..style = PaintingStyle.stroke
        //     ..strokeJoin = StrokeJoin.round;
        //   double width = (coordinates[e_1].x.toDouble() +
        //           coordinates[element.value!].x.toDouble() +
        //           40) /
        //       2;
        // double height = max(
        //     (coordinates[e_1].x.toDouble() -
        //             coordinates[element.value!].x.toDouble())
        //         .abs(),
        //     (coordinates[e_1].y.toDouble() -
        //             coordinates[element.value!].y.toDouble())
        //         .abs());
        // path.moveTo(coordinates[e_1].x.toDouble() + 20,
        //     coordinates[e_1].y.toDouble() + 20);
        // path.quadraticBezierTo(
        //     max(width, width + 100),
        //     max(height, 100),
        //     coordinates[element.value!].x.toDouble() + 20,
        //     coordinates[element.value!].y.toDouble() + 20);
        // path.close();
        // canvas.drawPath(path, linePaint);
        // } else if (count == 1) {
        final linePaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
        path.moveTo(coordinates[e_1].x.toDouble() + 20,
            coordinates[e_1].y.toDouble() + 20);
        path.lineTo(coordinates[element.value!].x.toDouble() + 20,
            coordinates[element.value!].y.toDouble() + 20);
        canvas.drawPath(path, linePaint);
        final dX = end.dx - start.dx;
        final dY = end.dy - start.dy;
        final angle = atan2(dY, dX);
        const arrowSize = 40;
        const arrowAngle = 20 * pi / 180;

        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.fill
          ..strokeJoin = StrokeJoin.round;

        final x = start.dx + calculateArrowLength(start, end) * cos(angle);
        final y = start.dy + calculateArrowLength(start, end) * sin(angle);

        path.moveTo(x - arrowSize * cos(angle - arrowAngle),
            y - arrowSize * sin(angle - arrowAngle));
        path.lineTo(x, y);
        path.lineTo(x - arrowSize * cos(angle + arrowAngle),
            y - arrowSize * sin(angle + arrowAngle));
        path.close();
        canvas.drawPath(path, paint);
        // }

        // }
        // final direction = end - start;
        // final normalizedDirection = direction / direction.distance;
        // double arrowLength = 30;
        // const arrowAngle = pi / 6;
        // final arrowPoint1 = end - normalizedDirection * arrowLength;
        // final arrowPoint2 = arrowPoint1 +
        //     Offset(
        //       arrowLength * cos(arrowAngle + pi / 2),
        //       arrowLength * sin(arrowAngle + pi / 2),
        //     );
        // final arrowPoint3 = arrowPoint1 +
        //     Offset(
        //       arrowLength * cos(arrowAngle - pi / 2),
        //       arrowLength * sin(arrowAngle - pi / 2),
        //     );

        // //arrowhead path
        // final arrowheadPath = Path()
        //   ..moveTo(end.dx, end.dy)
        //   ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
        //   ..lineTo(arrowPoint3.dx, arrowPoint3.dy)
        //   ..close();

        // canvas.drawPath(path, paint);
        // canvas.drawPath(arrowheadPath, paint);
      }
    });

    adjList.forEach((e_1, e_2) {
      for (var element in e_2) {
        bool pathAlreadyPresent = false;

        for (var element_2 in adjList[element.value] ?? []) {
          if (element_2.value == e_1) {
            pathAlreadyPresent = true;
            break;
          }
        }

        if (pathAlreadyPresent) {
          double width = (coordinates[e_1].x.toDouble() +
                  coordinates[element.value!].x.toDouble() +
                  40) /
              2;
          double height = max(
              (coordinates[e_1].x.toDouble() -
                      coordinates[element.value!].x.toDouble())
                  .abs(),
              (coordinates[e_1].y.toDouble() -
                      coordinates[element.value!].y.toDouble())
                  .abs());
          final offset = (Offset(max(width, width + 100), max(height, 100)) +
                  Offset(coordinates[element.value!].x.toDouble() + 20,
                      coordinates[element.value!].y.toDouble() + 20)) /
              2;
          final textSpan = TextSpan(
              text: transitionMatrix[e_1][element.value!].toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ));
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(
            minWidth: 0,
            maxWidth: size.width,
          );
          textPainter.paint(canvas, offset);
        } else {
          final start = Offset(coordinates[e_1].x.toDouble() + 20,
              coordinates[e_1].y.toDouble() + 20);

          final end = Offset(coordinates[element.value!].x.toDouble() + 20,
              coordinates[element.value!].y.toDouble() + 20);

          final textSpan = TextSpan(
              text: transitionMatrix[e_1][element.value!].toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ));
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );

          textPainter.layout(
            minWidth: 0,
            maxWidth: size.width,
          );
          final offset = (start + end) / 2 + const Offset(10, 10);
          textPainter.paint(canvas, offset);
        }
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool? hitTest(Offset position) {
    return false;
  }
}

String pickRandom(Offset start, Offset end, int element) {
  double x = ((start + end) / 2).dx;
  double y = ((start + end) / 2).dy;
  return (((x + y) / 2) / 1000).toStringAsFixed(4);
}

Widget generatePair(int value, TextEditingController controller) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "${value.toString()}:  ",
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      SizedBox(
        width: 70,
        height: 30,
        child: TextField(
          textAlignVertical: TextAlignVertical.bottom,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          showCursor: false,
          controller: controller,
          decoration: InputDecoration(
            hintText: '',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15.0), // Adjust the radius as needed
            ),
          ),
        ),
      ),
    ],
  );
}
