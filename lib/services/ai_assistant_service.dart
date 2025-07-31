// AI Assistant Service - Making WhiteVault Truly Unique
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AIAssistantService {
  static const String _openAIKey = 'YOUR_OPENAI_API_KEY'; // Add your key
  static const String _openAIUrl = 'https://api.openai.com/v1/chat/completions';

  // 🧠 AI-POWERED IDEA GENERATION
  static Future<List<String>> generateBrainstormingIdeas(String topic) async {
    final prompt =
        '''
    Generate 10 creative brainstorming ideas for the topic: "$topic"
    Focus on innovative, actionable, and diverse approaches.
    Return as a numbered list.
    ''';

    final response = await _callOpenAI(prompt);
    return response
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  // 🎨 AI CANVAS OPTIMIZATION
  static Future<Map<String, dynamic>> analyzeCanvas(
    List<Map<String, dynamic>> canvasElements,
  ) async {
    final prompt =
        '''
    Analyze this whiteboard canvas and provide optimization suggestions:
    Elements: ${canvasElements.length}
    Types: ${canvasElements.map((e) => e['type']).toSet().join(', ')}
    
    Provide:
    1. Layout optimization suggestions
    2. Color scheme recommendations
    3. Missing element suggestions
    4. Organization improvements
    ''';

    final response = await _callOpenAI(prompt);
    return {
      'suggestions': response,
      'score': _calculateCanvasScore(canvasElements),
      'improvements': _generateImprovements(canvasElements),
    };
  }

  // 📝 SMART TEXT ENHANCEMENT
  static Future<String> enhanceText(
    String originalText,
    String enhancement,
  ) async {
    final prompt =
        '''
    Enhance this text for $enhancement:
    Original: "$originalText"
    
    Make it more engaging, clear, and professional while maintaining the core message.
    ''';

    return await _callOpenAI(prompt);
  }

  // 🔗 AI CONNECTION SUGGESTIONS
  static Future<List<Map<String, dynamic>>> suggestConnections(
    List<Map<String, dynamic>> elements,
  ) async {
    final prompt =
        '''
    Analyze these whiteboard elements and suggest logical connections:
    ${elements.map((e) => '${e['type']}: ${e['properties']['content'] ?? e['type']}')}
    
    Suggest which elements should be connected and why.
    ''';

    final response = await _callOpenAI(prompt);
    return _parseConnectionSuggestions(response, elements);
  }

  // 🎯 MEETING SUMMARY GENERATION
  static Future<String> generateMeetingSummary(
    List<Map<String, dynamic>> canvasElements,
  ) async {
    final content = canvasElements
        .where((e) => e['properties']['content'] != null)
        .map((e) => e['properties']['content'])
        .join(' ');

    final prompt =
        '''
    Create a professional meeting summary from this whiteboard content:
    "$content"
    
    Include:
    - Key discussion points
    - Action items
    - Decisions made
    - Next steps
    ''';

    return await _callOpenAI(prompt);
  }

  // Private helper methods
  static Future<String> _callOpenAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {
          'Authorization': 'Bearer $_openAIKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      return 'AI service temporarily unavailable';
    } catch (e) {
      return 'Error generating AI response: $e';
    }
  }

  static int _calculateCanvasScore(List<Map<String, dynamic>> elements) {
    int score = 0;
    score += elements.length * 10; // Points for content
    score +=
        elements.where((e) => e['type'] == 'connection').length *
        20; // Bonus for connections
    score +=
        elements.map((e) => e['type']).toSet().length * 15; // Variety bonus
    return score.clamp(0, 100);
  }

  static List<String> _generateImprovements(
    List<Map<String, dynamic>> elements,
  ) {
    List<String> improvements = [];

    if (elements.length < 3) improvements.add('Add more content elements');
    if (elements.where((e) => e['type'] == 'connection').isEmpty) {
      improvements.add('Consider connecting related ideas');
    }
    if (elements.map((e) => e['type']).toSet().length < 3) {
      improvements.add('Try different element types for variety');
    }

    return improvements;
  }

  static List<Map<String, dynamic>> _parseConnectionSuggestions(
    String response,
    List<Map<String, dynamic>> elements,
  ) {
    // Parse AI response and return connection suggestions
    // This would need more sophisticated parsing in a real implementation
    return [];
  }
}

// AI-powered Widget for Canvas Analysis
class AICanvasInsights extends StatefulWidget {
  final List<Map<String, dynamic>> canvasElements;

  const AICanvasInsights({super.key, required this.canvasElements});

  @override
  State<AICanvasInsights> createState() => _AICanvasInsightsState();
}

class _AICanvasInsightsState extends State<AICanvasInsights> {
  Map<String, dynamic>? _analysis;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'AI Canvas Insights',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _analyzeCanvas,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_analysis != null) ...[
              Text('Canvas Score: ${_analysis!['score']}/100'),
              const SizedBox(height: 8),
              Text(_analysis!['suggestions'] ?? 'No suggestions available'),
              const SizedBox(height: 8),
              ...(_analysis!['improvements'] as List<String>).map(
                (improvement) => Chip(label: Text(improvement)),
              ),
            ] else
              const Text('Tap refresh to get AI insights about your canvas'),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeCanvas() async {
    setState(() => _isLoading = true);
    try {
      final analysis = await AIAssistantService.analyzeCanvas(
        widget.canvasElements,
      );
      if (mounted) {
        setState(() => _analysis = analysis);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error analyzing canvas: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
