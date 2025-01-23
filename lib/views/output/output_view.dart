import 'package:flutter/material.dart';

// Comenzamos con la clase OutputView
class OutputView extends StatelessWidget {
  final dynamic parsedJson;

  const OutputView({super.key, required this.parsedJson});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelView - Output'),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: _buildJsonTree(parsedJson, 0, false),
        ),
      ),
    );
  }

  Widget _buildJsonTree(dynamic data, int depth, bool isLast) {
    if (data is Map) {
      return _buildMap(data.cast<String, dynamic>(), depth, isLast);
    } else if (data is List) {
      return _buildList(data, depth);
    } else {
      return _buildSingleLineValue(data, depth);
    }
  }

  Widget _buildMap(Map<String, dynamic> map, int depth, bool isParentLast) {
    List<MapEntry<String, dynamic>> entries = map.entries.toList();
    int lastIndex = entries.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((entryWithIndex) {
        int index = entryWithIndex.key;
        MapEntry<String, dynamic> entry = entryWithIndex.value;
        bool isLastEntry = index == lastIndex;

        Widget title = Text(
          '"${entry.key}": ',
          style: const TextStyle(
            color: Color(0xFF9CDCFE),
            fontFamily: 'Roboto Mono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );

        if (entry.value is Map || entry.value is List) {
          return ExpandableNode(
            title: title,
            isLast: isLastEntry,
            child: _buildJsonTree(entry.value, depth + 1, isLastEntry),
          );
        } else {
          return _buildKeyValueInSingleRow(
            entry.key,
            entry.value,
            depth,
            isLastEntry,
          );
        }
      }).toList(),
    );
  }

  Widget _buildList(List<dynamic> list, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.asMap().entries.map((entry) {
        bool isLastEntry = entry.key == list.length - 1;

        Widget title = Text(
          '[${entry.key}]',
          style: const TextStyle(
            color: Color(0xFF9CDCFE),
            fontFamily: 'Roboto Mono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );

        if (entry.value is Map || entry.value is List) {
          return ExpandableNode(
            title: title,
            isLast: isLastEntry,
            child: _buildJsonTree(entry.value, depth + 1, isLastEntry),
          );
        } else {
          return _buildSingleLineValue(entry.value, depth);
        }
      }).toList(),
    );
  }

  Widget _buildKeyValueInSingleRow(
      String key, dynamic value, int depth, bool isLast) {
    Color textColor = _getTextColor(value);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: CustomPaint(
              painter: LinePainter(isLast: isLast),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '"$key": ',
                      style: const TextStyle(
                        color: Color(0xFF9CDCFE),
                        fontFamily: 'Roboto Mono',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '$value',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Roboto Mono',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleLineValue(dynamic value, int depth) {
    Color textColor = _getTextColor(value);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: CustomPaint(
              painter: LinePainter(isLast: false),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '$value',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Roboto Mono',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(dynamic value) {
    if (value is String) {
      return const Color(0xFFCE9178);
    } else if (value is num) {
      return const Color(0xFFB5CEA8);
    } else if (value is bool) {
      return value ? Colors.greenAccent : Colors.redAccent;
    } else {
      return Colors.grey;
    }
  }
}

// Definimos el widget ExpandableNode
class ExpandableNode extends StatefulWidget {
  final Widget title;
  final Widget child;
  final bool isLast;
  final bool initiallyExpanded;

  const ExpandableNode({
    super.key,
    required this.title,
    required this.child,
    required this.isLast,
    this.initiallyExpanded = true,
  });

  @override
  _ExpandableNodeState createState() => _ExpandableNodeState();
}

class _ExpandableNodeState extends State<ExpandableNode>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExpandableNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;

      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: CustomPaint(
              painter: LinePainter(isLast: widget.isLast),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _toggleExpansion,
                    child: Row(
                      children: [
                        Icon(
                          _isExpanded
                              ? Icons.arrow_drop_down
                              : Icons.arrow_right,
                          size: 16,
                          color: Colors.grey,
                        ),
                        widget.title,
                      ],
                    ),
                  ),
                  SizeTransition(
                    sizeFactor: _animation,
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Definimos el LinePainter
class LinePainter extends CustomPainter {
  final bool isLast;

  LinePainter({required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final Paint paint = Paint()
      ..color = const Color(0xFF4E4E4E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    // Altura del título (ajusta este valor si es necesario)
    double titleHeight = 20.0;

    // Línea vertical desde arriba hasta abajo
    path.moveTo(centerX, 0);
    if (isLast) {
      // Si es el último, la línea vertical termina en el centro del título
      path.lineTo(centerX, titleHeight / 2);
    } else {
      path.lineTo(centerX, size.height);
    }

    // Línea horizontal en el centro del título
    path.moveTo(centerX, titleHeight / 2);
    path.lineTo(size.width, titleHeight / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.isLast != isLast;
  }
}
