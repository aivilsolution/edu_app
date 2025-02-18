import 'package:edu_app/features/ai/views/pages/chats_page.dart';
import 'package:edu_app/features/ai/views/pages/recommedation_page.dart';
import 'package:flutter/material.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(children: const [ChatsPage(), RecommendationPage()]),
    ),
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    title: const Text('AI'),
    centerTitle: true,
    bottom: TabBar(
      labelColor: Theme.of(context).colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tabs: [Tab(text: 'Chat'), Tab(text: 'Recommendation')],
    ),
  );
}
