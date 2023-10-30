class GraphNodeClass {
  bool isVisited;
  bool isExplored;
  int? value;

  GraphNodeClass({this.value,required this.isVisited,required this.isExplored});

  void markVisited() {
    isVisited = true;
  }

  void markExplored() {
    isExplored = true;
  }
}
