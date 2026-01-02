import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: const HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Gold',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFC5A028),
          surface: Color(0xFF1D1E33),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HabitHomePage(),
    );
  }
}

// --- HABIT MODEL ---

class Habit {
  final String id;
  final String name;
  final IconData icon;
  bool isCompleted;
  double progress;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.isCompleted = false,
    this.progress = 0.0,
  });
}

// --- STATE MANAGEMENT ---

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [
    Habit(id: '1', name: 'Morning Meditation', icon: LucideIcons.sun, progress: 0.7),
    Habit(id: '2', name: 'Deep Reading', icon: LucideIcons.bookOpen, progress: 0.3),
  ];

  final List<String> _quotes = [
    "Quality is not an act, it is a habit.",
    "Your future is found in your routine.",
    "Motivation gets you started. Habit keeps you going.",
  ];

  List<Habit> get habits => _habits;
  String get randomQuote => (_quotes..shuffle()).first;

  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].isCompleted = !_habits[index].isCompleted;
      _habits[index].progress = _habits[index].isCompleted ? 1.0 : 0.0;
      notifyListeners();
    }
  }

  void addHabit(String name, IconData icon) {
    _habits.add(Habit(
      id: DateTime.now().toString(),
      name: name,
      icon: icon,
    ));
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }
}

// --- MAIN SCREEN ---

class HabitHomePage extends StatelessWidget {
  const HabitHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final quote = habitProvider.randomQuote;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("STAY CONSISTENT", style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("My Habits", style: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.quote, color: Color(0xFFD4AF37), size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(quote, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: habitProvider.habits.isEmpty
                  ? const Center(child: Text("No habits yet. Tap + to start!", style: TextStyle(color: Colors.white24)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: habitProvider.habits.length,
                itemBuilder: (context, index) => HabitCard(habit: habitProvider.habits[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () => _showAddHabitSheet(context),
        child: const Icon(LucideIcons.plus, color: Color(0xFF0A0E21)),
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1D1E33),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => const AddHabitSheet(),
    );
  }
}

// --- HABIT CARD COMPONENT ---

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1D1E33),
            title: const Text("Delete Habit?"),
            content: Text("Are you sure you want to delete '${habit.name}'?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id);
                  Navigator.pop(context);
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0A0E21), borderRadius: BorderRadius.circular(12)),
              child: Icon(habit.icon, color: const Color(0xFFD4AF37)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: habit.progress, backgroundColor: Colors.white10, color: const Color(0xFFD4AF37), minHeight: 6),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => Provider.of<HabitProvider>(context, listen: false).toggleHabit(habit.id),
              icon: Icon(
                habit.isCompleted ? LucideIcons.checkCircle : LucideIcons.circle,
                color: habit.isCompleted ? const Color(0xFFD4AF37) : Colors.white24,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ADD HABIT SHEET ---

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});
  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final TextEditingController _controller = TextEditingController();
  IconData selectedIcon = LucideIcons.activity;
  final List<IconData> iconOptions = [LucideIcons.activity, LucideIcons.anchor, LucideIcons.bike, LucideIcons.coffee, LucideIcons.heart, LucideIcons.moon, LucideIcons.zap];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("New Habit", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "What's the new goal?",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0A0E21),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: iconOptions.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => selectedIcon = iconOptions[index]),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedIcon == iconOptions[index] ? const Color(0xFFD4AF37) : const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconOptions[index], color: selectedIcon == iconOptions[index] ? const Color(0xFF0A0E21) : Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Provider.of<HabitProvider>(context, listen: false).addHabit(_controller.text, selectedIcon);
                  Navigator.pop(context);
                }
              },
              child: const Text("Create Habit", style: TextStyle(color: Color(0xFF0A0E21), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}