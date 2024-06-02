import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanState();
}

class _PlanState extends State<PlanPage> {
  final String _title = 'Plan Page (TODO)';
  final List<String> _plans = ['Plan 1', 'Plan 2', 'Plan 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: ListView.builder(
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_plans[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlan,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addPlan() {
    setState(() {
      _plans.add('New Plan');
    });
  }
}
