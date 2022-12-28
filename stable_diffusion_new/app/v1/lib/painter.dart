import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//import 'package:painter/painter.dart';
import 'painter_src.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class PainterWidget extends StatefulWidget {
  _PainterState _state = new _PainterState();

  _PainterState get get_current_painter_state{
    return _state;
  }

  @override
  _PainterState createState() {
    _state = new _PainterState();
    return _state;
  }
}

class _PainterState extends State<PainterWidget> {
  bool _finished = false;
  PainterController _controller = _newController();
  PainterController _prevController = _newController();

  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> get finish_and_get_memory_img{
    _prevController = _controller;
    return _controller.finish().toPNG();
  }

  Future<Uint8List> get get_memory_img{
    _prevController = _controller;
    return _controller.rendered.toPNG();
  }

  void  reload_controller() {
    setState(() {
      _controller = _newController();
    });
  }

  void load_prev_controller(){
    print(_prevController.isFinished());
    setState(() {
      _controller = _prevController;
    });
  }


  static PainterController _newController() {
    PainterController controller = new PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.white;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;
    if (_finished) {
      actions = <Widget>[
        new IconButton(
          icon: new Icon(Icons.content_copy),
          tooltip: 'New Painting',
          onPressed: () => setState(() {
            _finished = false;
            _controller = _newController();
          }),
        ),
      ];
    } else {
      actions = <Widget>[
        new IconButton(
            icon: new Icon(
              Icons.undo,
            ),
            tooltip: 'Undo',
            onPressed: () {
              if (!_controller.isEmpty) {
                  _controller.undo();
              }
            }),
        new IconButton(
            icon: new Icon(Icons.delete),
            tooltip: 'Clear',
            onPressed: _controller.clear),
//        new IconButton(
//            icon: new Icon(Icons.check),
//            onPressed: () => _show(_controller.finish(),_prompt_controller.value.text , context)),
      ];
    }
    return new Scaffold(
      body: new Center(
          child: Column(
            children: [

              Row( // reload and stuff
                children: actions
              ),

              AspectRatio(aspectRatio: 1.0, child: new Painter(_controller)), // painter

              PreferredSize(
                child: new DrawBar(_controller),
                preferredSize: new Size(MediaQuery.of(context).size.width, 30.0), //colorpicker
              )
            ],
          )
      ),
        backgroundColor: Colors.blueGrey
    );
  }


}




class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Flexible(child: new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return new Container(
                  child: new Slider(
                    value: _controller.thickness,
                    onChanged: (double value) => setState(() {
                      _controller.thickness = value;
                    }),
                    min: 1.0,
                    max: 20.0,
                    activeColor: Colors.white,
                  ));
            })),
        new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return new RotatedBox(
                  quarterTurns: _controller.eraseMode ? 2 : 0,
                  child: IconButton(
                      icon: new Icon(Icons.create),
                      tooltip: (_controller.eraseMode ? 'Disable' : 'Enable') +
                          ' eraser',
                      onPressed: () {
                        setState(() {
                          _controller.eraseMode = !_controller.eraseMode;
                        });
                      }));
            }),
        new ColorPickerButton(_controller, false),
        new ColorPickerButton(_controller, true),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final PainterController _controller;
  final bool _background;

  ColorPickerButton(this._controller, this._background);

  @override
  _ColorPickerButtonState createState() => new _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return new IconButton(
        icon: new Icon(_iconData, color: _color),
        tooltip: widget._background
            ? 'Change background color'
            : 'Change draw color',
        onPressed: _pickColor);
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator.of(context)
        .push(new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return new Scaffold(
              appBar: new AppBar(
                title: const Text('Pick color'),
              ),
              body: new Container(
                  alignment: Alignment.center,
                  child: new ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (Color c) => pickerColor = c,
                  )));
        }))
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => widget._background
      ? widget._controller.backgroundColor
      : widget._controller.drawColor;

  IconData get _iconData =>
      widget._background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    if (widget._background) {
      widget._controller.backgroundColor = color;
    } else {
      widget._controller.drawColor = color;
    }
  }
}

