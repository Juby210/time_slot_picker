library time_slot_picker;
import 'package:flutter/material.dart';
import 'package:time_slot_picker/slot.dart';

typedef tapEvent = void Function(DateTime, DateTime);
class TimeSlotPicker extends StatefulWidget {
  final DateTime? date;
  final OutlinedBorder? slotBorder;
  final TextStyle? textStyle;
  final int defaultSelectedHour;
  final bool hour12;
  final tapEvent onTap;

  TimeSlotPicker({
    Key? key,
    this.date,
    this.slotBorder,
    this.textStyle,
    required this.defaultSelectedHour,
    this.hour12 = false,
    required this.onTap
  }) : super(key: key);

  @override
  _TimeSlotPickerState createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  DateTime _currentDate = new DateTime.now();
  List<Slot> _timeSlots = [];
  int _selected = 0;

  late ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      padding: EdgeInsets.all(5.0),
      child: new ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        shrinkWrap: true,
        controller: _controller,

        itemBuilder: (BuildContext context, int index){
          return new Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: new TextButton(
              style: TextButton.styleFrom(
                backgroundColor: index == _selected ? Theme.of(context).colorScheme.primaryVariant : null,
                shape: widget.slotBorder ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                padding: EdgeInsets.all(10.0),
              ),
              child: new Text(_timeSlots[index].slotString, style: widget.textStyle ?? new TextStyle()),
              onPressed: (){
                widget.onTap(_timeSlots[index].startTime, _timeSlots[index].endTime);
                setState(() {
                  _selected = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if(widget.date!=null)
      _currentDate = widget.date ?? DateTime.now();
    _currentDate = new DateTime(_currentDate.year, _currentDate.month, _currentDate.day);

    this._timeSlots = _createTimeList(_currentDate);

    _controller = ScrollController(initialScrollOffset: (121 * _selected).toDouble()); // hacky
  }

  List<Slot> _createTimeList(DateTime date){
    List<Slot> slots = [];
    DateTime currentStartTime = date;
    while(true){
      if (widget.defaultSelectedHour == currentStartTime.hour) _selected = slots.length;
      Slot slot = new Slot();
      slot.startTime = currentStartTime;
      slot.endTime = currentStartTime.add(Duration(hours: 1)).subtract(Duration(seconds: 1));
      slot.slotString = _timeToString(slot.startTime) + " - " + _timeToString(slot.endTime);
      currentStartTime = currentStartTime.add(Duration(hours: 1));
      slots.add(slot);

      if(slot.endTime.hour == 23 && slot.endTime.minute == 59)
        break;
    }
    return slots;
  }

  String _timeToString(DateTime time) {
    if (widget.hour12 == true) {
      if(time.hour==0){
        String minute = time.minute.toString().length<2?"0"+time.minute.toString():time.minute.toString();
        return "12:$minute AM";
      }else if(time.hour<12){
        String hour = time.hour.toString().length<2?"0"+time.hour.toString():time.hour.toString();
        String minute = time.minute.toString().length<2?"0"+time.minute.toString():time.minute.toString();
        return "$hour:$minute AM";
      }else if(time.hour==12){
        String minute = time.minute.toString().length<2?"0"+time.minute.toString():time.minute.toString();
        return "12:$minute PM";
      }else{
        String hour = (time.hour-12).toString().length<2?"0"+(time.hour-12).toString():(time.hour-12).toString();
        String minute = time.minute.toString().length<2?"0"+time.minute.toString():time.minute.toString();
        return "$hour:$minute PM";
      }
    }
    String hour = time.hour.toString().length<2?"0"+time.hour.toString():time.hour.toString();
    String minute = time.minute.toString().length<2?"0"+time.minute.toString():time.minute.toString();
    return "$hour:$minute";
  }
}
