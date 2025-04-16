import 'package:flutter/material.dart';
import 'bookdetailspage.dart';

class Book {
  final String title;
  final String author;
  final String coverImageUrl;

  Book({required this.title, required this.author, required this.coverImageUrl});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> books = [
    Book(
      title: "BOOK 1",
      author: "Auther 1",
      coverImageUrl: "assets/images/book.png",
    ),
    Book(
      title: "BOOK 2",
      author: "Auther 2",
      coverImageUrl: "assets/images/book.png",
    ),
    Book(
      title: "BOOK 3",
      author: "Auther 3",
      coverImageUrl: "assets/images/book.png",
    ),
    Book(
      title: "BOOK 4",
      author: "Auther 5",
      coverImageUrl: "assets/images/book.png",
    ),
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Book> filteredBooks = books.where((book) {
      final query = searchQuery.toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search by title or author",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailPage(book: book),
                  ),
                );
              },
              leading: Image.asset(
                book.coverImageUrl,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
              ),
              title: Text(book.title),
              subtitle: Text(book.author),
            ),
          );
        },
      ),
    );
  }
}