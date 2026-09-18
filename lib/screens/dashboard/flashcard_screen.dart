import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../services/flashcard_provider.dart';
import '../../services/learning_provider.dart';
import '../../services/user_provider.dart';
import '../../services/theme_service.dart';
import '../../models/learning/flashcard_model.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  String _activeTab = "due"; // "due", "today", "new", "all", "fav"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FlashcardProvider>(context, listen: false).fetchCards();
      Provider.of<LearningProvider>(context, listen: false).fetchSubjects();
    });
  }

  List<FlashcardModel> _getActiveList(FlashcardProvider provider) {
    if (_activeTab == "due") return provider.dueNowCards;
    if (_activeTab == "today") return provider.dueTodayCards;
    if (_activeTab == "new") return provider.newCards;
    if (_activeTab == "fav") return provider.favoriteCards;
    return provider.filteredCards;
  }

  void _handleReview(int quality, FlashcardProvider provider, List<FlashcardModel> activeList) {
    if (activeList.isEmpty || _currentIndex >= activeList.length) return;
    
    final currentCard = activeList[_currentIndex];
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    provider.reviewCard(currentCard, quality, userProvider: userProvider);

    setState(() {
      _isFlipped = false;
      if (_currentIndex < activeList.length - 1) {
        _currentIndex++;
      } else {
        _showFinishedDialog();
      }
    });
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Session Complete! 🎉", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
        content: const Text(
          "Great job! You've reviewed all cards in this view. Earned +5 XP per card.",
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text("Awesome!", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openCreateCardDialog(BuildContext context, {FlashcardModel? cardToEdit}) {
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    final learning = Provider.of<LearningProvider>(context, listen: false);

    final qCtrl = TextEditingController(text: cardToEdit?.question ?? "");
    final aCtrl = TextEditingController(text: cardToEdit?.answer ?? "");
    String? selectedSub = cardToEdit?.subjectId;
    String? selectedTop = cardToEdit?.topicId;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          cardToEdit == null ? "Create Flashcard" : "Edit Flashcard",
          style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qCtrl,
                style: const TextStyle(color: AppColors.primaryText),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Front (Question / Prompt)",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aCtrl,
                style: const TextStyle(color: AppColors.primaryText),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Back (Answer / Explanation)",
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSub,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.primaryText),
                hint: const Text("Select Subject (Optional)", style: TextStyle(color: AppColors.secondaryText)),
                items: learning.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => selectedSub = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel", style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (qCtrl.text.trim().isEmpty || aCtrl.text.trim().isEmpty) return;
              if (cardToEdit == null) {
                await provider.addCard(
                  question: qCtrl.text.trim(),
                  answer: aCtrl.text.trim(),
                  subjectId: selectedSub,
                  topicId: selectedTop,
                );
              } else {
                await provider.editCard(
                  cardId: cardToEdit.id,
                  question: qCtrl.text.trim(),
                  answer: aCtrl.text.trim(),
                  subjectId: selectedSub,
                  topicId: selectedTop,
                );
              }
              if (mounted) Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text("Save", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openAiGeneratorDialog(BuildContext context) {
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    final learning = Provider.of<LearningProvider>(context, listen: false);

    final subCtrl = TextEditingController(text: learning.subjects.isNotEmpty ? learning.subjects.first.name : "Computer Science");
    final topCtrl = TextEditingController(text: "Algorithms");
    final countCtrl = TextEditingController(text: "5");
    final notesCtrl = TextEditingController();
    String difficulty = "Medium";
    String language = "English";

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("✨ Generate Flashcards with AI", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subCtrl,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Subject (e.g. Physics, History)"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: topCtrl,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Topic (e.g. Quantum Mechanics)"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: countCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Number of Cards (3 - 15)"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Optional Notes / Reference Text"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel", style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              onPressed: () async {
                final sub = subCtrl.text.trim();
                final top = topCtrl.text.trim();
                final count = int.tryParse(countCtrl.text.trim()) ?? 5;
                Navigator.pop(dialogCtx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Generating AI Flashcards... Please wait."),
                    backgroundColor: AppColors.card,
                  ),
                );

                final generated = await provider.generateAiCards(
                  subject: sub,
                  topic: top,
                  count: count,
                  difficulty: difficulty,
                  language: language,
                  optionalNotes: notesCtrl.text.trim(),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully generated $generated AI Flashcards! 🎉"),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text("Generate", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FlashcardProvider>(context);
    final activeList = _getActiveList(provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Smart Flashcards", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.accent),
            tooltip: "Generate with AI",
            onPressed: () => _openAiGeneratorDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryText),
            tooltip: "Create Flashcard",
            onPressed: () => _openCreateCardDialog(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                const SizedBox(height: 10),
                _buildFilterTabs(provider),
                const SizedBox(height: 10),
                Expanded(
                  child: activeList.isEmpty
                      ? _buildEmptyState(provider)
                      : _buildFlashcardStudyView(provider, activeList),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterTabs(FlashcardProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip("Due Now (${provider.dueNowCards.length})", "due"),
          _filterChip("Due Today (${provider.dueTodayCards.length})", "today"),
          _filterChip("New (${provider.newCards.length})", "new"),
          _filterChip("Favorites (${provider.favoriteCards.length})", "fav"),
          _filterChip("All Cards (${provider.filteredCards.length})", "all"),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String tabKey) {
    final isSelected = _activeTab == tabKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.accent,
        backgroundColor: AppColors.card,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.goldInk : AppColors.primaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        side: BorderSide(color: isSelected ? AppColors.accent : AppColors.border),
        onSelected: (_) => setState(() {
          _activeTab = tabKey;
          _currentIndex = 0;
          _isFlipped = false;
        }),
      ),
    );
  }

  Widget _buildEmptyState(FlashcardProvider provider) {
    String message = "No flashcards due right now!";
    if (_activeTab == "new") message = "No new cards available.";
    if (_activeTab == "fav") message = "No favorite cards yet.";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.card),
              child: const Icon(Icons.style_outlined, size: 64, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Review new cards, create custom decks, or generate cards automatically with AI.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openCreateCardDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Create Card"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAiGeneratorDialog(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: AppColors.background),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text("Generate with AI"),
                ),
                if (_activeTab != "all" && provider.filteredCards.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _activeTab = "all"),
                    icon: const Icon(Icons.style, color: AppColors.primaryText),
                    label: const Text("Practice All Cards", style: TextStyle(color: AppColors.primaryText)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardStudyView(FlashcardProvider provider, List<FlashcardModel> activeList) {
    if (_currentIndex >= activeList.length) {
      _currentIndex = 0;
    }
    final card = activeList[_currentIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / activeList.length,
                backgroundColor: AppColors.card,
                color: AppColors.accent,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Card ${_currentIndex + 1} of ${activeList.length}", style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(card.isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: card.isFavorite ? AppColors.accent : AppColors.secondaryText, size: 20),
                        onPressed: () => provider.toggleFavorite(card),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.secondaryText, size: 18),
                        onPressed: () => _openCreateCardDialog(context, cardToEdit: card),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () => provider.deleteCard(card.id),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Card Flip Container
        GestureDetector(
          onTap: () => setState(() => _isFlipped = !_isFlipped),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                return AnimatedBuilder(
                  animation: rotate,
                  builder: (context, child) {
                    final tilt = (rotate.value <= pi / 2) ? rotate.value : pi - rotate.value;
                    return Transform(
                      transform: Matrix4.rotationY(tilt),
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              child: _isFlipped
                  ? _buildCardFace(card.answer, true)
                  : _buildCardFace(card.question, false),
            ),
          ),
        ),

        const Spacer(),

        // Confidence Row (SM-2 options)
        if (_isFlipped)
          _buildConfidenceRow(provider, activeList)
        else
          const Text("Tap card to flip answer", style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCardFace(String text, bool isBack) {
    return Container(
      key: ValueKey(isBack),
      width: min(MediaQuery.of(context).size.width * 0.88, 380),
      height: 380,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isBack ? AppColors.cyan.withValues(alpha: 0.5) : AppColors.accent.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isBack ? AppColors.cyan.withValues(alpha: 0.15) : AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isBack ? "ANSWER" : "QUESTION",
              style: TextStyle(
                color: isBack ? AppColors.cyan : AppColors.accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primaryText, fontSize: 20, fontWeight: FontWeight.w600, height: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceRow(FlashcardProvider provider, List<FlashcardModel> activeList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _confidenceButton("Again", Colors.redAccent, 0, provider, activeList),
          _confidenceButton("Hard", Colors.orangeAccent, 3, provider, activeList),
          _confidenceButton("Good", AppColors.cyan, 4, provider, activeList),
          _confidenceButton("Easy", Colors.greenAccent, 5, provider, activeList),
        ],
      ),
    );
  }

  Widget _confidenceButton(String label, Color color, int quality, FlashcardProvider provider, List<FlashcardModel> activeList) {
    return ElevatedButton(
      onPressed: () => _handleReview(quality, provider, activeList),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
