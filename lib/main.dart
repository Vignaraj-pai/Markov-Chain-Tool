import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'dart:core';

import 'package:bfs_visualiser/Graph_Node_widget.dart';
import 'package:bfs_visualiser/graph_node_class.dart';
import 'package:flutter/material.dart';

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
  List<GraphNodeClass> graph = [];
  List<Point> coordinates = [];
  Map<int, List<GraphNodeClass>> adjList = {};
  int currentNode = 0;
  GraphNodeClass? lastDoubleTapGraph;
  bool startVisualisation = false;
  TextEditingController? startNodeTextController;
  final formKey = GlobalKey<FormState>();
  ValueNotifier<String> disconnectedGraphNotifier = ValueNotifier("");
  late Widget _animatedWidget_1;
  late Widget _animatedWidget_2;
  late Widget _currentAnimatedWidget;

  initCoordinates() {
    coordinates.clear();
    int count = 0;
    while (count != totalNodes) {
      int x = Random().nextInt(window.physicalSize.width ~/ 2.2);
      int y = Random().nextInt(window.physicalSize.height ~/ 2.5);
      if (!coordinates.contains(Point(x, y))) {
        // print("$x $y");
        coordinates.add(Point(x, y));
        count++;
      }
    }
    _animatedWidget_2 = SizedBox(
      height: 150,
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: "Starting node",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              controller: startNodeTextController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter a value";
                }
                if (!RegExp(r'^-*[0-9]+$').hasMatch(value)) {
                  return "Please enter a number";
                }
                if (int.parse(value) < 0) {
                  return "Enter a positive number";
                }
                if (currentNode == 0 && int.parse(value) >= 0) {
                  return "Add some Nodes to the canvas";
                }
                if (int.parse(value) >= currentNode) {
                  return "Enter a value between 0 and ${currentNode - 1}";
                }
                return null;
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  startVisualisation = true;
                  await bfs(int.parse(startNodeTextController!.text));
                  disconnectedGraphNotifier.value = "Completed BFS!!";
                  setState(() {
                    _currentAnimatedWidget = _animatedWidget_1;
                    startVisualisation = false;
                    startNodeTextController?.clear();
                  });
                }
              },
              label: const Text(
                "Start",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ))
        ],
      ),
    );

    _animatedWidget_1 = SizedBox(
      child: FloatingActionButton.extended(
        label: const Text("Start Visualisation"),
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
      home: max(width, height) > 1000 && min(width, height) > 500
          ? Scaffold(
              floatingActionButton: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  !startVisualisation
                      ? Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            child: _currentAnimatedWidget,
                          ),
                        )
                      : Container(),
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
                  !startVisualisation
                      ? Padding(
                          padding: const EdgeInsets.only(right: 50.0),
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              lastDoubleTapGraph = null;
                              startVisualisation = false;
                              initCoordinates();
                              currentNode = 0;
                              disconnectedGraphNotifier.value = "";
                              setState(() {
                                graph = [];
                                adjList = {};
                                _currentAnimatedWidget = _animatedWidget_1;
                              });
                            },
                            label: const Text("Reset"),
                          ),
                        )
                      : Container(),
                  !startVisualisation
                      ? FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: () {
                            startNodeTextController?.clear();
                            if (currentNode >= totalNodes) {
                              disconnectedGraphNotifier.value =
                                  "Only a maximum of $totalNodes node(s) can be spawned!!";
                              return;
                            }
                            setState(() {
                              _currentAnimatedWidget = _animatedWidget_1;
                              graph.add(GraphNodeClass(
                                  value: currentNode,
                                  isVisited: false,
                                  isExplored: false));
                              currentNode++;
                            });
                          },
                        )
                      : SizedBox(
                          height: 0,
                          width: 0,
                          child: FloatingActionButton(onPressed: () {})),
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
                      child: Stack(children: [
                        startVisualisation
                            ? Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: GraphNode(
                                              graph: GraphNodeClass(
                                                  isVisited: true,
                                                  isExplored: false)),
                                        ),
                                        const Text("-> Visited"),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: GraphNode(
                                              graph: GraphNodeClass(
                                                  isVisited: false,
                                                  isExplored: true)),
                                        ),
                                        const Text("-> Explored"),
                                      ],
                                    )),
                              )
                            : Container(),
                        ...graph
                            .map((e) => Positioned(
                                  top: coordinates[e.value!].y.toDouble(),
                                  left: coordinates[e.value!].x.toDouble(),
                                  child: GestureDetector(
                                      onTap: () {
                                        if (!startVisualisation) {
                                          if (lastDoubleTapGraph == null) {
                                            lastDoubleTapGraph = e;
                                            // print("tapped");
                                          } else {
                                            if (e.value !=
                                                lastDoubleTapGraph!.value) {
                                              setState(() {
                                                if (adjList.containsKey(
                                                    lastDoubleTapGraph!
                                                        .value)) {
                                                  adjList[lastDoubleTapGraph!
                                                          .value]!
                                                      .add(e);
                                                } else {
                                                  adjList[lastDoubleTapGraph!
                                                      .value!] = [e];
                                                }
                                                if (adjList
                                                    .containsKey(e.value)) {
                                                  {
                                                    adjList[e.value]!.add(
                                                        lastDoubleTapGraph!);
                                                  }
                                                } else {
                                                  adjList[e.value!] = [
                                                    lastDoubleTapGraph!
                                                  ];
                                                }
                                                lastDoubleTapGraph = null;
                                              });
                                            }
                                          }
                                        }
                                      },
                                      child: GraphNode(graph: e)),
                                ))
                            .toList()
                      ]),
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

    adjList.forEach((e_1, e_2) {
      for (var element in e_2) {
        canvas.drawLine(
            Offset(coordinates[e_1].x.toDouble() + 20,
                coordinates[e_1].y.toDouble() + 20),
            Offset(coordinates[element.value!].x.toDouble() + 20,
                coordinates[element.value!].y.toDouble() + 20),
            paint);
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
