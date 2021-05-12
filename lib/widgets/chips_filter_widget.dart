import 'package:flutter/material.dart';

class ChipFilter extends StatefulWidget {
  final String owner;
  final String color;
  final bool selectState;
  final Function onSelect, onUnselect;

  ChipFilter({this.owner, this.color, this.selectState,this.onSelect,this.onUnselect});

  @override
  _ChipFilterState createState() => _ChipFilterState();
}

class _ChipFilterState extends State<ChipFilter> {
  bool _isSelected = false;
  Function sortedList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Container(
        child: FilterChip(

            label: Text(
              widget.owner,
              style: TextStyle(fontSize: 14),
            ),
            backgroundColor: Colors.black38,
            selected: _isSelected,
            selectedColor: Colors.black12,
            onSelected: (isSelected) {
              // print(widget.owner);
              setState(() {
                _isSelected = isSelected;
              });
              _isSelected ? widget.onSelect() : widget.onUnselect();
            }),
      ),
    );
  }
}