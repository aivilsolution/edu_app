import 'package:flutter/material.dart';

class AvatarList extends StatelessWidget {
  const AvatarList({
    super.key,
    required this.avatarList,
  });

  final List<String> avatarList;

  @override
  Widget build(BuildContext context) {
    final displayedMembers = avatarList.take(3).toList();
    final remainingCount = avatarList.length - displayedMembers.length;
    const double avatarSize = 24;
    final double stackWidth = displayedMembers.length * (avatarSize * 0.7) +
        (remainingCount > 0 ? avatarSize : 0);

    return SizedBox(
      width: stackWidth + avatarSize * 0.1,
      height: avatarSize,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          for (var i = 0; i < displayedMembers.length; i++)
            Positioned(
              left: i * (avatarSize * 0.7),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1.5,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(displayedMembers[i]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: displayedMembers.length * (avatarSize * 0.7),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
