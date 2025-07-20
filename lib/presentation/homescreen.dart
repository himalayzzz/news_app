import 'package:flutter/material.dart';
import 'package:news_app/api/api.dart';
import 'package:news_app/news_model/news_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  late Future<NewsModel> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = getNews(); // or 'in'
  }

  Future<void> _launchArticleUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No URL provided for this article.')),
      );
      return;
    }

    // Prefix with https:// if missing
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception("launchUrl returned false");
      }
    } catch (e) {
      print('Launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text(
          'News App',
          style: TextStyle(color: Color.fromARGB(255, 60, 193, 255)),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: FutureBuilder<NewsModel>(
          future: newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  "Failed to load news",
                  style: TextStyle(color: Color.fromARGB(255, 226, 21, 21)),
                ),
              );
            }

            final articles = snapshot.data!.articles ?? [];

            if (articles.isEmpty) {
              return const Center(
                child: Text(
                  "No news articles available.",
                  style: TextStyle(color: Color.fromARGB(255, 64, 255, 6)),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final article = articles[index];
                return ListTile(
                  onTap: () => _launchArticleUrl(article.url),
                  contentPadding: const EdgeInsets.all(10),
                  leading: article.urlToImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            article.urlToImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 60),
                          ),
                        )
                      : const Icon(Icons.image, size: 60),
                  title: Text(
                    article.title ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 204, 0, 255),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        article.description ?? 'No Description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color.fromARGB(221, 255, 255, 255)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.publishedAt?.substring(0, 16) ??
                            'No publish time',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}