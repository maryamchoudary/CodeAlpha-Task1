import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FlashcardApp());

class Flashcard {
  String question;
  String answer;
  Flashcard({required this.question, required this.answer});
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const FlashcardHome(),
    );
  }
}

class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});

  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome>
    with SingleTickerProviderStateMixin {
  final List<Flashcard> _flashcards = [
    Flashcard(question: "What is Flutter?", answer: "An open-source UI toolkit by Google."),
    Flashcard(question: "What language is used in Flutter?", answer: "Dart."),
    Flashcard(question: "Capital of Pakistan?", answer: "Islamabad."),
    Flashcard(question: "Who developed Python?", answer: "Guido van Rossum."),
    Flashcard(question: "OOP stands for?", answer: "Object-Oriented Programming."),
    Flashcard(question: "HTML stands for?", answer: "HyperText Markup Language."),
    Flashcard(question: "CSS is mainly used for?", answer: "Styling web pages."),
    Flashcard(question: "HTTP stands for?", answer: "HyperText Transfer Protocol."),
    Flashcard(question: "What is SQL used for?", answer: "Managing and querying databases."),
    Flashcard(question: "RAM stands for?", answer: "Random Access Memory."),
    Flashcard(question: "What is AI?", answer: "Artificial Intelligence."),
    Flashcard(question: "Who created C language?", answer: "Dennis Ritchie."),
    Flashcard(question: "Speed of light?", answer: "≈ 299,792 km/s."),
    Flashcard(question: "What is 2 + 2 × 2?", answer: "6 (order of operations)."),
    Flashcard(question: "Boiling point of water?", answer: "100°C or 212°F."),
    Flashcard(question: "National animal of Pakistan?", answer: "Markhor."),
    Flashcard(question: "When did WWII end?", answer: "1945."),
    Flashcard(question: "Who is the founder of Microsoft?", answer: "Bill Gates."),
    Flashcard(question: "Full form of URL?", answer: "Uniform Resource Locator."),
    Flashcard(question: "Which planet is known as the Red Planet?", answer: "Mars."),
  ];

  int _currentIndex = 0;
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  void _ensureFront() {
    if (!_isFront) {
      _controller.reverse();
      _isFront = true;
    }
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _ensureFront();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('This is the last card')));
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _ensureFront();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('This is the first card')));
    }
  }

  void _showAddEditDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final qCtrl = TextEditingController(
        text: isEdit ? _flashcards[editIndex].question : '');
    final aCtrl =
        TextEditingController(text: isEdit ? _flashcards[editIndex].answer : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Flashcard' : 'Add Flashcard'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: qCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = qCtrl.text.trim();
              final a = aCtrl.text.trim();
              if (q.isEmpty || a.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Both fields are required')),
                );
                return;
              }
              setState(() {
                if (isEdit) {
                  _flashcards[editIndex!] = Flashcard(question: q, answer: a);
                } else {
                  _flashcards.add(Flashcard(question: q, answer: a));
                  _currentIndex = _flashcards.length - 1;
                }
                _ensureFront();
              });
              Navigator.of(ctx).pop();
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCurrent() {
    if (_flashcards.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _flashcards.removeAt(_currentIndex);
                if (_currentIndex >= _flashcards.length) {
                  _currentIndex = _flashcards.isEmpty ? 0 : _flashcards.length - 1;
                }
                _ensureFront();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(Flashcard card) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isFront = angle <= (pi / 2);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(isFront ? 0 : pi),
                    child: Text(
                      isFront ? card.question : card.answer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isFront ? 22 : 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontStyle: isFront ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = _flashcards.isNotEmpty;
    final title = hasCards
        ? 'Card ${_currentIndex + 1} / ${_flashcards.length}'
        : 'No Flashcards';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          if (hasCards)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddEditDialog(editIndex: _currentIndex),
            ),
          if (hasCards)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCurrent,
            ),
        ],
      ),
      body: Center(
        child: hasCards
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFlipCard(_flashcards[_currentIndex]),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _previousCard,
                        label: const Text("Previous"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _nextCard,
                        label: const Text("Next"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap the card to flip",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : const Text("No flashcards yet. Add one to begin!"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Flashcard"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
