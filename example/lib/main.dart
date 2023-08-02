import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/algo/models.dart';
import 'package:flutter_force_directed_graph/force_directed_graph_controller.dart';
import 'package:flutter_force_directed_graph/force_directed_graph_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Force Directed Graph Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Force Directed Graph Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ForceDirectedGraphController<int> controller =
      ForceDirectedGraphController(
    graph: ForceDirectedGraph.generateNTree(
      nodeCount: 50,
      maxDepth: 3,
      n: 4,
      generator: () {
        nodeCount++;
        return nodeCount;
      },
    ),
  );
  int nodeCount = 0;
  Set<int> nodes = {};
  Set<String> edges = {};
  double _scale = 1.0;
  int locatedTo = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.needUpdate();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Wrap(
            children: [
              ElevatedButton(
                onPressed: () {
                  final a = nodeCount;
                  nodeCount++;
                  controller.addNode(a);
                  nodes.clear();
                  edges.clear();
                },
                child: const Text('add node'),
              ),
              ElevatedButton(
                onPressed: () {
                  for (final node in nodes) {
                    controller.deleteNodeByData(node);
                  }
                  nodes.clear();
                  edges.clear();
                },
                child: const Text('del node'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {
                  if (nodes.length == 2) {
                    final a = nodes.first;
                    final b = nodes.last;
                    controller.addEdgeByData(a, b);
                  }
                  nodes.clear();
                  edges.clear();
                },
                child: const Text('add edge'),
              ),
              ElevatedButton(
                onPressed: () {
                  for (final edge in edges) {
                    final a = int.parse(edge.split(' <-> ').first);
                    final b = int.parse(edge.split(' <-> ').last);
                    controller.deleteEdgeByData(a, b);
                  }
                  nodes.clear();
                  edges.clear();
                },
                child: const Text('del edge'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.needUpdate();
                },
                child: const Text('update'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    nodes.clear();
                    edges.clear();
                    nodeCount = 0;
                    locatedTo = 0;
                    controller.graph = ForceDirectedGraph.generateNTree(
                      nodeCount: 50,
                      maxDepth: 3,
                      n: 4,
                      generator: () {
                        nodeCount++;
                        return nodeCount;
                      },
                    );
                  });
                },
                child: const Text('random'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.center();
                },
                child: const Text('center'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    locatedTo++;
                    locatedTo = locatedTo % controller.graph.nodes.length;
                    final data = controller.graph.nodes[locatedTo].data;
                    controller.locateTo(data);
                  });
                },
                child:
                    Text('locateTo ${controller.graph.nodes[locatedTo].data}'),
              ),
              Slider(
                value: _scale,
                min: 0.1,
                max: 2.0,
                onChanged: (value) {
                  setState(() {
                    _scale = value;
                    controller.scale = value;
                  });
                },
              )
            ],
          ),
          Expanded(
            child: ForceDirectedGraphWidget(
              controller: controller,
              nodesBuilder: (context, data) {
                return GestureDetector(
                  onTap: () {
                    print("onTap $data");
                    setState(() {
                      if (nodes.contains(data)) {
                        nodes.remove(data);
                      } else {
                        nodes.add(data);
                      }
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: nodes.contains(data) ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('$data'),
                  ),
                );
              },
              edgesBuilder: (context, a, b, distance) {
                return GestureDetector(
                  onTap: () {
                    final edge = "$a <-> $b";
                    setState(() {
                      if (edges.contains(edge)) {
                        edges.remove(edge);
                      } else {
                        edges.add(edge);
                      }
                      print("onTap $a <-$distance-> $b");
                    });
                  },
                  child: Container(
                    width: distance,
                    height: 16,
                    color: edges.contains("$a <-> $b")
                        ? Colors.green
                        : Colors.blue,
                    alignment: Alignment.center,
                    child: Text('$a <-> $b'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
