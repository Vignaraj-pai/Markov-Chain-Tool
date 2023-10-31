import 'package:bfs_visualiser/constants.dart';
import 'package:bfs_visualiser/graph_node_class.dart';
import 'package:flutter/material.dart';

class GraphNode extends StatelessWidget {
  final GraphNodeClass graph;
  final bool isSelected;
  const GraphNode({Key? key, required this.graph, required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kNodeRadius,
      height: kNodeRadius,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.black,
            width: 3,
          ),
          shape: BoxShape.circle),
      child: Center(
        child: Text(
          graph.value == null ? "" : graph.value.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
