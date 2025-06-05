import 'package:flutter/material.dart';
import 'package:smartgridapp/view/widgets/section_iterator_widget.dart';

/// Page containing an iterative view of the Smart Grid Table
class TableIteratorPage extends StatefulWidget {
  const TableIteratorPage({super.key});

  @override
  State<TableIteratorPage> createState() => _TableIteratorPageState();
}

class _TableIteratorPageState extends State<TableIteratorPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SectionIterator(),
    );
  }
}
