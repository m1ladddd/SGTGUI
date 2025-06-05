import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/view/shared/title_data.dart';
import 'package:smartgridapp/view/widgets/chart_widgets.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:provider/provider.dart';

/// Simple custom [TextField] widget.
class TextFieldWidget extends StatelessWidget {
  final String prefix;
  final String hintText;
  final TextEditingController inputController;
  const TextFieldWidget({Key? key, required this.prefix, required this.hintText, required this.inputController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(offset: const Offset(12, 26), blurRadius: 50, spreadRadius: 0, color: Colors.grey.withOpacity(.1)),
          ]),
          child: TextField(
            controller: inputController,
            onSubmitted: (value) {
              inputController.text = value;
            },
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              label: Text(prefix),
              labelStyle: const TextStyle(color: Global.primary),
              // prefixIcon: Icon(Icons.email),
              filled: true,
              fillColor: Global.tertiary,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(.75)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Global.primary, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Global.secondary, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Global.error, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Global.primary, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom [TextField] widget for [double] type entries.
class DoubleTextFieldWidget extends StatefulWidget {
  final dynamic callback;
  final String prefixText;
  final double initialValue;
  final bool disabled;
  final TextEditingController controller;
  const DoubleTextFieldWidget({super.key, required this.callback, required this.initialValue, required this.prefixText, required this.controller, required this.disabled});

  @override
  State<DoubleTextFieldWidget> createState() => _DoubleTextFieldWidgetState();
}

class _DoubleTextFieldWidgetState extends State<DoubleTextFieldWidget> {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.prefixText),
          ),
          ConstrainedBox(
            //flex: 2,
            constraints: const BoxConstraints(maxWidth: 110),
            child: TextFormField(
              readOnly: widget.disabled,
              decoration: InputDecoration(
                hintText: widget.initialValue.toStringAsFixed(3),
                border: InputBorder.none,
              ),
              focusNode: focusNode,
              onTapOutside: (PointerDownEvent event) {
                String value = widget.controller.text;
                if (value.isNotEmpty) {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');
                  if (regExp.hasMatch(value)) {
                    double v = double.parse(value);

                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only rational numbers');
                    widget.controller.clear();
                  }
                }
                focusNode.unfocus();
              },
              onFieldSubmitted: (String value) {
                setState(() {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');
                  if (regExp.hasMatch(value) && !value.contains('/')) {
                    double v = double.parse(value);

                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only rational numbers');
                    widget.controller.clear();
                  }
                });
              },
              controller: widget.controller,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom [TextField] widget for [int] type entries.
class IntegerTextFieldWidget extends StatefulWidget {
  final dynamic callback;
  final String prefixText;
  final int initialValue;
  final bool disabled;
  final TextEditingController controller;
  const IntegerTextFieldWidget({super.key, required this.callback, required this.initialValue, required this.prefixText, required this.controller, required this.disabled});

  @override
  State<IntegerTextFieldWidget> createState() => _IntegerTextFieldWidgetState();
}

class _IntegerTextFieldWidgetState extends State<IntegerTextFieldWidget> {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.prefixText),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: TextFormField(
              readOnly: widget.disabled,
              decoration: InputDecoration(
                hintText: widget.initialValue.toStringAsFixed(0),
                border: InputBorder.none,
              ),
              focusNode: focusNode,
              onTapOutside: (PointerDownEvent event) {
                String value = widget.controller.text;
                if (value.isNotEmpty) {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'^[0-9]*$');
                  if (regExp.hasMatch(value)) {
                    int v = int.parse(value);

                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only integer numbers');
                    widget.controller.clear();
                  }
                }
                focusNode.unfocus();
              },
              onFieldSubmitted: (String value) {
                setState(() {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'^[0-9]*$');
                  if (regExp.hasMatch(value)) {
                    int v = int.parse(value);

                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only integer numbers');
                    widget.controller.clear();
                  }
                });
              },
              controller: widget.controller,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom [TextFormField] widget for [String] types.
class StringTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final dynamic callback;
  final String prefixText;
  final String hintText;
  final bool disabled;
  const StringTextFieldWidget({super.key, required this.controller, this.callback, required this.prefixText, required this.hintText, required this.disabled});

  @override
  State<StringTextFieldWidget> createState() => _StringTextFieldWidgetState();
}

class _StringTextFieldWidgetState extends State<StringTextFieldWidget> {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return TextFormField(
      readOnly: widget.disabled,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: size.width > 600 ? 8.0 : 12.0,
          ),
          child: Text(
            widget.prefixText,
          ),
        ),
        hintText: widget.hintText,
      ),
      focusNode: focusNode,
      onTapOutside: (PointerDownEvent event) {
        String value = widget.controller.text;
        if (value.isNotEmpty) {
          widget.callback(value);
        }
        focusNode.unfocus();
      },
      onFieldSubmitted: (value) => widget.callback(value),
      controller: widget.controller,
    );
  }
}

/// Custom [DropdownButton] for [List] type entries.
class DropDownWidget extends StatefulWidget {
  final List items;
  final dynamic callback;
  final String prefixText;
  final String? initialValue;
  final bool disabled;
  final bool underlineEnabled;
  final void Function(void Function())? parentSetState;

  const DropDownWidget({super.key, required this.items, required this.callback, required this.initialValue, required this.prefixText, required this.disabled, this.underlineEnabled = true, this.parentSetState});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String? selectedValue;

  @override
  void initState() {
    selectedValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: widget.underlineEnabled ? Colors.black : Colors.transparent, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: Text(widget.prefixText),
          ),
          ConstrainedBox(
            //flex: 2,
            constraints: const BoxConstraints(maxWidth: 110),
            child: DropdownButton(
              underline: Container(),
              isExpanded: true,
              items: List.generate(
                widget.items.length,
                (index) => DropdownMenuItem(
                  value: widget.items[index],
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.items[index]),
                  ),
                ),
              ),
              value: selectedValue,
              onChanged: widget.disabled
                  ? null
                  : (value) {
                      if (widget.parentSetState != null) {
                        widget.callback(value);
                        selectedValue = value.toString();
                        widget.parentSetState!(() {});
                      } else {
                        setState(() {
                          widget.callback(value);
                          selectedValue = value.toString();
                        });
                      }
                    },
            ),
          )
        ],
      ),
    );
  }
}

/// Custom [Slider] widget for [int] type entries.
class IntegerSliderWidget extends StatefulWidget {
  final dynamic callback;
  final String prefixText;
  final List range;
  final int initialValue;
  final bool disabled;
  final TextEditingController controller;
  const IntegerSliderWidget({super.key, required this.callback, required this.range, required this.initialValue, required this.prefixText, required this.controller, required this.disabled});

  @override
  State<IntegerSliderWidget> createState() => _IntegerSliderWidgetState();
}

class _IntegerSliderWidgetState extends State<IntegerSliderWidget> {
  double _currentSliderValue = 0;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    _currentSliderValue = widget.initialValue.toDouble();

    if (_currentSliderValue < widget.range[0]) _currentSliderValue = widget.range[0].toDouble();
    if (_currentSliderValue > widget.range[1]) _currentSliderValue = widget.range[1].toDouble();
    super.initState();
  }

  @override
  // Reinitializes the slider on widget update.
  void didUpdateWidget(covariant IntegerSliderWidget oldWidget) {
    _currentSliderValue = widget.initialValue.toDouble();

    if (_currentSliderValue < widget.range[0]) _currentSliderValue = widget.range[0].toDouble();
    if (_currentSliderValue > widget.range[1]) _currentSliderValue = widget.range[1].toDouble();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.prefixText),
          ),
          Expanded(
            flex: 4,
            child: Slider(
              value: _currentSliderValue,
              min: widget.range[0].toDouble(),
              max: widget.range[1].toDouble(),
              divisions: 50,
              label: _currentSliderValue.round().toString(),
              onChanged: widget.disabled
                  ? null
                  : (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        widget.callback(value.toInt());
                      });
                    },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: TextFormField(
              readOnly: widget.disabled,
              decoration: InputDecoration(
                hintText: _currentSliderValue.toInt().toString(),
                border: InputBorder.none,
              ),
              focusNode: focusNode,
              onTapOutside: (PointerDownEvent event) {
                String value = widget.controller.text;
                if (value.isNotEmpty) {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'^[0-9]*$');
                  if (regExp.hasMatch(value)) {
                    int v = int.parse(value);

                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only integer numbers');
                    widget.controller.clear();
                  }
                }
                focusNode.unfocus();
              },
              onFieldSubmitted: (String value) {
                setState(() {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'^[0-9]*$');
                  if (regExp.hasMatch(value)) {
                    double v = double.parse(value);
                    if (widget.range[0] <= v && v <= widget.range[1]) {
                      _currentSliderValue = v;
                    } else {
                      showToast(context: context, 'Please stick to values within the specified range');
                      widget.controller.clear();
                    }
                    widget.callback(int.parse(value));
                  } else {
                    showToast(context: context, 'Please provide only integer numbers');
                    widget.controller.clear();
                  }
                });
              },
              controller: widget.controller,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom [Slider] widget for [double] type entries.
class DoubleSliderWidget extends StatefulWidget {
  final dynamic callback;
  final String prefixText;
  final List range;
  final double initialValue;
  final bool disabled;
  final TextEditingController controller;
  const DoubleSliderWidget({super.key, required this.callback, required this.range, required this.initialValue, required this.prefixText, required this.controller, required this.disabled});

  @override
  State<DoubleSliderWidget> createState() => _DoubleSliderWidgetState();
}

class _DoubleSliderWidgetState extends State<DoubleSliderWidget> {
  double _currentSliderValue = 0;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    _currentSliderValue = widget.initialValue;

    if (_currentSliderValue < widget.range[0]) _currentSliderValue = widget.range[0].toDouble();
    if (_currentSliderValue > widget.range[1]) _currentSliderValue = widget.range[1].toDouble();
    super.initState();
  }

  @override
  // Reinitializes the slider on widget update.
  void didUpdateWidget(covariant DoubleSliderWidget oldWidget) {
    _currentSliderValue = widget.initialValue;

    if (_currentSliderValue < widget.range[0]) _currentSliderValue = widget.range[0].toDouble();
    if (_currentSliderValue > widget.range[1]) _currentSliderValue = widget.range[1].toDouble();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.prefixText),
          ),
          Expanded(
            flex: 4,
            child: Slider(
              value: _currentSliderValue,
              min: widget.range[0].toDouble(),
              max: widget.range[1].toDouble(),
              divisions: 50,
              label: _currentSliderValue.toString(),
              onChanged: widget.disabled
                  ? null
                  : (double value) {
                      setState(() {
                        _currentSliderValue = double.parse(value.toStringAsPrecision(3));
                        widget.callback(_currentSliderValue);
                      });
                    },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: TextFormField(
              readOnly: widget.disabled,
              decoration: InputDecoration(
                hintText: _currentSliderValue.toStringAsFixed(3),
                border: InputBorder.none,
              ),
              focusNode: focusNode,
              onTapOutside: (PointerDownEvent event) {
                String value = widget.controller.text;
                if (value.isNotEmpty) {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');
                  if (regExp.hasMatch(value)) {
                    double v = double.parse(value);

                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only rational numbers');
                    widget.controller.clear();
                  }
                }
                focusNode.unfocus();
              },
              onFieldSubmitted: (String value) {
                setState(() {
                  /// Regular Expression for all rational numbers
                  RegExp regExp = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');
                  if (regExp.hasMatch(value) && !value.contains('/')) {
                    double v = double.parse(value);
                    if (widget.range[0] <= v && v <= widget.range[1]) {
                      _currentSliderValue = v;
                    } else {
                      showToast(context: context, 'Please stick to values within the specified range');
                      widget.controller.clear();
                    }
                    widget.callback(v);
                  } else {
                    showToast(context: context, 'Please provide only rational numbers');
                    widget.controller.clear();
                  }
                });
              },
              controller: widget.controller,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom widget for editing List<double> type entries.
/// Can toggle between a single [TextFormField] and a button that navigates to [DoubleArrayEditorScreen].
class DynamicDoubleArrayField extends StatefulWidget {
  final dynamic callback;
  final String fieldText;
  final dynamic value;
  final bool disabled;
  final int length;
  final TextEditingController controller;
  const DynamicDoubleArrayField({Key? key, this.callback, required this.fieldText, required this.value, required this.disabled, required this.controller, required this.length}) : super(key: key);

  @override
  State<DynamicDoubleArrayField> createState() => _DynamicDoubleArrayFieldState();
}

class _DynamicDoubleArrayFieldState extends State<DynamicDoubleArrayField> {
  bool isArray = false;
  dynamic _value;

  @override
  void initState() {
    isArray = widget.value is List;
    _value = isArray ? widget.value.map((value) => value.toDouble()).toList() : widget.value.toDouble();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicDoubleArrayField oldWidget) {
    isArray = widget.value is List;
    _value = isArray ? widget.value.map((value) => value.toDouble()).toList() : widget.value.toDouble();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        isArray
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider, vertical: 5.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(widget.fieldText)),
                    SizedBox(
                      width: 142,
                      height: 38,
                      child: TextButton(
                        onPressed: widget.disabled
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return DoubleArrayEditorView(
                                        items: _value,
                                        title: widget.fieldText,
                                        callback: widget.callback,
                                        disabled: widget.disabled,
                                      );
                                    },
                                  ),
                                );
                              },
                        child: Text(
                          'Array Editor',
                          style: TextStyle(
                            color: widget.disabled
                                ? Colors.grey
                                : themeManager.isDark
                                    ? Global.tertiary
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : DoubleTextFieldWidget(
                callback: widget.callback,
                initialValue: _value,
                prefixText: widget.fieldText,
                controller: widget.controller,
                disabled: widget.disabled,
              ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 122.0),
            child: IconButton(
              tooltip: 'Switch value type',
              onPressed: widget.disabled
                  ? null
                  : () {
                      setState(() {
                        if (isArray) {
                          // Value will be first of the original array.
                          _value = _value[0];
                        } else {
                          // Value will become an array where the first value will be set.
                          _value = List.generate(widget.length, (index) => _value);
                        }

                        isArray = !isArray;
                        widget.callback(_value);
                      });
                    },
              icon: const Icon(Icons.swap_horiz),
            ),
          ),
        ),
      ],
    );
  }
}

/// Screen for editing List<double> type entries.
class DoubleArrayEditorView extends StatefulWidget {
  final dynamic callback;
  final String title;
  final List items;
  final bool disabled;
  const DoubleArrayEditorView({Key? key, required this.items, this.callback, required this.title, required this.disabled}) : super(key: key);

  @override
  State<DoubleArrayEditorView> createState() => _DoubleArrayEditorViewState();
}

class _DoubleArrayEditorViewState extends State<DoubleArrayEditorView> {
  List _items = [];
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    _items = List.from(widget.items);
    _controllers = List.generate(_items.length, (index) => TextEditingController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;
    List<Widget> children = [];

    children.addAll(_buildForms());

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 50, bottom: 5),
              child: DoubleLineGraph(lineData: _items),
            ),
          ),
          const ListTile(
            title: Text(
              'Intervals',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              children: children,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0 / paddingDivider),
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.callback(List.from(_items));
                    for (TextEditingController controller in _controllers) {
                      controller.clear();
                    }
                  });
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Global.tertiary),
                )),
          )
        ],
      ),
    );
  }

  List<Widget> _buildForms() {
    List<Widget> forms = [];
    for (int i = 0; i < _items.length; i++) {
      double val = _items[i].toDouble();

      forms.add(
        ListTile(
          leading: const Icon(Icons.numbers),
          title: DoubleTextFieldWidget(
            callback: (value) {
              setState(() {
                _items[i] = value;
              });
            },
            initialValue: val,
            controller: _controllers[i],
            disabled: false,
            prefixText: LineTitles.getTimestamp(i.toDouble(), _items.length),
          ),
        ),
      );
    }
    return forms;
  }
}

/// Custom widget for editing List<int> type entries.
/// Can toggle between a single [TextFormField] and a button that navigates to [IntArrayEditorScreen].
class DynamicIntegerArrayField extends StatefulWidget {
  final dynamic callback;
  final String fieldText;
  final dynamic value;
  final bool disabled;
  final int length;
  final TextEditingController controller;
  const DynamicIntegerArrayField({Key? key, this.callback, required this.fieldText, required this.value, required this.disabled, required this.controller, required this.length}) : super(key: key);

  @override
  State<DynamicIntegerArrayField> createState() => _DynamicIntegerArrayFieldState();
}

class _DynamicIntegerArrayFieldState extends State<DynamicIntegerArrayField> {
  bool isArray = false;
  dynamic _value;

  @override
  void initState() {
    isArray = widget.value is List;
    _value = isArray ? widget.value : widget.value.toInt();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicIntegerArrayField oldWidget) {
    isArray = widget.value is List;
    _value = isArray ? widget.value : widget.value.toInt();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        isArray
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0 / paddingDivider, vertical: 5.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(widget.fieldText)),
                    SizedBox(
                      width: 142,
                      height: 38,
                      child: TextButton(
                        onPressed: widget.disabled
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return IntegerArrayEditorView(
                                        items: _value,
                                        title: widget.fieldText,
                                        callback: widget.callback,
                                        disabled: widget.disabled,
                                      );
                                    },
                                  ),
                                );
                              },
                        child: Text(
                          'Array Editor',
                          style: TextStyle(
                            color: widget.disabled
                                ? Colors.grey
                                : themeManager.isDark
                                    ? Global.tertiary
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : IntegerTextFieldWidget(
                callback: widget.callback,
                initialValue: _value,
                prefixText: widget.fieldText,
                controller: widget.controller,
                disabled: widget.disabled,
              ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 122.0),
            child: IconButton(
              tooltip: 'Switch value type',
              onPressed: widget.disabled
                  ? null
                  : () {
                      setState(() {
                        if (isArray) {
                          // Value will be first of the original array.
                          _value = _value[0];
                        } else {
                          // Value will become an array where the first value will be set.
                          _value = List.generate(widget.length, (index) => _value);
                        }

                        isArray = !isArray;
                        widget.callback(_value);
                      });
                    },
              icon: const Icon(Icons.swap_horiz),
            ),
          ),
        ),
      ],
    );
  }
}

/// Screen for editing List<int> type entries.
class IntegerArrayEditorView extends StatefulWidget {
  final dynamic callback;
  final String title;
  final List items;
  final bool disabled;
  const IntegerArrayEditorView({Key? key, required this.items, this.callback, required this.title, required this.disabled}) : super(key: key);

  @override
  State<IntegerArrayEditorView> createState() => _IntegerArrayEditorViewState();
}

class _IntegerArrayEditorViewState extends State<IntegerArrayEditorView> {
  List _items = [];
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    _items = List.from(widget.items);
    _controllers = List.generate(_items.length, (index) => TextEditingController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingDivider = size.width > 600 ? 1 : 0.64;
    List<Widget> children = [];

    children.addAll(_buildForms());

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 50, bottom: 5),
              child: DoubleLineGraph(lineData: _items),
            ),
          ),
          const ListTile(
            title: Text(
              "Intervals",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: children,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0 / paddingDivider),
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.callback(List.from(_items));
                    for (TextEditingController controller in _controllers) {
                      controller.clear();
                    }
                  });
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Global.tertiary),
                )),
          )
        ],
      ),
    );
  }

  List<Widget> _buildForms() {
    List<Widget> forms = [];
    for (int i = 0; i < _items.length; i++) {
      int val = _items[i].toInt();

      forms.add(
        ListTile(
          leading: const Icon(Icons.numbers),
          title: IntegerTextFieldWidget(
            callback: (value) {
              setState(() {
                _items[i] = value;
              });
            },
            initialValue: val,
            controller: _controllers[i],
            disabled: false,
            prefixText: LineTitles.getTimestamp(i.toDouble(), _items.length),
          ),
        ),
      );
    }
    return forms;
  }
}
