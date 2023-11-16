import 'dart:collection';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';
import 'dart:core';
import 'dart:ffi'
import 'package:ffi/ffi.dart'

import 'package:arrow_path/arrow_path.dart';
import 'package:bfs_visualiser/Graph_Node_widget.dart';
import 'package:bfs_visualiser/constants.dart';
import 'package:bfs_visualiser/graph_node_class.dart';
import 'package:flutter/material.dart';

void main() {
  // FFIBridge.initialize();
  runApp(const MyApp());
}

// Works for Linux and Android
// class FFIBridge {
//   static bool initialize() {
//     nativeApiLib = (DynamicLibrary.open('../markov-lib/markov.so'));

//     final _create_markov_chain = nativeApiLib.lookup<NativeFunction<Pointer<Void> Function(Int32)>>('create_markov_chain');
//     create_markov_chain = _create_markov_chain.asFunction<Pointer<Void> Function(int)>();

//     set_transition_matrix = nativeApiLib.lookupFunction<Void Function(Pointer<Void>, Pointer<Void>),
//                                                                     void Function(Pointer<Void>, Pointer<Void>)>('set_transition_matrix');

//     calculate_state = nativeApiLib.lookupFunction<Pointer<Float> Function(Pointer<Void>, Pointer<Void>, Int32),
//                                                                     Pointer<Float> Function(Pointer<Void>, Pointer<Void>, int)>('set_transition_matrix');
//     return true;
//   }

//   static late DynamicLibrary nativeApiLib;
//   static late Function create_markov_chain;
//   static late Function set_transition_matrix;
//   static late Function calculate_state;
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int totalNodes = 50;
  List<GraphNodeClass> graph = []; //stores all nodes
  List<Point> coordinates = []; //stores coordinates of all nodes
  Map<int, List<GraphNodeClass>> adjList = {}; //stores adjacency list
  int currentNode = 0; //node to be added next
  GraphNodeClass? lastDoubleTapNode; //stores the last node double tapped
  TextEditingController? startNodeTextController;
  final formKey = GlobalKey<FormState>();
  ValueNotifier<String> disconnectedGraphNotifier = ValueNotifier("");
  List<List<int>>? transitionMatrix;
  bool nodePresent = false;
  late Widget _animatedWidget_1;
  late Widget _animatedWidget_2;
  late Widget _currentAnimatedWidget;
  Offset? _tapPosition;

  initCoordinates() {
    // coordinates.clear();
    // int count = 0;
    // while (count != totalNodes) {
    //   int x = Random().nextInt(window.physicalSize.width ~/ 2.2);
    //   int y = Random().nextInt(window.physicalSize.height ~/ 2.5);
    //   if (!coordinates.contains(Point(x, y))) {
    //     // print("$x $y");
    //     coordinates.add(Point(x, y));
    //     count++;
    //   }
    // }
    // _animatedWidget_2 = SizedBox(
    //     height: 150,
    //     width: 220,
    //     child: GridView.count(
    //       crossAxisCount: graph.length,
    //       children: List.generate(graph, (index) => null),
    //     ));

    _animatedWidget_1 = SizedBox(
      child: FloatingActionButton.extended(
        label: const Text("Enter Transition Matrix"),
        hoverColor: Colors.green,
        onPressed: () {
          setState(() {
            _currentAnimatedWidget = _animatedWidget_2;
          });
        },
      ),
    );

    _currentAnimatedWidget = _animatedWidget_1;
  }

  @override
  void initState() {
    startNodeTextController = TextEditingController();
    initCoordinates();
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
              floatingActionButton: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      child: _currentAnimatedWidget,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: ValueListenableBuilder(
                        valueListenable: disconnectedGraphNotifier,
                        builder: ((context, value, child) {
                          return Text(value,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16));
                        })),
                  ),
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
                              disconnectedGraphNotifier.value = "";
                              setState(() {
                                graph = [];
                                adjList = {};
                                coordinates = [];
                                _currentAnimatedWidget = _animatedWidget_1;
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
                                print(graph.length);
                              });
                            },
                            label: const Text("Undo"),
                          ),
                        )
                      : Container()
                  // !startVisualisation
                  //     ? FloatingActionButton(
                  //         child: const Icon(Icons.add),
                  //         onPressed: () {},
                  //       )
                  //     : SizedBox(
                  //         height: 0,
                  //         width: 0,
                  //         child: FloatingActionButton(onPressed: () {})),
                ],
              ),
              // appBar: AppBar(
              //   title: const Text('BFS Visualiser'),
              // ),
              body: Builder(builder: (context) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: CustomPaint(
                      painter: LinePainter(
                          adjList: adjList, coordinates: coordinates),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTapDown: (details) {
                          _tapPosition = Offset(details.globalPosition.dx - 20,
                              details.globalPosition.dy - 20);
                        },
                        onTap: () {
                          startNodeTextController?.clear();
                          lastDoubleTapNode = null;
                          if (currentNode >= totalNodes) {
                            disconnectedGraphNotifier.value =
                                "Only a maximum of $totalNodes node(s) can be spawned!!";
                            return;
                          }
                          coordinates.add(Point(
                              _tapPosition?.dx ?? 0, _tapPosition?.dy ?? 0));
                          setState(() {
                            _currentAnimatedWidget = _animatedWidget_1;
                            graph.add(GraphNodeClass(
                                value: currentNode,
                                isVisited: false,
                                isExplored: false));
                            currentNode++;
                            nodePresent = true;
                          });
                        },
                        child: Stack(children: [
                          // startVisualisation
                          // ? Padding(
                          //     padding: const EdgeInsets.all(12.0),
                          //     child: Align(
                          //         alignment: Alignment.bottomRight,
                          //         child: Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.end,
                          //           children: [
                          //             // Padding(
                          //             //   padding: const EdgeInsets.symmetric(
                          //             //       horizontal: 8.0),
                          //             //   child: GraphNode(
                          //             //       graph: GraphNodeClass(
                          //             //           isVisited: true,
                          //             //           isExplored: false)),
                          //             // ),
                          //             // const Text("-> Visited"),
                          //             // const SizedBox(
                          //             //   width: 10,
                          //             // ),
                          //             // Padding(
                          //             //   padding: const EdgeInsets.symmetric(
                          //             //       horizontal: 8.0),
                          //             //   child: GraphNode(
                          //             //       graph: GraphNodeClass(
                          //             //           isVisited: false,
                          //             //           isExplored: true)),
                          //             // ),
                          //             // const Text("-> Explored"),
                          //           ],
                          //         )),
                          //   )
                          // : Container(),
                          ...graph
                              .map((e) => Positioned(
                                    top: coordinates[e.value!].y.toDouble(),
                                    left: coordinates[e.value!].x.toDouble(),
                                    child: GestureDetector(
                                        onTap: () {
                                          if (lastDoubleTapNode == null) {
                                            setState(() {
                                              lastDoubleTapNode = e;
                                            });
                                          } else {
                                            if (e.value !=
                                                lastDoubleTapNode!.value) {
                                              setState(() {
                                                if (adjList.containsKey(
                                                    lastDoubleTapNode!.value)) {
                                                  adjList[lastDoubleTapNode!
                                                          .value]!
                                                      .add(e);
                                                } else {
                                                  adjList[lastDoubleTapNode!
                                                      .value!] = [e];
                                                }
                                                if (adjList
                                                    .containsKey(e.value)) {
                                                  {
                                                    adjList[e.value]!.add(
                                                        lastDoubleTapNode!);
                                                  }
                                                } else {
                                                  adjList[e.value!] = [
                                                    lastDoubleTapNode!
                                                  ];
                                                }
                                                lastDoubleTapNode = null;
                                              });
                                            }
                                          }
                                        },
                                        child: GraphNode(
                                            graph: e,
                                            isSelected: e.value ==
                                                    lastDoubleTapNode?.value
                                                ? true
                                                : false)),
                                  ))
                              .toList()
                        ]),
                      ),
                    ));
              }))
          : Container(
              color: Colors.black,
              child: const Center(
                child: Text("Please use a larger device"),
              ),
            ),
    );
  }

  //BFS Algorithm

  // ignore: non_constant_identifier_names
  Future<void> bfs_connected(Queue<int> q) async {
    while (q.isNotEmpty) {
      int front = q.removeFirst();
      // print("${adjList[front]}");
      if (adjList.containsKey(front)) {
        for (GraphNodeClass visitingNode in adjList[front]!) {
          if (!graph[visitingNode.value!].isVisited) {
            setState(() {
              graph[visitingNode.value!].markVisited();
            });
            q.add(visitingNode.value!);
            await Future.delayed(const Duration(seconds: 1));
            // print("${visitingNode.value} visited \n");
          }
        }
      }
      setState(() {
        graph[front].markExplored();
      });
      await Future.delayed(const Duration(seconds: 1));
      // print("${front} explored \n");
    }
  }

  Future<void> bfs(int start) async {
    Queue<int> q = Queue();

    setState(() {
      graph[graph.indexWhere((element) => element.value == start)]
          .markVisited();
    });

    await Future.delayed(const Duration(seconds: 1));

    q.add(start);
    await bfs_connected(q);

    for (var element in graph) {
      if (element.isExplored == false) {
        disconnectedGraphNotifier.value =
            "Disconnected graph has been detected!! Starting BFS on it from position ${element.value}";
        await Future.delayed(const Duration(seconds: 2));
        await bfs(element.value!);
      }
    }
  }
}

class LinePainter extends CustomPainter {
  final Map<int, List<GraphNodeClass>> adjList;
  final List<Point> coordinates;
  LinePainter({required this.adjList, required this.coordinates});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    print(adjList);
    adjList.forEach((e_1, e_2) {
      for (var element in e_2) {
        canvas.drawLine(
            Offset(coordinates[e_1].x.toDouble() + 20,
                coordinates[e_1].y.toDouble() + 20),
            Offset(coordinates[element.value!].x.toDouble() + 20,
                coordinates[element.value!].y.toDouble() + 20),
            paint);
        // // canvas.drawLine(Offset(coordinates[element.value!].x.toDouble() + 20, coordinates[element.value!].y.toDouble() + 20),
        // // Offset(coordinates[element.value!].x.toDouble() + 20, coordinates[element.value!].y.toDouble() + 20),paint);
        // Path path = Path();
        // // path.moveTo(coordinates[element.value!].x.toDouble() + 20,
        // //     coordinates[element.value!].y.toDouble() + 20);
        // path.moveTo(100, 100);
        // path = ArrowPath.addTip(path);
        // // path.moveTo(size.width * 0.25, 120);
        // // path.relativeCubicTo(0, 0, size.width * 0.25, 50, size.width * 0.5, 0);
        // // path = ArrowPath.addTip(path);

        // canvas.drawPath(path, paint..color = Colors.blue);

        // Path path = Path();
        // path.moveTo(100, 60);
        // path.relativeCubicTo(0, 0, size.width * 0.25, 50, size.width * 0.5, 0);
        // path = ArrowPath.addTip(path, tipAngle: 2, tipLength: 10);

        // canvas.drawPath(path, paint..color = Colors.blue);
        // Path path = Path();
        // path.relativeLineTo(100, 100);
        // path = ArrowPath.addTip(path);
        // canvas.drawPath(path, paint..color = Colors.blue);

        //   Path path = Path();
        //   path.moveTo(size.width * 0.25, 60);
        //   path.
        //   path = ArrowPath.addTip(path);

        //   canvas.drawPath(path, paint..color = Colors.blue);

        //   const TextSpan textSpan = TextSpan(
        //     text: 'Single arrow',
        //     style: TextStyle(color: Colors.blue),
        //   );
        //   final TextPainter textPainter = TextPainter(
        //     text: textSpan,
        //     textAlign: TextAlign.center,
        //     textDirection: TextDirection.ltr,
        //   );
        //   textPainter.layout(minWidth: size.width);
        //   textPainter.paint(canvas, const Offset(0, 36));
      }
    });

    adjList.forEach((e_1, e_2) {
      for (var element in e_2) {
        final start = Offset(coordinates[e_1].x.toDouble() + 20,
            coordinates[e_1].y.toDouble() + 20);

        final end = Offset(coordinates[element.value!].x.toDouble() + 20,
            coordinates[element.value!].y.toDouble() + 20);

        final textSpan = TextSpan(
            text: pickRandom(start, end, element.value ?? 1),
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
        final offset = (start + end) / 2;
        textPainter.paint(canvas, offset);
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

String pickRandom(Offset start, Offset end, int element) {
  double x = ((start + end) / 2).dx;
  double y = ((start + end) / 2).dy;
  return (((x + y) / 2) / 1000).toStringAsFixed(4);
}
