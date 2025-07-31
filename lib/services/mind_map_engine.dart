// Mind Mapping & Smart Templates - Making WhiteVault a Thinking Tool
import 'dart:math';
import 'package:flutter/material.dart';

class MindMapEngine {
  // 🧠 INTELLIGENT MIND MAP GENERATION
  static List<MindMapNode> generateMindMap(
    String centralTopic,
    List<String> subtopics,
  ) {
    final nodes = <MindMapNode>[];

    // Create central node
    final centralNode = MindMapNode(
      id: 'central',
      text: centralTopic,
      position: const Offset(400, 300),
      level: 0,
      color: Colors.blue,
      size: 80,
    );
    nodes.add(centralNode);

    // Generate subtopic nodes in circular pattern
    final angleStep = (2 * pi) / subtopics.length;
    for (int i = 0; i < subtopics.length; i++) {
      final angle = i * angleStep;
      const distance = 150.0;
      final x = centralNode.position.dx + cos(angle) * distance;
      final y = centralNode.position.dy + sin(angle) * distance;

      final subtopicNode = MindMapNode(
        id: 'subtopic_$i',
        text: subtopics[i],
        position: Offset(x, y),
        level: 1,
        color: _getColorForLevel(1),
        size: 60,
        parentId: centralNode.id,
      );
      nodes.add(subtopicNode);
    }

    return nodes;
  }

  // 📊 FLOWCHART GENERATION
  static List<FlowchartNode> generateFlowchart(List<String> steps) {
    final nodes = <FlowchartNode>[];
    const startY = 100.0;
    const stepHeight = 120.0;
    const nodeWidth = 200.0;
    const nodeHeight = 60.0;

    for (int i = 0; i < steps.length; i++) {
      final nodeType = _determineNodeType(steps[i], i, steps.length);
      final node = FlowchartNode(
        id: 'step_$i',
        text: steps[i],
        position: Offset(400 - nodeWidth / 2, startY + i * stepHeight),
        size: const Size(nodeWidth, nodeHeight),
        type: nodeType,
        color: _getColorForNodeType(nodeType),
      );
      nodes.add(node);
    }

    return nodes;
  }

  // 🎯 STRATEGIC FRAMEWORKS
  static CanvasTemplate generateSWOTAnalysis() {
    return CanvasTemplate(
      name: 'SWOT Analysis',
      description:
          'Strengths, Weaknesses, Opportunities, Threats analysis framework',
      elements: [
        // Title
        TemplateElement(
          type: 'text',
          position: const Offset(400, 50),
          size: const Size(300, 50),
          properties: {
            'content': 'SWOT Analysis',
            'fontSize': 24.0,
            'fontWeight': 'bold',
            'alignment': 'center',
          },
        ),

        // Strengths Quadrant
        TemplateElement(
          type: 'container',
          position: const Offset(100, 100),
          size: const Size(250, 200),
          properties: {
            'backgroundColor': 0xFF4CAF50,
            'borderRadius': 12.0,
            'opacity': 0.2,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(120, 120),
          size: const Size(200, 30),
          properties: {
            'content': 'STRENGTHS',
            'fontSize': 18.0,
            'fontWeight': 'bold',
            'color': 0xFF2E7D32,
          },
        ),

        // Weaknesses Quadrant
        TemplateElement(
          type: 'container',
          position: const Offset(450, 100),
          size: const Size(250, 200),
          properties: {
            'backgroundColor': 0xFFF44336,
            'borderRadius': 12.0,
            'opacity': 0.2,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(470, 120),
          size: const Size(200, 30),
          properties: {
            'content': 'WEAKNESSES',
            'fontSize': 18.0,
            'fontWeight': 'bold',
            'color': 0xFFC62828,
          },
        ),

        // Opportunities Quadrant
        TemplateElement(
          type: 'container',
          position: const Offset(100, 350),
          size: const Size(250, 200),
          properties: {
            'backgroundColor': 0xFF2196F3,
            'borderRadius': 12.0,
            'opacity': 0.2,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(120, 370),
          size: const Size(200, 30),
          properties: {
            'content': 'OPPORTUNITIES',
            'fontSize': 18.0,
            'fontWeight': 'bold',
            'color': 0xFF1565C0,
          },
        ),

        // Threats Quadrant
        TemplateElement(
          type: 'container',
          position: const Offset(450, 350),
          size: const Size(250, 200),
          properties: {
            'backgroundColor': 0xFFFF9800,
            'borderRadius': 12.0,
            'opacity': 0.2,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(470, 370),
          size: const Size(200, 30),
          properties: {
            'content': 'THREATS',
            'fontSize': 18.0,
            'fontWeight': 'bold',
            'color': 0xFFE65100,
          },
        ),
      ],
    );
  }

  // 📋 PROJECT PLANNING TEMPLATE
  static CanvasTemplate generateProjectPlanningBoard() {
    return CanvasTemplate(
      name: 'Project Planning Board',
      description: 'Comprehensive project planning with phases and milestones',
      elements: [
        // Header
        TemplateElement(
          type: 'text',
          position: const Offset(400, 30),
          size: const Size(400, 40),
          properties: {
            'content': 'Project Planning Board',
            'fontSize': 24.0,
            'fontWeight': 'bold',
            'alignment': 'center',
          },
        ),

        // Planning Phase
        TemplateElement(
          type: 'container',
          position: const Offset(50, 100),
          size: const Size(200, 400),
          properties: {
            'backgroundColor': 0xFFE3F2FD,
            'borderRadius': 8.0,
            'borderColor': 0xFF2196F3,
            'borderWidth': 2.0,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(70, 120),
          size: const Size(160, 30),
          properties: {
            'content': 'PLANNING',
            'fontSize': 16.0,
            'fontWeight': 'bold',
            'color': 0xFF1976D2,
            'alignment': 'center',
          },
        ),

        // Execution Phase
        TemplateElement(
          type: 'container',
          position: const Offset(300, 100),
          size: const Size(200, 400),
          properties: {
            'backgroundColor': 0xFFFFF3E0,
            'borderRadius': 8.0,
            'borderColor': 0xFFFF9800,
            'borderWidth': 2.0,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(320, 120),
          size: const Size(160, 30),
          properties: {
            'content': 'EXECUTION',
            'fontSize': 16.0,
            'fontWeight': 'bold',
            'color': 0xFFF57C00,
            'alignment': 'center',
          },
        ),

        // Review Phase
        TemplateElement(
          type: 'container',
          position: const Offset(550, 100),
          size: const Size(200, 400),
          properties: {
            'backgroundColor': 0xFFE8F5E8,
            'borderRadius': 8.0,
            'borderColor': 0xFF4CAF50,
            'borderWidth': 2.0,
          },
        ),
        TemplateElement(
          type: 'text',
          position: const Offset(570, 120),
          size: const Size(160, 30),
          properties: {
            'content': 'REVIEW',
            'fontSize': 16.0,
            'fontWeight': 'bold',
            'color': 0xFF388E3C,
            'alignment': 'center',
          },
        ),
      ],
    );
  }

  // Helper methods
  static Color _getColorForLevel(int level) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[level % colors.length];
  }

  static FlowchartNodeType _determineNodeType(
    String step,
    int index,
    int total,
  ) {
    if (index == 0) return FlowchartNodeType.start;
    if (index == total - 1) return FlowchartNodeType.end;
    if (step.toLowerCase().contains('decision') || step.contains('?')) {
      return FlowchartNodeType.decision;
    }
    return FlowchartNodeType.process;
  }

  static Color _getColorForNodeType(FlowchartNodeType type) {
    switch (type) {
      case FlowchartNodeType.start:
        return Colors.green;
      case FlowchartNodeType.process:
        return Colors.blue;
      case FlowchartNodeType.decision:
        return Colors.orange;
      case FlowchartNodeType.end:
        return Colors.red;
    }
  }
}

// Data Models
class MindMapNode {
  final String id;
  final String text;
  final Offset position;
  final int level;
  final Color color;
  final double size;
  final String? parentId;

  MindMapNode({
    required this.id,
    required this.text,
    required this.position,
    required this.level,
    required this.color,
    required this.size,
    this.parentId,
  });
}

class FlowchartNode {
  final String id;
  final String text;
  final Offset position;
  final Size size;
  final FlowchartNodeType type;
  final Color color;

  FlowchartNode({
    required this.id,
    required this.text,
    required this.position,
    required this.size,
    required this.type,
    required this.color,
  });
}

enum FlowchartNodeType { start, process, decision, end }

class CanvasTemplate {
  final String name;
  final String description;
  final List<TemplateElement> elements;
  final String? thumbnail;

  CanvasTemplate({
    required this.name,
    required this.description,
    required this.elements,
    this.thumbnail,
  });
}

class TemplateElement {
  final String type;
  final Offset position;
  final Size size;
  final Map<String, dynamic> properties;

  TemplateElement({
    required this.type,
    required this.position,
    required this.size,
    required this.properties,
  });
}

// Template Gallery Widget
class TemplateGallery extends StatefulWidget {
  final Function(CanvasTemplate) onTemplateSelected;

  const TemplateGallery({super.key, required this.onTemplateSelected});

  @override
  State<TemplateGallery> createState() => _TemplateGalleryState();
}

class _TemplateGalleryState extends State<TemplateGallery> {
  final List<CanvasTemplate> _templates = [
    MindMapEngine.generateSWOTAnalysis(),
    MindMapEngine.generateProjectPlanningBoard(),
    // Add more templates here
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Business',
    'Education',
    'Creative',
    'Planning',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.dashboard, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Template Gallery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Templates Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _buildTemplateCard(template);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(CanvasTemplate template) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => widget.onTemplateSelected(template),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: template.thumbnail != null
                    ? Image.asset(template.thumbnail!, fit: BoxFit.cover)
                    : const Icon(Icons.dashboard, size: 48, color: Colors.grey),
              ),
            ),

            // Template Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Smart Mind Map Widget
class SmartMindMapWidget extends StatefulWidget {
  final String centralTopic;
  final List<MindMapNode> nodes;
  final Function(List<MindMapNode>)? onNodesChanged;

  const SmartMindMapWidget({
    super.key,
    required this.centralTopic,
    required this.nodes,
    this.onNodesChanged,
  });

  @override
  State<SmartMindMapWidget> createState() => _SmartMindMapWidgetState();
}

class _SmartMindMapWidgetState extends State<SmartMindMapWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: MindMapPainter(widget.nodes),
        child: Stack(
          children: widget.nodes.map((node) => _buildNodeWidget(node)).toList(),
        ),
      ),
    );
  }

  Widget _buildNodeWidget(MindMapNode node) {
    return Positioned(
      left: node.position.dx - node.size / 2,
      top: node.position.dy - node.size / 2,
      child: GestureDetector(
        onPanUpdate: (details) => _updateNodePosition(node, details.delta),
        child: Container(
          width: node.size,
          height: node.size,
          decoration: BoxDecoration(
            color: node.color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: node.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: node.color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              node.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _updateNodePosition(MindMapNode node, Offset delta) {
    // Update node position logic here
    if (widget.onNodesChanged != null) {
      widget.onNodesChanged!(widget.nodes);
    }
  }
}

// Mind Map Painter for connections
class MindMapPainter extends CustomPainter {
  final List<MindMapNode> nodes;

  MindMapPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw connections between nodes
    for (final node in nodes) {
      if (node.parentId != null) {
        final parent = nodes.firstWhere((n) => n.id == node.parentId);

        // Draw curved line from parent to child
        final path = Path();
        path.moveTo(parent.position.dx, parent.position.dy);

        final controlPoint1 = Offset(
          parent.position.dx + (node.position.dx - parent.position.dx) * 0.5,
          parent.position.dy,
        );
        final controlPoint2 = Offset(
          parent.position.dx + (node.position.dx - parent.position.dx) * 0.5,
          node.position.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          node.position.dx,
          node.position.dy,
        );

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(MindMapPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}
