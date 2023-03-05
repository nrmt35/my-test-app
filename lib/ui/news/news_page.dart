import 'package:flutter/material.dart';
import 'package:my_test_app/ui/news/news_card.dart';

import '../../data/dummy_data.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: news.length,
          itemBuilder: (context, index) => NewsCard(news: news[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 20),
        ),
      ),
    );
  }
}
