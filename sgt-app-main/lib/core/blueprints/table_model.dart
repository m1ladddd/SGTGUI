/// Abstract class containing all preset of the table sections.
/// moduleLocations  and lineLocations are the exact pixel locations
/// of a module in the original image with no scaling applied.
/// Next the line orientation are also defined.
/// This will be the rotation of a given line on the screen.
abstract class TableFrame {
  static const List tableSections = [
    {
      "maxNumModules": 0,
      "numLines": 0,
      "tableIndexRemapped": -1,
      "tableIndex": 0,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [],
      "lineRotation": []
    },
    {
      "maxNumModules": 4,
      "numLines": 8,
      "tableIndexRemapped": 1,
      "tableIndex": 1,
      "moduleIndexRemapped": [
        5,
        1,
        3,
        0
      ],
      "moduleLocations": [
        [
          80.0,
          70.0
        ],
        [
          280.0,
          70.0
        ],
        [
          240.0,
          329.0
        ],
        [
          120.0,
          329.0
        ]
      ],
      "lineLocations": [
        [
          80.0,
          127.5
        ],
        [
          100.0,
          160.0
        ],
        [
          152.5,
          160.0
        ],
        [
          207.5,
          160.0
        ],
        [
          260.0,
          160.0
        ],
        [
          280.0,
          127.5
        ],
        [
          120.0,
          232.0
        ],
        [
          240.0,
          232.0
        ]
      ],
      "lineRotation": [
        90.0,
        0.0,
        0.0,
        0.0,
        0.0,
        90.0,
        90.0,
        90.0,
      ]
    },
    {
      "maxNumModules": 0,
      "numLines": 0,
      "tableIndexRemapped": -1,
      "tableIndex": 2,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [],
      "lineRotation": []
    },
    {
      "maxNumModules": 8,
      "numLines": 16,
      "tableIndexRemapped": 5,
      "tableIndex": 3,
      "moduleIndexRemapped": [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7
      ],
      "moduleLocations": [
        [
          329.0,
          180.0
        ],
        [
          299.0,
          299.0
        ],
        [
          180.0,
          329.0
        ],
        [
          61.0,
          299.0
        ],
        [
          31.0,
          180.0
        ],
        [
          61.0,
          61.0
        ],
        [
          180.0,
          31.0
        ],
        [
          299.0,
          61.0
        ],
      ],
      "lineLocations": [
        [
          269.5,
          180.0
        ],
        [
          235.0,
          207.5
        ],
        [
          254.5,
          254.5
        ],
        [
          207.5,
          235.0
        ],
        [
          180.0,
          269.5
        ],
        [
          152.5,
          235.0
        ],
        [
          105.5,
          254.5
        ],
        [
          125.0,
          207.5
        ],
        [
          90.5,
          180.0
        ],
        [
          125.0,
          152.5
        ],
        [
          105.5,
          105.5
        ],
        [
          152.5,
          125.0
        ],
        [
          180.0,
          90.5
        ],
        [
          207.5,
          125.0
        ],
        [
          254.5,
          105.5
        ],
        [
          235.0,
          152.5
        ]
      ],
      "lineRotation": [
        0.0,
        90.0,
        45.0,
        0.0,
        90.0,
        0.0,
        135.0,
        90.0,
        0.0,
        90.0,
        45.0,
        0.0,
        90.0,
        0.0,
        135.0,
        90.0
      ]
    },
    {
      "maxNumModules": 0,
      "numLines": 16,
      "tableIndexRemapped": 2,
      "tableIndex": 4,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [
        [
          120.0,
          30.0
        ],
        [
          180.0,
          65.0
        ],
        [
          240.0,
          30.0
        ],
        [
          267.5,
          65.0
        ],
        [
          295.0,
          122.5
        ],
        [
          330.0,
          180.0
        ],
        [
          295.0,
          237.5
        ],
        [
          267.5,
          295.0
        ],
        [
          240.0,
          330.0
        ],
        [
          180.0,
          295.0
        ],
        [
          120.0,
          330.0
        ],
        [
          92.5,
          295.0
        ],
        [
          65.0,
          237.5
        ],
        [
          30.0,
          180.0
        ],
        [
          65.0,
          122.5
        ],
        [
          92.5,
          65.0
        ]
      ],
      "lineRotation": [
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0
      ]
    },
    {
      "maxNumModules": 8,
      "numLines": 16,
      "tableIndexRemapped": 6,
      "tableIndex": 5,
      "moduleIndexRemapped": [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7
      ],
      "moduleLocations": [
        [
          31.0,
          180.0
        ],
        [
          61.0,
          61.0
        ],
        [
          180.0,
          31.0
        ],
        [
          299.0,
          61.0
        ],
        [
          329.0,
          180.0
        ],
        [
          299.0,
          299.0
        ],
        [
          180.0,
          329.0
        ],
        [
          61.0,
          299.0
        ],
      ],
      "lineLocations": [
        [
          269.5,
          180.0
        ],
        [
          235.0,
          207.5
        ],
        [
          254.5,
          254.5
        ],
        [
          207.5,
          235.0
        ],
        [
          180.0,
          269.5
        ],
        [
          152.5,
          235.0
        ],
        [
          105.5,
          254.5
        ],
        [
          125.0,
          207.5
        ],
        [
          90.5,
          180.0
        ],
        [
          125.0,
          152.5
        ],
        [
          105.5,
          105.5
        ],
        [
          152.5,
          125.0
        ],
        [
          180.0,
          90.5
        ],
        [
          207.5,
          125.0
        ],
        [
          254.5,
          105.5
        ],
        [
          235.0,
          152.5
        ]
      ],
      "lineRotation": [
        0.0,
        90.0,
        45.0,
        0.0,
        90.0,
        0.0,
        135.0,
        90.0,
        0.0,
        90.0,
        45.0,
        0.0,
        90.0,
        0.0,
        135.0,
        90.0
      ]
    },
    {
      "maxNumModules": 0,
      "numLines": 0,
      "tableIndexRemapped": -1,
      "tableIndex": 6,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [],
      "lineRotation": []
    },
    {
      "maxNumModules": 8,
      "numLines": 19,
      "tableIndexRemapped": 3,
      "tableIndex": 7,
      "moduleIndexRemapped": [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7
      ],
      "moduleLocations": [
        [
          310.0,
          110.0
        ],
        [
          310.0,
          180.0
        ],
        [
          310.0,
          250.0
        ],
        [
          310.0,
          320.0
        ],
        [
          50.0,
          320.0
        ],
        [
          50.0,
          250.0
        ],
        [
          50.0,
          180.0
        ],
        [
          50.0,
          110.0
        ],
      ],
      "lineLocations": [
        [
          120.0,
          52.5
        ],
        [
          240.0,
          52.5
        ],
        [
          262.5,
          110.0
        ],
        [
          240.0,
          145.0
        ],
        [
          262.5,
          180.0
        ],
        [
          240.0,
          215.0
        ],
        [
          262.5,
          250.0
        ],
        [
          240.0,
          285.0
        ],
        [
          262.5,
          320.0
        ],
        [
          210.0,
          320.0
        ],
        [
          180.0,
          342.5
        ],
        [
          150.0,
          320.0
        ],
        [
          97.5,
          320.0
        ],
        [
          120.0,
          285.0
        ],
        [
          97.5,
          250.0
        ],
        [
          120.0,
          215.0
        ],
        [
          97.5,
          180.0
        ],
        [
          120.0,
          145.0
        ],
        [
          97.5,
          110.0
        ],
      ],
      "lineRotation": [
        90.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        0.0,
        90.0,
        0.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0,
        90.0,
        0.0
      ]
    },
    {
      "maxNumModules": 0,
      "numLines": 0,
      "tableIndexRemapped": -1,
      "tableIndex": 8,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [],
      "lineRotation": []
    },
    {
      "maxNumModules": 0,
      "numLines": 0,
      "tableIndexRemapped": -1,
      "tableIndex": 9,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [],
      "lineRotation": []
    },
    {
      "maxNumModules": 8,
      "numLines": 16,
      "tableIndexRemapped": 4,
      "tableIndex": 10,
      "moduleIndexRemapped": [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7
      ],
      "moduleLocations": [
        [
          180.0,
          31.0
        ],
        [
          299.0,
          61.0
        ],
        [
          329.0,
          180.0
        ],
        [
          299.0,
          299.0
        ],
        [
          180.0,
          329.0
        ],
        [
          61.0,
          299.0
        ],
        [
          31.0,
          180.0
        ],
        [
          61.0,
          61.0
        ],
      ],
      "lineLocations": [
        [
          269.5,
          180.0
        ],
        [
          235.0,
          207.5
        ],
        [
          254.5,
          254.5
        ],
        [
          207.5,
          235.0
        ],
        [
          180.0,
          269.5
        ],
        [
          152.5,
          235.0
        ],
        [
          105.5,
          254.5
        ],
        [
          125.0,
          207.5
        ],
        [
          90.5,
          180.0
        ],
        [
          125.0,
          152.5
        ],
        [
          105.5,
          105.5
        ],
        [
          152.5,
          125.0
        ],
        [
          180.0,
          90.5
        ],
        [
          207.5,
          125.0
        ],
        [
          254.5,
          105.5
        ],
        [
          235.0,
          152.5
        ]
      ],
      "lineRotation": [
        0.0,
        90.0,
        45.0,
        0.0,
        90.0,
        0.0,
        135.0,
        90.0,
        0.0,
        90.0,
        45.0,
        0.0,
        90.0,
        0.0,
        135.0,
        90.0
      ]
    },
    {
      "maxNumModules": 0,
      "numLines": 0,
      "tableIndexRemapped": -1,
      "tableIndex": 11,
      "moduleIndexRemapped": [],
      "moduleLocations": [],
      "lineLocations": [],
      "lineRotation": []
    },
  ];
}
