import 'package:flutter/material.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.timer_outlined,
                        size: 28,
                        color: Colors.white70,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.white70,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(),
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    leading: Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: false,
                        onChanged: (bool? value) {},
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    title: Text(
                      'Task ${index + 1}',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 24,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
