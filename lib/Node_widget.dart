import 'package:flutter/material.dart';
import 'package:markov_chain/constants.dart';
import 'package:markov_chain/node_class.dart';

class GraphNode extends StatelessWidget {
  final bool done;
  final bool isAbsorbing;
  final NodeClass graph;
  final bool isSelected;
  final bool isStart;
  const GraphNode(
      {Key? key,
      required this.graph,
      required this.isSelected,
      required this.isStart,
      required this.done,
      required this.isAbsorbing})
      : super(key: key);

  Color decideColor() {
    if (isSelected) {
      return Colors.green;
    } else if (isStart) {
      return Colors.red;
    }
    return Colors.black;
  }

  String decideNumber() {
    if (done) {
      return graph.finalState.toString();
    }
    return graph.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kNodeRadius,
      height: kNodeRadius,
      decoration: BoxDecoration(
          color: isAbsorbing ? Colors.green : Colors.white,
          border: Border.all(
            color: decideColor(),
            width: 3,
          ),
          shape: BoxShape.circle),
      child: Center(
        child: FittedBox(
          child: Text(
            decideNumber(),
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
