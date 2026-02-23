import 'package:flutter/material.dart';

void main() {
  runApp(const InstagramDemo());
}

class InstagramDemo extends StatelessWidget {
  const InstagramDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Instagram",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.black),
          SizedBox(width: 15),
          Icon(Icons.send, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: ListView(
        children: const [
          StoriesSection(),
          Divider(),
          PostWidget(
            username: "usuario_1",
            imageUrl: "https://picsum.photos/500/400",
          ),
          PostWidget(
            username: "flutter_dev",
            imageUrl: "https://picsum.photos/500/401",
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.orange],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://picsum.photos/200",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text("user$index"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final String username;
  final String imageUrl;

  const PostWidget({
    super.key,
    required this.username,
    required this.imageUrl,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage("https://picsum.photos/100"),
          ),
          title: Text(widget.username),
          trailing: const Icon(Icons.more_vert),
        ),
        Image.network(widget.imageUrl),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
              },
            ),
            const IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: null,
            ),
            const IconButton(
              icon: Icon(Icons.send),
              onPressed: null,
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Me gusta esto ❤️",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}