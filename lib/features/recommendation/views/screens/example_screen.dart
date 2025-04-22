import 'package:flutter/material.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ExampleItem(
            question:
                "What is the time complexity of Dijkstra's algorithm with a binary heap implementation?",
            answer:
                "O((V + E) log V), where V is the number of vertices and E is the number of edges in the graph.",
          ),
          SizedBox(height: 12),
          ExampleItem(
            question:
                "Can Dijkstra's algorithm work with negative edge weights?",
            answer:
                "No, Dijkstra's algorithm doesn't work with negative edge weights because it assumes that adding an edge to a path never decreases the path's total length. For graphs with negative edges, algorithms like Bellman-Ford should be used instead.",
          ),
          SizedBox(height: 12),
          ExampleItem(
            question:
                "What data structures are commonly used to implement Dijkstra's algorithm?",
            answer:
                "Common implementations use priority queues such as binary heaps, Fibonacci heaps, or binary search trees to efficiently extract the vertex with the minimum distance value.",
          ),
          SizedBox(height: 12),
          ExampleItem(
            question:
                "What is the difference between Dijkstra's algorithm and BFS (Breadth-First Search)?",
            answer:
                "While both algorithms find paths in graphs, BFS finds the shortest path in terms of the number of edges in unweighted graphs. Dijkstra's algorithm finds the shortest path in terms of the sum of edge weights in weighted graphs. BFS has a time complexity of O(V + E) while Dijkstra's is O((V + E) log V) with a binary heap.",
          ),
          SizedBox(height: 12),
          ExampleItem(
            question: "What is the primary purpose of Dijkstra's algorithm?",
            answer:
                "Dijkstra's algorithm is used to find the shortest path from a source node to all other nodes in a weighted graph with non-negative edge weights.",
          ),
        ],
      ),
    );
  }
}

class ExampleItem extends StatefulWidget {
  final String question;
  final String answer;

  const ExampleItem({super.key, required this.question, required this.answer});

  @override
  State<ExampleItem> createState() => _ExampleItemState();
}

class _ExampleItemState extends State<ExampleItem> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child:
                  _showAnswer
                      ? TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAnswer = false;
                          });
                        },
                        icon: Icon(
                          Icons.visibility_off,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          'Hide Answer',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                      : ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAnswer = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Show Answer'),
                      ),
            ),
            if (_showAnswer) ...[
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Answer',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
