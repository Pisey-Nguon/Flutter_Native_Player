
import 'package:flutter/material.dart';

class PlayerPinHeaderWidget extends SliverPersistentHeaderDelegate{
  final IconData iconData;
  final String title;

  PlayerPinHeaderWidget({required this.iconData, required this.title});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 14),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData,color: Colors.black87,),
          const SizedBox(width: 5,),
          Text(title,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15))
        ],
      ),
    );
  }

  @override
  double get maxExtent =>60;

  @override
  double get minExtent =>60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
  
}