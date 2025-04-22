import 'package:flutter/material.dart';
import 'package:flutter_survey/flutter_survey.dart';




class ChallengeCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Question> questions;
  final Map<String, bool> correctAnswers;

  const ChallengeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.questions,
    required this.correctAnswers,
  });
}


class ChallengeResult {
  final int score;
  final int totalQuestions;
  final double percentage;
  final String message;
  final Color color;
  final String feedback;
  final bool isPassing;

  const ChallengeResult({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.message,
    required this.color,
    required this.feedback,
    required this.isPassing,
  });

  factory ChallengeResult.calculate(
    List<QuestionResult> results,
    Map<String, bool> correctAnswers,
  ) {
    int score = 0;

    for (final result in results) {
      for (final answer in result.answers) {
        if (correctAnswers[answer] == true) {
          score++;
          break;
        }
      }
    }

    final totalQuestions = results.length;
    final double percentage =
        totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

    Color resultColor;
    String message;
    String feedback;

    if (percentage >= 90) {
      resultColor = Colors.green;
      message = 'Outstanding!';
      feedback = 'You\'ve mastered this level';
    } else if (percentage >= 70) {
      resultColor = Colors.green;
      message = 'Great job!';
      feedback = 'You\'ve mastered this level';
    } else if (percentage >= 50) {
      resultColor = Colors.orange;
      message = 'Good effort!';
      feedback = 'Review the questions to improve';
    } else if (percentage >= 30) {
      resultColor = Colors.orange;
      message = 'Keep practicing!';
      feedback = 'Review the questions to improve';
    } else {
      resultColor = Colors.red;
      message = 'Don\'t give up!';
      feedback = 'Review the questions to improve';
    }

    return ChallengeResult(
      score: score,
      totalQuestions: totalQuestions,
      percentage: percentage,
      message: message,
      color: resultColor,
      feedback: feedback,
      isPassing: percentage >= 70,
    );
  }
}




class ChallengeDataProvider {
  static List<ChallengeCategory> getChallengeCategories(BuildContext context) {
    return [
      ChallengeCategory(
        id: 'beginner',
        name: 'Beginner',
        icon: Icons.school_outlined,
        color: Colors.green,
        questions: [
          Question(
            question:
                'Network Problem\nA --10--> B --15--> E\n...\nShortest path from A to E?',
            isMandatory: true,
            answerChoices: {
              'A → B → E (25ms)': null,
              'A → C → D → E (45ms)': null,
            },
          ),
          Question(
            question:
                'Tree Traversal\nGiven a binary tree...\nWhat is the result of an in-order traversal?',
            isMandatory: true,
            answerChoices: {
              '[1, 3, 5, 7, 9]': null,
              '[5, 3, 1, 9, 7]': null,
              '[1, 3, 7, 9, 5]': null,
            },
          ),
        ],
        correctAnswers: {
          'A → B → E (25ms)': true,
          'A → C → D → E (45ms)': false,
          '[1, 3, 5, 7, 9]': true,
          '[5, 3, 1, 9, 7]': false,
          '[1, 3, 7, 9, 5]': false,
        },
      ),
      ChallengeCategory(
        id: 'intermediate',
        name: 'Intermediate',
        icon: Icons.trending_up,
        color: Colors.orange,
        questions: [
          Question(
            question:
                'City Navigation\nA → B: 50km ×1.2...\nOptimal path from A to E?',
            isMandatory: true,
            answerChoices: {
              'A → B → E (110km)': null,
              'A → C → E (100km)': null,
            },
          ),
          Question(
            question:
                'Dynamic Programming\nYou need to climb n steps...\nHow many distinct ways can you climb 5 steps?',
            isMandatory: true,
            answerChoices: {'8 ways': null, '5 ways': null, '13 ways': null},
          ),
        ],
        correctAnswers: {
          'A → B → E (110km)': false,
          'A → C → E (100km)': true,
          '8 ways': true,
          '5 ways': false,
          '13 ways': false,
        },
      ),
      ChallengeCategory(
        id: 'advanced',
        name: 'Advanced',
        icon: Icons.psychology,
        color: Colors.red,
        questions: [
          Question(
            question:
                'Graph Algorithm\nGiven a directed graph with cycles...\nWhat is the time complexity of the Bellman-Ford algorithm?',
            isMandatory: true,
            answerChoices: {'O(V×E)': null, 'O(V+E)': null, 'O(V²)': null},
          ),
          Question(
            question:
                'Divide and Conquer\nConsider an algorithm that...\nWhat is the solution to the recurrence T(n) = 2T(n/2) + n?',
            isMandatory: true,
            answerChoices: {'O(n log n)': null, 'O(n²)': null, 'O(n)': null},
          ),
        ],
        correctAnswers: {
          'O(V×E)': true,
          'O(V+E)': false,
          'O(V²)': false,
          'O(n log n)': true,
          'O(n²)': false,
          'O(n)': false,
        },
      ),
    ];
  }
}



class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  
  String? _selectedCategoryId;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<QuestionResult> _questionResults = [];
  late List<ChallengeCategory> _categories;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _resetCounter = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _categories = ChallengeDataProvider.getChallengeCategories(context);
  }

  
  ChallengeCategory? get _selectedCategory {
    if (_selectedCategoryId == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      return null;
    }
  }

  
  void _resetSurvey() {
    setState(() {
      _questionResults = [];
      
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            if (_selectedCategory != null) _buildCategorySelectorSection(),
            Expanded(
              child:
                  _selectedCategory != null
                      ? _buildChallengeContent()
                      : _buildWelcomeContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _selectedCategory != null ? _buildSubmitButton() : null,
    );
  }

  

  Widget _buildCategorySelectorSection() {
    final category = _selectedCategory!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: _buildCategorySelector(),
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              return _buildCategoryItem(category, isSelected);
            }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(ChallengeCategory category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          if (_selectedCategory?.id != category.id) {
            setState(() {
              _selectedCategoryId = category.id;
              _questionResults = [];
              _resetCounter = 0; 
            });
            _animationController.reset();
            _animationController.forward();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? category.color.withOpacity(0.15)
                    : Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? category.color : Colors.transparent,
              width: 2,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: category.color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Icon(
                category.icon,
                color:
                    isSelected
                        ? category.color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? category.color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Test Your Algorithm Knowledge',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a difficulty level to start the challenge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              ..._categories.map((category) => _buildCategoryCard(category)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ChallengeCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: category.color.withOpacity(0.3), width: 1),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryId = category.id;
              _questionResults = [];
              _resetCounter = 0; 
            });
            _animationController.reset();
            _animationController.forward();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: category.color.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeContent() {
    final category = _selectedCategory!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Survey(
                      
                      key: ValueKey('${category.id}_${_resetCounter}'),
                      initialData: category.questions,
                      onNext: (results) {
                        setState(() {
                          _questionResults = results;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final category = _selectedCategory!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _evaluateAndShowResults();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: category.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Submit Answers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  

  void _evaluateAndShowResults() {
    final category = _selectedCategory!;
    final result = ChallengeResult.calculate(
      _questionResults,
      category.correctAnswers,
    );

    _showResultsDialog(category, result);
  }

  void _showResultsDialog(ChallengeCategory category, ChallengeResult result) {
    showDialog(
      context: context,
      
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResultHeader(result),
                _buildResultDetails(category, result),
                _buildResultActions(result),
              ],
            ),
          ),
    );
  }

  Widget _buildResultHeader(ChallengeResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: result.color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildProgressIndicator(result),
          const SizedBox(height: 24),
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ChallengeResult result) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end:
            result.totalQuestions > 0
                ? result.score / result.totalQuestions
                : 0,
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(result.color),
              ),
            ),
            Column(
              children: [
                Text(
                  '${result.score}/${result.totalQuestions}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: result.color,
                  ),
                ),
                Text(
                  'score',
                  style: TextStyle(color: result.color.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultDetails(
    ChallengeCategory category,
    ChallengeResult result,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text('Level: ${category.name}'),
            subtitle: const Text('Algorithm Challenges'),
            dense: true,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              result.isPassing ? Icons.emoji_events : Icons.lightbulb_outline,
              color: result.color,
            ),
            title: Text(
              result.isPassing ? 'Great performance!' : 'Learning opportunity',
              style: TextStyle(
                color: result.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(result.feedback),
            dense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultActions(ChallengeResult result) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                
                Navigator.of(context).pop();
                
                setState(() {
                  _selectedCategoryId = null;
                  _questionResults = [];
                });
                _animationController.reset();
                _animationController.forward();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Another'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                
                Navigator.of(context).pop();
                
                _handleNextAction(result);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    result.isPassing
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(result.isPassing ? 'Next Level' : 'Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextAction(ChallengeResult result) {
    if (result.isPassing) {
      
      final categoryIds = _categories.map((c) => c.id).toList();
      final currentIndex = categoryIds.indexOf(_selectedCategoryId!);
      if (currentIndex < categoryIds.length - 1) {
        setState(() {
          _selectedCategoryId = categoryIds[currentIndex + 1];
          _questionResults = [];
          _resetCounter = 0; 
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        
        _showCompletionDialog();
      }
    } else {
      
      setState(() {
        _questionResults = [];
        _resetCounter++; 
        _formKey = GlobalKey<FormState>(); 
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '🎉 Congratulations!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You\'ve completed all algorithm challenges.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedCategoryId = null;
                      _questionResults = [];
                      _resetCounter =
                          0; 
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
    );
  }
}
