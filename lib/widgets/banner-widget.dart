// ignore_for_file: file_names, unused_field, avoid_unnecessary_containers, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chichanka_perfume/controllers/banners-controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final CarouselController carouselController = CarouselController();
  final bannerController _bannerController = Get.put(bannerController());
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     child: Obx(() {
  //       return CarouselSlider(
  //         items: _bannerController.bannerUrls
  //             .map(
  //               (imageUrls) => ClipRRect(
  //                 borderRadius: BorderRadius.circular(10.0),
  //                 child: CachedNetworkImage(
  //                   imageUrl: imageUrls,
  //                   fit: BoxFit.cover,
  //                   width: Get.width - 10,
  //                   placeholder: (context, url) => ColoredBox(
  //                     color: Colors.white,
  //                     child: Center(
  //                       child: CupertinoActivityIndicator(),
  //                     ),
  //                   ),
  //                   errorWidget: (context, url, error) => Icon(Icons.error),
  //                 ),
  //               ),
  //             )
  //             .toList(),
  //         options: CarouselOptions(
  //           scrollDirection: Axis.horizontal,
  //           autoPlay: true,
  //           aspectRatio: 2.5,
  //           viewportFraction: 1,
  //         ),
  //       );
  //     }),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // Danh sách link ảnh tĩnh
    final List<String> demoBannerUrls = [
      'https://i.pinimg.com/736x/0c/ad/12/0cad129d9c0d34eaac50302009a2360c.jpg',
      'https://i.pinimg.com/736x/29/5d/bf/295dbff01f15e244dfa253741366f8bc.jpg',
      'https://i.pinimg.com/736x/d1/cc/6f/d1cc6f87b17863157c707ef9a3bf16f9.jpg',
    ];

    return Container(
      child: CarouselSlider(
        items: demoBannerUrls
            .map(
              (imageUrl) => ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: Get.width - 10,
                  placeholder: (context, url) => ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            )
            .toList(),
        options: CarouselOptions(
          scrollDirection: Axis.horizontal,
          autoPlay: true,
          aspectRatio: 2.5,
          viewportFraction: 1,
        ),
      ),
    );
  }
}
