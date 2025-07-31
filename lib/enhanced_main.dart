import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/canvas_element.dart';
import 'models/user.dart';
import 'widgets/draw_canvas.dart';

// Import new advanced features
import 'services/ai_assistant_service.dart';
import 'services/collaboration_service_stub.dart'; // Using stub version
import 'services/mind_map_engine.dart';

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
  final Color _selectedColor = Colors.black;
  final double _strokeWidth = 2.0;
  String _selectedTool = 'pen';
  bool _showTools = false;
  bool _isAIMode = false;
  bool _showCollaboration = false;
  final List<String> _collaborators = [];

  // Advanced features - using static methods for now
  bool _enableGestureRecognition = true;

  // Stub variables for missing features
  dynamic _selectedEffect;
  final dynamic _aiService = AIAssistantService();
  final dynamic _mindMapEngine = MindMapEngine();

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
    _initializeCollaboration();
  }

  void _initializeCollaboration() async {
    try {
      // Initialize collaboration using static methods
      await CollaborationService.joinCanvas(widget.canvasId);
      // For now, we'll simulate collaboration updates
      // In the future, you can implement real-time streams
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
            // Main Canvas - simplified for compatibility
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
            _toolButton(Icons.lightbulb, 'Brainstorm', _showBrainstormDialog),
            _toolButton(
              Icons.auto_fix_high,
              'Enhance Text',
              _enhanceSelectedText,
            ),
            _toolButton(Icons.analytics, 'Analyze Canvas', _analyzeCanvas),
            _toolButton(Icons.summarize, 'Generate Summary', _generateSummary),
          ]),

          const Divider(height: 24),

          // Templates Section
          _buildToolSection('Smart Templates', [
            _toolButton(Icons.account_tree, 'Mind Map', _createMindMap),
            _toolButton(Icons.dashboard, 'SWOT Analysis', _createSWOTAnalysis),
            _toolButton(Icons.timeline, 'Project Board', _createProjectBoard),
            _toolButton(
              Icons.explore,
              'Template Gallery',
              _showTemplateGallery,
            ),
          ]),

          const Divider(height: 24),

          // Drawing Tools Section
          _buildToolSection('Drawing Tools', [
            _toolButton(Icons.brush, 'Pencil', () => _selectTool('pencil')),
            _toolButton(Icons.create, 'Marker', () => _selectTool('marker')),
            _toolButton(
              Icons.water_drop,
              'Watercolor',
              () => _selectTool('watercolor'),
            ),
            _toolButton(
              Icons.scatter_plot,
              'Spray',
              () => _selectTool('spray'),
            ),
            _toolButton(
              Icons.font_download,
              'Calligraphy',
              () => _selectTool('calligraphy'),
            ),
            _toolButton(Icons.lightbulb, 'Neon', () => _selectTool('neon')),
          ]),

          const Divider(height: 24),

          // Effects Section
          _buildToolSection('Effects', [
            _toolButton(
              Icons.auto_awesome,
              'Glow',
              () => _toggleEffect('glow'),
            ),
            _toolButton(
              Icons.format_color_fill,
              'Shadow',
              () => _toggleEffect('shadow'),
            ),
            _toolButton(Icons.blur_on, 'Blur', () => _toggleEffect('blur')),
            _toolButton(
              Icons.gradient,
              'Rainbow',
              () => _toggleEffect('rainbow'),
            ),
          ]),
        ],
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
                      ..._collaborators.map((user) => _buildUserTile(user)),
                    ],
                  ),
                ),

                // Comments section
                const Divider(),
                Expanded(
                  child: StreamBuilder<List<CollabComment>>(
                    stream: CollaborationService.commentsStream,
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentTile(comments[index]);
                        },
                      );
                    },
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

  Widget _buildCommentTile(CollabComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.userId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  comment.timestamp.toString().substring(11, 16),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.text),
          ],
        ),
      ),
    );
  }

  // AI Methods
  void _analyzeCanvas() async {
    try {
      final analysis = await _aiService.analyzeCanvas(_savedData);
      _showDialog('Canvas Analysis', analysis);
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
                  final ideas = await _aiService.generateBrainstormingIdeas(
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
    // Implementation for enhancing selected text
    _showError('Please select text to enhance');
  }

  void _generateSummary() async {
    try {
      final summary = await _aiService.generateMeetingSummary(_savedData);
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
            final mindMapElements = _mindMapEngine.generateMindMap(topic);
            setState(() {
              _savedData.addAll(mindMapElements);
            });
            _saveToPrefs();
          },
        ),
      ),
    );
  }

  void _createSWOTAnalysis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SWOT Analysis'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter project/company name...',
          ),
          onSubmitted: (name) {
            Navigator.pop(context);
            final swotElements = _mindMapEngine.generateSWOTAnalysis(name);
            setState(() {
              _savedData.addAll(swotElements);
            });
            _saveToPrefs();
          },
        ),
      ),
    );
  }

  void _createProjectBoard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Planning Board'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Enter project name...'),
          onSubmitted: (name) {
            Navigator.pop(context);
            final projectElements = _mindMapEngine.generateProjectPlanningBoard(
              name,
            );
            setState(() {
              _savedData.addAll(projectElements);
            });
            _saveToPrefs();
          },
        ),
      ),
    );
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
              _templateTile('Flowchart', 'Map processes and workflows', () {
                Navigator.pop(context);
                // Add flowchart creation
              }),
              _templateTile('Kanban Board', 'Track task progress', () {
                Navigator.pop(context);
                // Add Kanban board creation
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

    // Update collaboration service
    CollaborationService.updateCanvas(elements);
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

  Widget _toolButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
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
    // Implementation for undo
  }

  void _redo() {
    // Implementation for redo
  }

  void _clearCanvas() {
    setState(() {
      _savedData.clear();
    });
    _saveToPrefs();
  }

  void _shareCanvas() {
    // Implementation for sharing
  }

  void _saveToPrefs() async {
    // Your existing save implementation
    final prefs = await SharedPreferences.getInstance();
    final jsonData = _savedData.map((e) => e.toJson()).toList();
    await prefs.setString('canvas_data', json.encode(jsonData));
  }

  void _loadFromPrefs() async {
    // Your existing load implementation
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('canvas_data');
    if (savedData != null) {
      final jsonData = json.decode(savedData) as List;
      setState(() {
        _savedData = jsonData.map((e) => CanvasElement.fromJson(e)).toList();
      });
    }
  }

  @override
  void dispose() {
    CollaborationService.leaveCanvas();
    super.dispose();
  }

  // Missing method implementations
  void _selectTool(String tool) {
    setState(() {
      _selectedTool = tool;
    });
  }

  void _toggleEffect(String effect) {
    setState(() {
      _selectedEffect = _selectedEffect == effect ? null : effect;
    });
  }
}
