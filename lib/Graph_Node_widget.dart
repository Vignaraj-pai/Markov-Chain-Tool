import 'package:bfs_visualiser/constants.dart';
import 'package:bfs_visualiser/graph_node_class.dart';
import 'package:flutter/material.dart';

class GraphNode extends StatefulWidget {
  final GraphNodeClass graph;
  const GraphNode({Key? key, required this.graph}) : super(key: key);

  @override
  State<GraphNode> createState() => _GraphNodeState();
}

class _GraphNodeState extends State<GraphNode> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      child: Container(
        width: kNodeRadius,
        height:kNodeRadius,
        decoration: BoxDecoration(
            color: widget.graph.isExplored ? Colors.green : widget.graph.isVisited ? Colors.grey : Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            shape: BoxShape.circle),
        child: Center(
          child: Text(
            widget.graph.value == null ? "" : widget.graph.value.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
