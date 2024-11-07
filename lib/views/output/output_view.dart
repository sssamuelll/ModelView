import 'package:flutter/material.dart';
import 'package:model_view/theme/json_linter.dart';

class OutputView extends StatelessWidget {
  final dynamic parsedJson;

  const OutputView({super.key, required this.parsedJson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelView - Output'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinear a la izquierda
            children: [
              _buildJsonTree(parsedJson),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJsonTree(dynamic data) {
    if (data is Map) {
      return _buildMap(data.cast<String, dynamic>());
    } else if (data is List) {
      return _buildList(data);
    } else {
      return _buildValue(data);
    }
  }

  Widget _buildMap(Map<String, dynamic> map) {
    String tooltipText = "${map.length} keys: " +
        map.entries
            .take(2)
            .map((e) => "${e.key}: ${e.value.runtimeType}")
            .join(", ") +
        (map.length > 2 ? ", ..." : "");

    String preview = "{ ${map.length} keys, types: " +
        map.values.map((e) => e.runtimeType).toSet().join(", ") +
        " }";

    return Card(
      color: const Color(0xFF1E1F26),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade800, width: 1),
      ),
      elevation: 2,
      child: Tooltip(
        message: tooltipText,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        child: ExpansionTile(
          leading:
              const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
          title: Text(
            preview,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto Mono',
              fontSize: 15,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(
              horizontal: 4.0), // Ajuste más compacto
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          children: map.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '"${entry.key}": ',
                      style: const TextStyle(
                        color: jsonKeyColor,
                        fontFamily: 'Roboto Mono',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildJsonTree(entry.value),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> list) {
    String tooltipText = "List of ${list.length} items, types: " +
        list.map((e) => e.runtimeType).toSet().join(", ");
    String preview = "[ ${list.length} items, type: " +
        (list.isNotEmpty ? list.first.runtimeType.toString() : "Unknown") +
        " ]";

    return Card(
      color: const Color(0xFF1E1F26),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade800, width: 1),
      ),
      elevation: 2,
      child: Tooltip(
        message: tooltipText,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        child: ExpansionTile(
          leading: const Icon(Icons.list_alt, color: Colors.greenAccent),
          title: Text(
            preview,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto Mono',
              fontSize: 15,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          children: list.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: _buildJsonTree(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildValue(dynamic value) {
    Color textColor;
    IconData? icon;

    if (value is String) {
      textColor = jsonStringColor;
      icon = Icons.text_fields;
    } else if (value is num) {
      textColor = jsonNumberColor;
      icon = Icons.bar_chart;
    } else if (value is bool) {
      textColor = value ? Colors.greenAccent : Colors.redAccent;
      icon = value ? Icons.check_circle : Icons.cancel;
    } else {
      textColor = Colors.grey;
      icon = Icons.help_outline;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: textColor, size: 18),
        const SizedBox(width: 4.0),
        Expanded(
          child: Text(
            '$value',
            style: TextStyle(
              color: textColor,
              fontFamily: 'Roboto Mono',
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
