import 'package:flutter/material.dart';

class Tables extends StatelessWidget {
  const Tables(
      {super.key,
      required this.heading,
      required this.heads,
      required this.rows,
      required this.maxHeight});
  final double maxHeight;
  final String heading;
  final List<String> heads;
  final List<List<dynamic>> rows;

  DataTable dataBody() {
    return DataTable(
      columnSpacing: Checkbox.width,
      showBottomBorder: true,
      columns: heads
          .map((head) => DataColumn(label: Text(head), tooltip: "The $head"))
          .toList(),
      rows: rows
          .map((row) =>
              DataRow(cells: row.map((data) => DataCell(data)).toList()))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      verticalDirection: VerticalDirection.down,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          heading,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: dataBody(),
        ),
      ],
    );
  }
}
