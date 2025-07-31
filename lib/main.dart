import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'models/canvas_element.dart';
import 'models/user.dart';
import 'widgets/tool_button.dart';
import 'widgets/draw_canvas.dart';
import 'widgets/color_picker.dart';

// Import new advanced features
import 'services/ai_assistant_service.dart';
import 'services/collaboration_service_stub.dart'; // Using stub version
import 'services/mind_map_engine.dart';

void main() {
  runApp(const WhiteVaultApp());
}

class WhiteVaultApp extends StatelessWidget {
  const WhiteVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhiteVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: WhiteCanvasScreen(
        canvasId: 'default',
        currentUser: User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Anonymous User',
          email: 'anonymous@whitevault.com',
          lastSeen: DateTime.now(),
        ),
      ),
    );
  }
}

class WhiteCanvasScreen extends StatefulWidget {
  final String canvasId;
  final User currentUser;

  const WhiteCanvasScreen({
    super.key,
    required this.canvasId,
    required this.currentUser,
  });

  @override
  State<WhiteCanvasScreen> createState() => _WhiteCanvasScreenState();
}

class _WhiteCanvasScreenState extends State<WhiteCanvasScreen> {
  List<CanvasElement> _savedData = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 2.0;
  String _selectedTool = 'pen';
  bool _showTools = false;
  bool _isAIMode = false;
  bool _showCollaboration = false;
  final List<String> _collaborators = [];
  String _selectedBrushType = 'pencil';
  bool _enableGestureRecognition = true;

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
    _initializeCollaboration();
  }

  void _initializeCollaboration() async {
    try {
      await CollaborationService.joinCanvas(widget.canvasId);
    } catch (e) {
      print('Collaboration initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Canvas
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showTools = false),
                child: DrawCanvas(
                  elements: _savedData,
                  selectedColor: _selectedColor,
                  strokeWidth: _strokeWidth,
                  selectedTool: _selectedTool,
                  onElementsChanged: _onCanvasChanged,
                ),
              ),
            ),

            // Collaboration Panel
            if (_showCollaboration)
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                width: 300,
                child: _buildCollaborationPanel(),
              ),

            // AI Insights Panel
            if (_isAIMode)
              Positioned(
                left: 0,
                top: 0,
                bottom: 100,
                width: 300,
                child: _buildAIPanel(),
              ),

            // Enhanced Top Toolbar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: _buildEnhancedTopToolbar(),
            ),

            // Enhanced Tool Menu
            if (_showTools)
              Positioned(
                bottom: 100,
                left: 10,
                right: 10,
                child: _buildEnhancedToolMenu(),
              ),

            // Enhanced Bottom Toolbar
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: _buildEnhancedBottomToolbar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTopToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AI Toggle
          IconButton(
            icon: Icon(
              Icons.psychology,
              color: _isAIMode ? Colors.blue : Colors.grey[600],
            ),
            onPressed: () => setState(() => _isAIMode = !_isAIMode),
            tooltip: 'AI Assistant',
          ),

          // Collaboration Toggle
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.people,
                  color: _showCollaboration ? Colors.green : Colors.grey[600],
                ),
                if (_collaborators.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${_collaborators.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () =>
                setState(() => _showCollaboration = !_showCollaboration),
            tooltip: 'Collaboration',
          ),

          const Spacer(),

          // Color picker button
          GestureDetector(
            onTap: () => _showColorPickerDialog(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Gesture Recognition Toggle
          IconButton(
            icon: Icon(
              Icons.gesture,
              color: _enableGestureRecognition
                  ? Colors.purple
                  : Colors.grey[600],
            ),
            onPressed: () => setState(
              () => _enableGestureRecognition = !_enableGestureRecognition,
            ),
            tooltip: 'Gesture Recognition',
          ),

          // Menu button
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => setState(() => _showTools = !_showTools),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedToolMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Tools Section
          _buildToolSection('AI Tools', [
            ToolButton(
              icon: Icons.lightbulb,
              label: 'Brainstorm',
              onPressed: _showBrainstormDialog,
            ),
            ToolButton(
              icon: Icons.auto_fix_high,
              label: 'Enhance Text',
              onPressed: _enhanceSelectedText,
            ),
            ToolButton(
              icon: Icons.analytics,
              label: 'Analyze Canvas',
              onPressed: _analyzeCanvas,
            ),
            ToolButton(
              icon: Icons.summarize,
              label: 'Generate Summary',
              onPressed: _generateSummary,
            ),
          ]),

          const Divider(height: 24),

          // Templates Section
          _buildToolSection('Smart Templates', [
            ToolButton(
              icon: Icons.account_tree,
              label: 'Mind Map',
              onPressed: _createMindMap,
            ),
            ToolButton(
              icon: Icons.dashboard,
              label: 'SWOT Analysis',
              onPressed: _createSWOTAnalysis,
            ),
            ToolButton(
              icon: Icons.timeline,
              label: 'Project Board',
              onPressed: _createProjectBoard,
            ),
            ToolButton(
              icon: Icons.explore,
              label: 'Template Gallery',
              onPressed: _showTemplateGallery,
            ),
          ]),

          const Divider(height: 24),

          // Drawing Tools Section
          _buildToolSection('Drawing Tools', [
            ToolButton(
              icon: Icons.brush,
              label: 'Pencil',
              onPressed: () => _selectTool('pencil'),
              isSelected: _selectedBrushType == 'pencil',
            ),
            ToolButton(
              icon: Icons.create,
              label: 'Marker',
              onPressed: () => _selectTool('marker'),
              isSelected: _selectedBrushType == 'marker',
            ),
            ToolButton(
              icon: Icons.water_drop,
              label: 'Watercolor',
              onPressed: () => _selectTool('watercolor'),
              isSelected: _selectedBrushType == 'watercolor',
            ),
            ToolButton(
              icon: Icons.scatter_plot,
              label: 'Spray',
              onPressed: () => _selectTool('spray'),
              isSelected: _selectedBrushType == 'spray',
            ),
          ]),

          const Divider(height: 24),

          // Stroke Width
          _buildToolSection('Stroke Width', [
            _buildStrokeButton(1.0),
            _buildStrokeButton(2.0),
            _buildStrokeButton(4.0),
            _buildStrokeButton(8.0),
            _buildStrokeButton(16.0),
          ]),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(double width) {
    return GestureDetector(
      onTap: () => setState(() => _strokeWidth = width),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _strokeWidth == width
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _strokeWidth == width ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Container(
            width: width.clamp(2, 20),
            height: width.clamp(2, 20),
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolSection(String title, List<Widget> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: tools),
      ],
    );
  }

  Widget _buildAIPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _aiActionCard(
                  'Analyze Canvas',
                  'Get insights about your canvas content',
                  Icons.analytics,
                  _analyzeCanvas,
                ),
                _aiActionCard(
                  'Brainstorm Ideas',
                  'Generate creative ideas for your project',
                  Icons.lightbulb,
                  _showBrainstormDialog,
                ),
                _aiActionCard(
                  'Enhance Text',
                  'Improve selected text content',
                  Icons.auto_fix_high,
                  _enhanceSelectedText,
                ),
                _aiActionCard(
                  'Generate Summary',
                  'Create a summary of your canvas',
                  Icons.summarize,
                  _generateSummary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiActionCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCollaborationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Live Collaboration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Active collaborators
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Users',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_collaborators.isEmpty)
                        const Text(
                          'No active collaborators',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ..._collaborators.map((user) => _buildUserTile(user)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                Colors.primaries[userId.hashCode % Colors.primaries.length],
            child: Text(
              userId[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Text(userId),
        ],
      ),
    );
  }

  // Tool Selection Methods
  void _selectTool(String tool) {
    setState(() {
      _selectedBrushType = tool;
      _selectedTool = 'pen'; // Keep the main tool as pen for drawing
    });
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SizedBox(
          width: 300,
          child: ColorPicker(
            selectedColor: _selectedColor,
            onColorSelected: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  // AI Methods
  void _analyzeCanvas() async {
    try {
      final canvasData = _savedData.map((e) => e.toJson()).toList();
      final analysis = await AIAssistantService.analyzeCanvas(canvasData);
      _showDialog('Canvas Analysis', analysis.toString());
    } catch (e) {
      _showError('Failed to analyze canvas: $e');
    }
  }

  void _showBrainstormDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Brainstorming'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter a topic to brainstorm...',
              ),
              onSubmitted: (topic) async {
                Navigator.pop(context);
                try {
                  final ideas =
                      await AIAssistantService.generateBrainstormingIdeas(
                        topic,
                      );
                  _showDialog('Brainstorming Ideas', ideas.join('\n\n'));
                } catch (e) {
                  _showError('Failed to generate ideas: $e');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _enhanceSelectedText() async {
    _showError('Select text to enhance (feature coming soon)');
  }

  void _generateSummary() async {
    try {
      final canvasData = _savedData.map((e) => e.toJson()).toList();
      final summary = await AIAssistantService.generateMeetingSummary(
        canvasData,
      );
      _showDialog('Canvas Summary', summary);
    } catch (e) {
      _showError('Failed to generate summary: $e');
    }
  }

  // Template Methods
  void _createMindMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Mind Map'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Enter central topic...'),
          onSubmitted: (topic) {
            Navigator.pop(context);
            try {
              final mindMapNodes = MindMapEngine.generateMindMap(topic, [
                'Idea 1',
                'Idea 2',
                'Idea 3',
              ]);
              // Convert mind map nodes to canvas elements
              final elements = _convertMindMapToCanvas(mindMapNodes, topic);
              setState(() {
                _savedData.addAll(elements);
              });
              _saveToPrefs();
            } catch (e) {
              _showError('Failed to create mind map: $e');
            }
          },
        ),
      ),
    );
  }

  List<CanvasElement> _convertMindMapToCanvas(
    List<dynamic> nodes,
    String topic,
  ) {
    final elements = <CanvasElement>[];

    // Add central topic
    elements.add(
      CanvasElement.createText(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: topic,
        position: const Offset(200, 200),
        color: Colors.blue,
        fontSize: 24,
        userId: widget.currentUser.id,
      ),
    );

    // Add surrounding ideas
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * 3.14159) / 3;
      final x = 200 + 100 * math.cos(angle);
      final y = 200 + 100 * math.sin(angle);

      elements.add(
        CanvasElement.createText(
          id: (DateTime.now().millisecondsSinceEpoch + i).toString(),
          text: 'Idea ${i + 1}',
          position: Offset(x, y),
          color: Colors.green,
          fontSize: 16,
          userId: widget.currentUser.id,
        ),
      );
    }

    return elements;
  }

  void _createSWOTAnalysis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SWOT Analysis'),
        content: const Text('Creating SWOT Analysis template...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              try {
                final swotTemplate = MindMapEngine.generateSWOTAnalysis();
                final elements = _convertTemplateToCanvas(swotTemplate);
                setState(() {
                  _savedData.addAll(elements);
                });
                _saveToPrefs();
              } catch (e) {
                _showError('Failed to create SWOT analysis: $e');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createProjectBoard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Planning Board'),
        content: const Text('Creating project planning template...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              try {
                final projectTemplate =
                    MindMapEngine.generateProjectPlanningBoard();
                final elements = _convertTemplateToCanvas(projectTemplate);
                setState(() {
                  _savedData.addAll(elements);
                });
                _saveToPrefs();
              } catch (e) {
                _showError('Failed to create project board: $e');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  List<CanvasElement> _convertTemplateToCanvas(dynamic template) {
    final elements = <CanvasElement>[];

    // Create basic template elements
    final positions = [
      const Offset(100, 100),
      const Offset(300, 100),
      const Offset(100, 300),
      const Offset(300, 300),
    ];

    final labels = ['Strengths', 'Weaknesses', 'Opportunities', 'Threats'];
    final colors = [Colors.green, Colors.red, Colors.blue, Colors.orange];

    for (int i = 0; i < 4; i++) {
      elements.add(
        CanvasElement.createStickyNote(
          id: (DateTime.now().millisecondsSinceEpoch + i).toString(),
          text: labels[i],
          position: positions[i],
          backgroundColor: colors[i].withValues(alpha: 0.3),
          userId: widget.currentUser.id,
        ),
      );
    }

    return elements;
  }

  void _showTemplateGallery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Template Gallery'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              _templateTile('Mind Map', 'Organize ideas visually', () {
                Navigator.pop(context);
                _createMindMap();
              }),
              _templateTile(
                'SWOT Analysis',
                'Analyze strengths and weaknesses',
                () {
                  Navigator.pop(context);
                  _createSWOTAnalysis();
                },
              ),
              _templateTile('Project Board', 'Plan your project phases', () {
                Navigator.pop(context);
                _createProjectBoard();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _templateTile(String title, String description, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  // Utility Methods
  void _onCanvasChanged(List<CanvasElement> elements) {
    setState(() {
      _savedData = elements;
    });
    _saveToPrefs();
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildEnhancedBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomToolButton(Icons.undo, _undo),
          _bottomToolButton(Icons.redo, _redo),
          _bottomToolButton(Icons.clear, _clearCanvas),
          _bottomToolButton(Icons.save, _saveToPrefs),
          _bottomToolButton(Icons.share, _shareCanvas),
        ],
      ),
    );
  }

  Widget _bottomToolButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: icon.toString().split('.').last,
    );
  }

  // Existing methods (undo, redo, clear, save, etc.)
  void _undo() {
    if (_savedData.isNotEmpty) {
      setState(() {
        _savedData.removeLast();
      });
      _saveToPrefs();
    }
  }

  void _redo() {
    // Implementation for redo (requires undo/redo stack)
    _showError('Redo not implemented yet');
  }

  void _clearCanvas() {
    setState(() {
      _savedData.clear();
    });
    _saveToPrefs();
  }

  void _shareCanvas() {
    _showError('Share feature coming soon');
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = _savedData.map((e) => e.toJson()).toList();
    await prefs.setString('canvas_data', json.encode(jsonData));
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('canvas_data');
    if (savedData != null) {
      try {
        final jsonData = json.decode(savedData) as List;
        setState(() {
          _savedData = jsonData.map((e) => CanvasElement.fromJson(e)).toList();
        });
      } catch (e) {
        print('Error loading saved data: $e');
      }
    }
  }

  @override
  void dispose() {
    try {
      CollaborationService.leaveCanvas();
    } catch (e) {
      print('Error leaving canvas: $e');
    }
    super.dispose();
  }
}
