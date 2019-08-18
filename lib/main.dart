import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flushbar/flushbar.dart';
// https://blog.usejournal.com/implementing-swipe-to-delete-in-flutter-a742e041c5dd

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();
  final TextStyle _biggerFont = TextStyle(fontSize: 18.0);

  void _removeName(WordPair pair) {
    setState(() {
      _saved.remove(pair);
    });
  }

  void _addName(WordPair pair) {
    setState(() {
      _saved.add(pair);
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<Dismissible> tiles = _saved.map(
            (WordPair pair) {
              return Dismissible(
                background: stackBehindDismiss(),
                key: Key(pair.toString()),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: new ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                  ),
                ),
                onDismissed: (direction) {
                  //To delete from favorites
                  _removeName(pair);

                  // show the undo button
                  undoFlushBar(pair);
                },
              );
            },
          );

          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            // Add 6 lines from here...
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget undoFlushBar(WordPair pair) {
    return Flushbar(
        title: "Removed",
        message: "${pair.asPascalCase} removed from favorites.",
        duration: Duration(seconds: 6),
        borderRadius: 8,
        margin: EdgeInsets.all(8),
        mainButton: FlatButton(
          onPressed: () {
            _addName(pair);
            // flushbar.dismiss();
          },
          child: Text(
            "UNDO",
            style: TextStyle(color: Colors.amber),
          ),
        ))
      ..show(context);
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index], index);
        });
  }

  Widget _buildRow(WordPair pair, int index) {
    final bool alreadySaved = _saved.contains(pair);
    // final List<int> colorCodes = <int>[600, 500, 400, 300];
    // color: Colors.deepPurple[colorCodes[index % colorCodes.length]],

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        // Add the lines from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _removeName(pair);
          } else {
            _addName(pair);
          }
        });
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}
