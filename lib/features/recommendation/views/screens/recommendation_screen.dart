import 'package:edu_app/features/ai/data/models/media.dart';
import 'package:edu_app/features/ai/views/widgets/media_deck_view.dart';
import 'package:edu_app/features/recommendation/views/screens/challenge_screen.dart';
import 'package:edu_app/features/recommendation/views/screens/example_screen.dart';
import 'package:flutter/material.dart';

class RecommendationScreen extends StatefulWidget {
  final String title;

  const RecommendationScreen({super.key, required this.title});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Tutorial'),
            Tab(icon: Icon(Icons.code), text: 'Examples'),
            Tab(icon: Icon(Icons.check_circle), text: 'Challenge'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MediaDeckView(
            needAppBar: false,
            media: Media(
              uid: "1",
              timestamp: DateTime.now(),
              content: dummyMediaContent,
            ),
          ),
          const ExampleScreen(),
          const ChallengeScreen(),
        ],
      ),
    );
  }
}

String dummyMediaContent = '''
{
  "presentation_title": "Dijkstra's Algorithm: Finding the Shortest Path",
  "target_audience": "Computer Science students and software developers familiar with basic\\ngraph concepts.",
  "slides": [
    {
      "slide_number": 1,
      "slide_type": "title",
      "title": "Dijkstra's Algorithm: Your GPS for Graphs",
      "content": "Navigate complex networks effortlessly! Dijkstra's Algorithm is a\\npowerful tool for finding the shortest path between nodes in a graph. Learn how it works and its real-world applications.\\nThis presentation breaks down the concept step-by-step.",
      "visual_suggestion": "An image of a winding road map with a clear starting and ending\\npoint. Overlayed visual elements could represent Dijkstra's algorithm finding the optimal route.",
      "presenter_notes": "Welcome the audience and briefly explain the purpose of the\\npresentation. Emphasize the practical relevance of Dijkstra's algorithm."
    },
    {
      "slide_number": 2,
      "slide_type": "content",
      "title": "What is Dijkstra's Algorithm?",
      "content": "Dijkstra's algorithm is a greedy algorithm used to find the shortest\\npaths from a starting node to all other nodes in a weighted graph. It's widely used in network routing, GPS systems, and\\npathfinding applications. Key elements include: Weighted Graph, Source Node, Distance Calculation.",
      "visual_suggestion": "A simple diagram of a weighted graph with nodes and edges,\\nhighlighting the source node.",
      "presenter_notes": "Define Dijkstra's algorithm clearly and concisely. Briefly\\nintroduce the key concepts like 'weighted graph' and 'source node' for the audience."
    },
    {
      "slide_number": 3,
      "slide_type": "visual",
      "title": "Visualizing the Process",
      "content": "The algorithm iteratively explores the graph, updating distances to each\\nnode from the starting point. Nodes are marked as visited once their shortest distance is finalized. The visual aid shows\\nhow nodes are selected, and edges explored to find shortest path.",
      "visual_suggestion": "An animated GIF or short video demonstrating Dijkstra's\\nalgorithm in action on a small graph. Highlight the node selection process and distance updates.",
      "presenter_notes": "Use the animation to visually explain how the algorithm iterates\\nand updates distances. Pause the animation at key points to explain the process."
    },
    {
      "slide_number": 4,
      "slide_type": "content",
      "title": "Step-by-Step Breakdown",
      "content": "* Initialize distances: Set distance to source node to 0, all others to\\ninfinity.\\n* Select unvisited node with the smallest distance.\\n* Update distances of neighbors: Calculate tentative\\ndistance, update if shorter.\\n* Mark current node as visited.\\n* Repeat until all nodes are visited.",
      "visual_suggestion": "Numbered list highlighting each step, with a simple icon\\nassociated with each step (e.g., infinity symbol for initialization, hand pointing for selection, arrows for distance\\nupdates).",
      "presenter_notes": "Walk through the algorithm step-by-step, explaining each action\\nin detail. Use simple language and provide concrete examples."
    },
    {
      "slide_number": 5,
      "slide_type": "data",
      "title": "Real-World Applications",
      "content": "* **GPS Navigation:** Finds the fastest route between locations.\\n*\\n**Network Routing:** Determines the optimal path for data packets.\\n* **Airline Ticketing:** Connects cities with the\\nfewest layovers.\\n* **Robotics:** Path planning for robots in complex environments.",
      "visual_suggestion": "A collage of images representing each application (e.g., a GPS\\ndevice, a network router, an airplane, a robot).",
      "presenter_notes": "Showcase the practical applications of Dijkstra's algorithm in\\nvarious industries. Emphasize its importance and impact."
    },
    {
      "slide_number": 6,
      "slide_type": "content",
      "title": "Limitations and Considerations",
      "content": "Dijkstra's algorithm does not work with graphs that have negative edge\\nweights. For graphs with negative weights, use the Bellman-Ford algorithm. The complexity is O(V^2) using adjacency\\nmatrix, and O(E log V) using priority queue. Choice of data structure has an impact on its performance.",
      "visual_suggestion": "A graph with a negative edge weight highlighted. A simple table\\nshowing the complexity differences between adjacency matrix and priority queue.",
      "presenter_notes": "Discuss the limitations of the algorithm and mention alternative\\nalgorithms for graphs with negative weights. Explain the time complexity and impact of data structures."
    },
    {
      "slide_number": 7,
      "slide_type": "conclusion",
      "title": "Mastering the Shortest Path",
      "content": "Dijkstra's Algorithm provides a powerful way to solve shortest path\\nproblems. By understanding its principles and applications, you can optimize network routing, navigation systems, and\\nmuch more. Explore further resources to deepen your knowledge and implement the algorithm yourself!",
      "visual_suggestion": "An image of a clear path leading to a destination, symbolizing\\nsuccessful navigation. Include links to online resources (e.g., GeeksforGeeks, Wikipedia) for further learning.",
      "presenter_notes": "Summarize the key takeaways and encourage the audience to explore\\nthe algorithm further. Provide resources for further learning."
    }
  ]
}
''';
