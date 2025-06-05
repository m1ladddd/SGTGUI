import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/models/table.dart';
import 'package:smartgridapp/view/shared/defines.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/widgets/entry_widgets.dart';

/// Custom [AlertDialog] widget containing all parameters of a certain [Module]
class ParameterDialog extends StatefulWidget {
  final Module? module;

  const ParameterDialog({super.key, required this.module});

  @override
  State<ParameterDialog> createState() => _ParameterDialogState();
}

class _ParameterDialogState extends State<ParameterDialog> {
  Module? module;
  Module? tempModule;
  Module? defaultModule;

  String? name;
  String? voltageLevel;

  TextEditingController nameFieldController = TextEditingController();

  @override
  void initState() {
    if (widget.module != null) {
      module = Module.clone(widget.module!);
      tempModule = Module.clone(module!);

      final TableHandler tableHandler = Provider.of<TableHandler>(context, listen: false);
      String id = tempModule!.id;
      Map data = Map.from(tableHandler.scenarioObjectsManager.originalScenario[id] ?? {});
      defaultModule = Module.clone(Module.fromMap(id, data));
    }

    super.initState();
  }

  // Callback function to update the modules parameters for nested widgets
  void updateCallback() {
    final TableHandler tableHandler = Provider.of<TableHandler>(context, listen: false);

    /// Use copy constructor to prevent copying be reference.
    module = Module.clone(tempModule!);
    tableHandler.changeParameters(module!);
  }

  // Function for updating the parameters of a module
  void updatemodule() {
    setState(() {
      if (name != null) {
        if (name!.isNotEmpty) {
          tempModule?.name = name!;

          // Reset fields
          nameFieldController.clear();
          name = null;
        }
      }

      if (voltageLevel != null) {
        tempModule?.voltageLevel = voltageLevel!;
      }
    });

    updateCallback();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final TableHandler tableHandler = Provider.of<TableHandler>(context);
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);

    return AlertDialog(
      // Dialog window contains all parameters of a given module.
      // Based on the components contained in this module, icon button can be lit up.
      // Through the icon buttons can be navigated to the corresponding component window.
      //
      // The dialog window has the following structure:
      //
      //  Title:
      //  Text Widget
      //
      //  Content:
      //  Column Widget
      //  ---Text Entry Widget (module name)
      //  ---Dropdown Menu (module voltage level)
      //  ---Row Widget
      //  ------Component Icon Buttons
      //
      //  Actions:
      //  Update and close Buttons
      //

      title: const Text('Module Parameters'),
      actionsAlignment: MainAxisAlignment.end,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: module == null
            ? const [
                Text("This spot contains no module"),
              ]
            : [
                StringTextFieldWidget(
                  disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, 'name', null),
                  controller: nameFieldController,
                  callback: (value) => name = value,
                  prefixText: 'Name: ',
                  hintText: module!.name,
                ),
                DropDownWidget(
                  disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, 'voltage', null),
                  items: tableHandler.restrictionsManager.getRangeRestrictions('voltage', null),
                  callback: (selectedValue) => voltageLevel = selectedValue,
                  initialValue: module!.voltageLevel,
                  prefixText: 'Voltage Level: ',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => ParameterItemsViewer(
                            updateCallback: updateCallback,
                            moduleParameters: tempModule!.generators,
                            defaultParameters: defaultModule!.generators,
                            parameterKey: 'generators',
                            title: 'Generator Parameters',
                          ),
                        );
                      },
                      icon: Image.asset(
                        'images/icons8-generator-64.png',
                        color: tempModule!.generators.isEmpty
                            ? themeManager.isDark
                                ? Colors.white
                                : Colors.black
                            : Colors.greenAccent,
                      ),
                      tooltip: 'Generators',
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => ParameterItemsViewer(
                            updateCallback: updateCallback,
                            moduleParameters: tempModule!.transformers,
                            defaultParameters: defaultModule!.transformers,
                            parameterKey: 'transformers',
                            title: 'Transformer Parameters',
                          ),
                        );
                      },
                      icon: Image.asset(
                        'images/icons8-power-transformer-64.png',
                        color: tempModule!.transformers.isEmpty
                            ? themeManager.isDark
                                ? Colors.white
                                : Colors.black
                            : Colors.greenAccent,
                      ),
                      tooltip: 'Transformers',
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => ParameterItemsViewer(
                            updateCallback: updateCallback,
                            moduleParameters: tempModule!.storages,
                            defaultParameters: defaultModule!.storages,
                            parameterKey: 'storages',
                            title: 'Storage Parameters',
                          ),
                        );
                      },
                      icon: Image.asset(
                        'images/icons8-android-l-battery-50.png',
                        color: tempModule!.storages.isEmpty
                            ? themeManager.isDark
                                ? Colors.white
                                : Colors.black
                            : Colors.greenAccent,
                      ),
                      tooltip: 'Storages',
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => ParameterItemsViewer(
                            updateCallback: updateCallback,
                            moduleParameters: tempModule!.loads,
                            defaultParameters: defaultModule!.loads,
                            parameterKey: 'loads',
                            title: 'Load Parameters',
                          ),
                        );
                      },
                      icon: Image.asset(
                        'images/icons8-cables-64.png',
                        color: tempModule!.loads.isEmpty
                            ? themeManager.isDark
                                ? Colors.white
                                : Colors.black
                            : Colors.greenAccent,
                      ),
                      tooltip: 'Loads',
                    ),
                  ],
                )
              ],
      ),
      actions: <Widget>[
        Visibility(
          visible: module != null,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // Clears textfield
                updatemodule();
                nameFieldController.clear();
              });
            },
            child: const Text(
              'Update',
              style: TextStyle(color: Global.tertiary),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(color: Global.tertiary),
          ),
        ),
      ],
    );
  }
}

/// Window for viewing and editing component parameters of a [Module].
class ParameterItemsViewer extends StatefulWidget {
  /// Callback for updating [Module].
  final VoidCallback updateCallback;

  /// [List] of parameters containing a reference to the original [Module].
  final List moduleParameters;

  /// [List] of parameters of the original [Module].
  final List defaultParameters;

  /// [String] of parameter type.
  final String parameterKey;

  /// Title of page.
  final String title;

  const ParameterItemsViewer({super.key, required this.updateCallback, required this.moduleParameters, required this.title, required this.parameterKey, required this.defaultParameters});

  @override
  State<ParameterItemsViewer> createState() => _ParameterItemsViewerState();
}

class _ParameterItemsViewerState extends State<ParameterItemsViewer> {
  int index = 0;
  List<TextEditingController> controllers = [];
  List parameterFields = [];

  void _changeCounter(int change) {
    setState(() {
      index += change;
      // If list is empty, index % 0 would cause a division by zero exception
      index = widget.moduleParameters.isNotEmpty ? index % widget.moduleParameters.length : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This window is for view a type of component.
    // A component can be a:
    // - Generator
    // - Transformer
    // - Storage
    // - Load
    //
    // Components can be added to or removed from the list.
    // This can be done using icon buttons in the appbar.
    // These options are only available to advanced users.
    // All parameters are visible on the ParameterCard widget.
    //
    // This page has the following structure:
    //    Appbar:
    //    ParameterAppBar
    //
    //    Body:
    //    Container
    //    ---Column Widget
    //    ------Row Widget
    //    ---------Icon Button Left
    //    ---------Text Field
    //    ---------Icon Button Right
    //    ------Container
    //    ---------ParameterCard
    //    ------Container
    //    ---------Row
    //    ------------Update Button
    //    ------------Close Button

    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final TableHandler tableHandler = Provider.of<TableHandler>(context);
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);
    final Size size = MediaQuery.of(context).size;
    int sizeDivider = size.width > 600 ? 1 : 2;

    // Create list of TextEditingControllers if there are parameters to edit
    if (widget.moduleParameters.isNotEmpty) {
      controllers = List.generate(widget.moduleParameters[index].length, (index) => TextEditingController());
      parameterFields = List.generate(widget.moduleParameters[index].length, (index) => null);
    }

    void updateModule() {
      setState(() {
        // Loops over all controllers, gets value
        // and updates the parameter field if it was not empty
        List keys = widget.moduleParameters[index].keys.toList();
        for (int i = 0; i < controllers.length; i++) {
          if (parameterFields[i] != null) {
            widget.moduleParameters[index][keys[i]] = parameterFields[i];
            controllers[i].clear();
          }
        }
        widget.updateCallback();
      });
    }

    // Function for removing a properties field of a component
    void removeProperty() {
      setState(() {
        widget.moduleParameters.removeAt(index);
        _changeCounter(-1);
      });

      showToast('Property field has been removed succesfully!', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);

      widget.updateCallback();
    }

    // Function for adding a properties field of a component.
    // Creates window for selection of parameters to include.
    void addProperty() {
      // List of available parameters to be added to new component.
      List<String> params = tableHandler.restrictionsManager.getParameterNames(difficultyManager.stringDifficulty, widget.parameterKey);
      List<bool> includes = List.generate(params.length, (index) => false);

      showDialog(
        context: context,
        builder: (context) {
          // Dialog contains the following structure:
          //
          // content
          // ---SingleChildScrollView
          // ------Column
          // ---------Padding
          // ------------FittedBox
          // ---------------SizedBox
          // ------------------SwitchListTile
          // ---------Padding
          // ------------FittedBox
          // ---------------SizedBox
          // ------------------SwitchListTile
          // ---------Padding
          // ------------FittedBox
          // ---------------SizedBox
          // ------------------SwitchListTile
          //
          // actions
          // ---ElevatedButton
          // ---ElevatedButton

          return StatefulBuilder(
            // Created different setState for refreshing alert dialog.
            // Parent widgets can still be refreshed using the original setState.
            builder: (context, setStateChild) {
              List<Widget> widgets = [
                const Text('Select parameters to be included.'),
                const SizedBox(
                  height: 20,
                )
              ];

              widgets.addAll(
                List.generate(
                  params.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0 / sizeDivider),
                    // Will scale with screen width
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 250,
                        child: SwitchListTile(
                          title: Text(params[index]),
                          value: includes[index],
                          onChanged: (bool value) {
                            setStateChild(() {
                              includes[index] = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );

              return AlertDialog(
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: widgets,
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // New component field from selected parameters.
                          Map newParams = tableHandler.restrictionsManager.cmptParamsFromRestrictions(widget.parameterKey, includes);
                          widget.moduleParameters.add(newParams);
                          index = widget.moduleParameters.length - 1;
                          showToast('New property field has been created succesfully!', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Global.tertiary),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Global.tertiary),
                      ))
                ],
              );
            },
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ParameterAppBar(
          hasParamField: widget.moduleParameters.isNotEmpty,
          removePropertyCallback: removeProperty,
          addPropertyCallback: addProperty,
          title: widget.title,
        ),
      ),
      body: Container(
        color: themeManager.isDark ? const Color.fromARGB(255, 70, 53, 92) : Global.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.moduleParameters.isEmpty
                      ? []
                      : [
                          Visibility(
                            /* Only when there are multiple items
                               the navigation button is needed */
                            visible: widget.moduleParameters.length > 1,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _changeCounter(-1);
                                });
                              },
                              icon: const Icon(
                                Icons.arrow_left,
                                color: Global.tertiary,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '${widget.title} ${index + 1}',
                              style: const TextStyle(color: Global.tertiary),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Visibility(
                            /* Only when there are multiple items
                               the navigation button is needed */
                            visible: widget.moduleParameters.length > 1,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _changeCounter(1);
                                });
                              },
                              icon: const Icon(
                                Icons.arrow_right,
                                color: Global.tertiary,
                              ),
                            ),
                          ),
                        ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 50 / sizeDivider, horizontal: 50 / sizeDivider),
                decoration: BoxDecoration(
                  color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                /* Width set to infinity to use all the space available */
                width: double.infinity,
                child: ParameterCard(
                  parameterKey: widget.parameterKey,
                  parameters: widget.moduleParameters.isEmpty ? null : widget.moduleParameters[index],
                  defaultParameters: widget.defaultParameters.isEmpty || widget.defaultParameters.length < index + 1 || widget.moduleParameters.isEmpty ? null : widget.defaultParameters[index],
                  parameterFields: parameterFields,
                  controllers: controllers,
                  updateCallback: updateModule,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Update button should only be visible
                    // when there are element to be updated
                    Visibility(
                      visible: widget.moduleParameters.isNotEmpty,
                      child: ElevatedButton(
                        onPressed: () {
                          updateModule();
                          for (var controller in controllers) {
                            controller.clear();
                          }
                        },
                        child: const Text(
                          'Update',
                          style: TextStyle(color: Global.tertiary),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Global.tertiary),
                      ),
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

/// Parameter card for viewing and editing list of parameters
class ParameterCard extends StatefulWidget {
  final String parameterKey;
  final Map? defaultParameters;
  final Map? parameters;
  final List<TextEditingController> controllers;
  final List parameterFields;
  final VoidCallback updateCallback;
  const ParameterCard({super.key, required this.parameters, required this.controllers, required this.parameterKey, required this.parameterFields, this.defaultParameters, required this.updateCallback});

  @override
  State<ParameterCard> createState() => _ParameterCardState();
}

class _ParameterCardState extends State<ParameterCard> {
  @override
  Widget build(BuildContext context) {
    final TableHandler tableHandler = Provider.of<TableHandler>(context);
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);

    /// When no parameters are supplied, a message is showed on the screen
    /// When there are parameters, the following structure for display is used:
    /// Listview
    /// ---Item 1
    /// ---Item 2
    /// ---Item N
    ///
    /// Depending on the type of the field provided in the restrictions JSON,
    /// The type of field changes. For the String type, a TextFormField is supplied.
    /// For List types, a dropdown menu is used. For integers and doubles a combination
    /// of a slider and a TextField is used. And for Lists of doubles or integers,
    /// one or more textfields are used.
    return widget.parameters == null
        ? const Center(child: Text('This module has no parameters of this type'))
        : widget.defaultParameters == null && difficultyManager.difficulty == Difficulty.beginner
            ? const Center(child: Text('This cannot be changed by beginner users.'))
            : ListView(
                //mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.parameters!.length,
                  (idx) {
                    String key = widget.parameters!.keys.toList()[idx];
                    String paramName = tableHandler.restrictionsManager.getNicerParameterName(difficultyManager.stringDifficulty, widget.parameterKey, key) ?? key;

                    bool visible = tableHandler.restrictionsManager.getVisibilityRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key);
                    Type dataType = tableHandler.restrictionsManager.getTypeRestrictions(widget.parameterKey, key);
                    Widget editField = Container();

                    if (visible) {
                      if (dataType == String) {
                        // String datatype is for a parameter of type string
                        // containing any value except for a series of numbers
                        String value = widget.parameters![key];
                        editField = StringTextFieldWidget(
                          callback: (value) => widget.parameterFields[idx] = value,
                          disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                          controller: widget.controllers[idx],
                          hintText: value.toString(),
                          prefixText: '$paramName: ',
                        );
                      }

                      if (dataType == List) {
                        // The list datatype specifies that the parameter can only be
                        // one particular string value of a certain preset.
                        String value = widget.parameters![key];
                        editField = DropDownWidget(
                          disabled: tableHandler.restrictionsManager.getWriteRestrictions(
                            difficultyManager.stringDifficulty,
                            widget.parameterKey,
                            key,
                          ),
                          callback: (value) => widget.parameterFields[idx] = value.toString(),
                          initialValue: value,
                          items: tableHandler.restrictionsManager.getRangeRestrictions(
                            widget.parameterKey,
                            key,
                          ),
                          prefixText: '$paramName: ',
                        );
                      }

                      if (dataType == int) {
                        // Initial value is an integer.
                        int value = widget.parameters![key].toInt();
                        if (difficultyManager.difficulty == Difficulty.beginner) {
                          editField = IntegerSliderWidget(
                            disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                            callback: (value) => widget.parameterFields[idx] = value,
                            range: [
                              0,
                              int.parse(widget.defaultParameters![key].toString())
                            ],
                            initialValue: value,
                            prefixText: '$paramName: ',
                            controller: widget.controllers[idx],
                          );
                        }

                        if (difficultyManager.difficulty == Difficulty.advanced) {
                          editField = IntegerTextFieldWidget(
                            disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                            callback: (value) => widget.parameterFields[idx] = value,
                            initialValue: value,
                            prefixText: '$paramName: ',
                            controller: widget.controllers[idx],
                          );
                        }
                      }

                      if (dataType == List<int>) {
                        // Initial value can be a integer or list.
                        // If the initial value is not a list, the value is cast to an integer to prevent an exception.
                        dynamic value = widget.parameters![key];
                        if (value is! List) value = value.toInt();

                        if (difficultyManager.difficulty == Difficulty.beginner) {}

                        if (difficultyManager.difficulty == Difficulty.advanced) {
                          editField = DynamicIntegerArrayField(
                            disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                            callback: (value) => widget.parameterFields[idx] = value,
                            value: value,
                            fieldText: '$paramName: ',
                            controller: widget.controllers[idx],
                            length: tableHandler.restrictionsManager.getRangeRestrictions(
                              widget.parameterKey,
                              key,
                            ),
                          );
                        }
                      }

                      if (dataType == double) {
                        // Initial value can be a double or integer.
                        // Thus the first value is cast to a double to prevent an exception.
                        double value = widget.parameters![key].toDouble();
                        if (difficultyManager.difficulty == Difficulty.beginner) {
                          editField = DoubleSliderWidget(
                            disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                            callback: (value) => widget.parameterFields[idx] = value,
                            range: [
                              0,
                              double.parse(widget.defaultParameters![key].toString())
                            ],
                            initialValue: value,
                            prefixText: '$paramName: ',
                            controller: widget.controllers[idx],
                          );
                        }

                        if (difficultyManager.difficulty == Difficulty.advanced) {
                          editField = DoubleTextFieldWidget(
                            disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                            callback: (value) => widget.parameterFields[idx] = value,
                            initialValue: value,
                            prefixText: '$paramName: ',
                            controller: widget.controllers[idx],
                          );
                        }
                      }

                      if (dataType == List<double>) {
                        // Initial value can be a double, integer or list.
                        // If the initial value is not a list, the value is cast to a double to prevent an exception.
                        dynamic value = widget.parameters![key];
                        if (value is! List) value = value.toDouble();

                        if (difficultyManager.difficulty == Difficulty.beginner) {}

                        if (difficultyManager.difficulty == Difficulty.advanced) {
                          editField = DynamicDoubleArrayField(
                            disabled: tableHandler.restrictionsManager.getWriteRestrictions(difficultyManager.stringDifficulty, widget.parameterKey, key),
                            callback: (value) => widget.parameterFields[idx] = value,
                            value: value,
                            fieldText: '$paramName: ',
                            controller: widget.controllers[idx],
                            length: tableHandler.restrictionsManager.getRangeRestrictions(
                              widget.parameterKey,
                              key,
                            ),
                          );
                        }
                      }
                    }

                    return editField;
                  },
                ),
              );
  }
}

/// Custom [AppBar] widget for parameter view page
class ParameterAppBar extends StatelessWidget {
  final void Function() removePropertyCallback;
  final void Function() addPropertyCallback;
  final bool hasParamField;
  final String title;
  const ParameterAppBar({super.key, required this.title, required this.removePropertyCallback, required this.addPropertyCallback, required this.hasParamField});

  @override
  Widget build(BuildContext context) {
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);

    /// This appbar has the following structure:
    /// Row
    /// ---Return Button
    /// ---Add component
    /// ---Delete component

    return AppBar(
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(title),
        ),
      ),
      elevation: 0,
      actions: [
        Visibility(
          visible: difficultyManager.difficulty == Difficulty.advanced,
          child: IconButton(
            onPressed: () {
              addPropertyCallback();
            },
            icon: const Icon(
              Icons.add_card,
              color: Global.tertiary,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        // Delete button only visible when there are parameters to delete
        Visibility(
          visible: hasParamField && difficultyManager.difficulty == Difficulty.advanced,
          child: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (conetext) {
                    return AlertDialog(
                      content: const Text('Are you sure you wish to delete this set of parameters?'),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              removePropertyCallback();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Yes, I\'m sure',
                              style: TextStyle(color: Global.tertiary),
                            )),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'No, don\'t delete',
                              style: TextStyle(color: Global.tertiary),
                            ))
                      ],
                    );
                  });
            },
            icon: const Icon(
              Icons.delete,
              color: Global.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}
