import 'package:flutter/material.dart';
import 'package:my_app/repository.dart';
import 'model.dart';
import 'dart:math';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> listNote = [];
  Repository repository = Repository();

  void getData() async {
    listNote = await repository.getData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    getData();
  }

  Color randomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Note'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => SearchPage(
                        listNote: listNote,
                      )),
            ),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: listNote.isEmpty
          ? const Center(
              child: Text('Save your note'),
            )
          : ListView.builder(
              itemCount: listNote.length,
              itemBuilder: (context, index) {
                final Color tileColor = randomColor();
                const Color textColor = Colors.white;

                return Card(
                  color: tileColor,
                  elevation: 2.0,
                  margin: const EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Text(
                      listNote[index].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      listNote[index].date,
                      style: const TextStyle(color: textColor),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () async {
                        Repository repository = new Repository();
                        final deleted = await repository
                            .delete(listNote[index].id.toString());
                        if (deleted) {
                          setState(() {
                            getData();
                            listNote.removeAt(index);
                          });
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            title: listNote[index].title,
                            content: listNote[index].content,
                            id: listNote[index].id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreatePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final List<Note> listNote;

  const SearchPage({Key? key, required this.listNote}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchTerm = '';

  List<Note> get searchResults {
    return widget.listNote
        .where((note) =>
            note.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
            note.content.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchTerm = '';
                    });
                  },
                ),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final note = searchResults[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.date),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailPage(
                    title: note.title, content: note.content, id: note.id),
              ),
            );
          },
        );
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final String content;
  final int id;

  const DetailPage(
      {required this.title, required this.content, required this.id, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditPage(
                      title: title, content: content, id: id.toString()),
                ),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void sendDataToAPI(String title, String content) {
    Repository repository = Repository();
    repository.postData(title, content).then((response) {
      if (response != null) {
        // Tutup halaman saat ini
        Navigator.of(context).pop();

        // Perbarui data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomePage(),
          ),
        );

        // Tampilkan pesan sukses
        const snackBar = SnackBar(
          content: Text('Update Note Succesfully!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }).catchError((error) {
      // Tangani kesalahan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Content:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter note content',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final content = contentController.text;
                sendDataToAPI(title, content);
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final String title;
  final String content;
  final String id; // Tambahkan parameter id

  const EditPage(
      {required this.title, required this.content, required this.id, Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    contentController.text = widget.content;
  }

  void saveChanges() async {
    Repository repository = Repository();
    final updatedTitle = titleController.text;
    final updatedContent = contentController.text;

    final updatedNote =
        await repository.editData(updatedTitle, updatedContent, widget.id);

    if (updatedNote != null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomePage(),
        ),
        (route) => false,
      );

      // Tampilkan pesan sukses
      // ignore: prefer_const_constructors
      final snackBar = SnackBar(
        content: const Text('Update Note Successfully!'),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          ElevatedButton(
            onPressed: saveChanges,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Content:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter note content',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
