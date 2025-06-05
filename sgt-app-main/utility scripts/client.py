import paho.mqtt.client as mqtt
import uuid
import time
import json
import os
import socket
import copy
from broadcaster import Broadcaster
import dictdiffer

# We take the local ip address and put it as local broker.
# (the broker server need to run on the same computer than the one executing the code).
## Socket used to retrieve local IP.
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))

## Local IP of the computer executing the program.
local_broker_ip = s.getsockname()[0]
print(f'Broker IP {local_broker_ip}')

host_name = str(local_broker_ip)
port = 1883

outTopic = 'SmartDemoTable2/GUI/Ingoing'
inTopic = 'SmartDemoTable2/GUI/Outgoing'

protocol_version =  "v000"
opcode = "o000"

## UDP broadcast message structure
## [protocol id - 4 bytes]
## [opcode      - 4 bytes]
## [IP address  - string of variable lenght, NULL terminated]
message = protocol_version + opcode + str(local_broker_ip)

# Add NULL terminator at end of IP address.
# EPS32 boards uses raw char types and only supports NULL terminated strings.
stringLenght = len(message)
message = message[:stringLenght] + '\0' + message[stringLenght + 1:]

udp_broadcaster = Broadcaster()
udp_broadcaster.set_interval(0.2)
udp_broadcaster.set_port(5005)
udp_broadcaster.set_message(message.encode('UTF-8'))
udp_broadcaster.start_broadcasting()

with open('static/Scenario1_default.json') as f:
    static_orig_json = json.load(f)
    f.close()

static_session_json = copy.copy(static_orig_json)

with open('static/module_config.json') as f:
    static_module_restrictions = json.load(f)

static_scenarios = ['Default', 'Winter', 'Summer', 'EV', 'Night', 'Demo']

with open('dynamic/Scenario1_default.json') as f:
    dynamic_orig_json = json.load(f)
    f.close()

dynamic_session_json = copy.copy(dynamic_orig_json)

with open('dynamic/module_config.json') as f:
    dynamic_module_restrictions = json.load(f)

dynamic_scenarios = ['Winter', 'Summer', 'EV', 'Night', 'Demo']

orig_json = copy.copy(static_orig_json)
session_json = copy.copy(static_session_json)
module_restrictions = copy.copy(static_module_restrictions)

orig_properties_msg = {"type": "SCENARIO_JSON", "payload": {"scenario_json": orig_json, "is_static": True}}
sesion_properties_msg = {"type": "SCENARIO_JSON", "payload": {"scenario_json": session_json, "is_static": True}}
restrictions_msg = {"type": "RESTRICTIONS_JSON", "payload": module_restrictions}

module_update_msgs = {"type": "MODULE_UPDATE", "payload": {"table_section": 4, "module_location": 5, "module_id": "1071771887"}}
module_update_msgs2 = {"type": "MODULE_UPDATE", "payload": {"table_section": 4, "module_location": 5, "module_id": "0"}}
module_update_msgs3 = {"type": "MODULE_UPDATE", "payload": {"table_section": 4, "module_location": 6, "module_id": "1071780135"}}
module_update_msgs4 = {"type": "MODULE_UPDATE", "payload": {"table_section": 4, "module_location": 6, "module_id": "0"}}
module_update_msgs5 = {"type": "MODULE_UPDATE", "payload": {"table_section": 4, "module_location": 7, "module_id": "1071766506"}}
module_update_msgs6 = {"type": "MODULE_UPDATE", "payload": {"table_section": 4, "module_location": 7, "module_id": "0"}}

multi_line_update_msg  = {
    "type": "LINE_UPDATE", 
    "payload": [
        {
            "table": 4,
            "line": 2,
            "active": True
        },
        {
            "table": 4,
            "line": 3,
            "active": True
        },
        {
            "table": 4,
            "line": 4,
            "active": False
        },
        {
            "table": 4,
            "line": 5,
            "active": True
        },
        {
            "table": 4,
            "line": 6,
            "active": False
        }
    ]
}

scenarioStatic = True

capacity_graphs = {
    'transformerCapacityGraphs': {
        'Transformer 1 Current Power': [47.71,52.36,38.1,43.2,11.48,59.83,50.7,24.54,36.14,48.29,30.47,42.93,33,55.08,36.97,23.24,19.6,41.78,59.9,10.33,27.12,3.62,35.27,35.4],
        'Transformer 1 Maximum Power': [53.98,32.84,17.57,13.21,59.87,50.56,4.4,59.68,41.2,9.32,56.78,21.09,26.63,30.64,42.08,53.13,7.31,16.91,18.18,56.63,39.78,3.94,53.55,35.14],
        'Transformer 2 Current Power': [7.19,25.93,23.06,4.81,36.13,53.8,15.1,10.26,47.79,59.58,39.78,33.35,59.95,55.14,37.66,16.27,24.49,12.25,36.65,20.41,3.3,53.75,47.8,56.19],
        'Transformer 2 Maximum Power': [41.75,13.36,20.71,14.82,13.23,57,56.25,5.72,21.5,54.22,25.02,25.51,35.01,21.42,16.66,22.2,14.43,27.26,50.37,7.86,45.05,51.18,53.62,54.95],
        'Transformer 3 Current Power': [20.38,10.47,14.13,33.33,22.7,24.31,3.42,40.25,21.46,23.47,17.26,34.75,14.64,20.78,56.17,29.94,57.4,56.67,36.03,31.81,10.59,57.68,7.98,57.79],
        'Transformer 3 Maximum Power': [19.42,4.92,36.3,9.5,49.66,56.52,56.2,54.34,56.11,27.02,4.12,36.28,40.19,40.59,29.62,46.81,27.55,11.57,54.34,13.34,31.58,11.94,34.11,25.52]
    },
    'powerPerTableSection': {
        'Table Section 1 Load': [47.71,52.36,38.1,43.2,11.48,59.83,50.7,24.54,36.14,48.29,30.47,42.93,33,55.08,36.97,23.24,19.6,41.78,59.9,10.33,27.12,3.62,35.27,35.4],
        'Table Section 2 Load': [53.98,32.84,17.57,13.21,59.87,50.56,4.4,59.68,41.2,9.32,56.78,21.09,26.63,30.64,42.08,53.13,7.31,16.91,18.18,56.63,39.78,3.94,53.55,35.14],
        'Table Section 3 Load': [7.19,25.93,23.06,4.81,36.13,53.8,15.1,10.26,47.79,59.58,39.78,33.35,59.95,55.14,37.66,16.27,24.49,12.25,36.65,20.41,3.3,53.75,47.8,56.19],
        'Table Section 4 Load': [41.75,13.36,20.71,14.82,13.23,57,56.25,5.72,21.5,54.22,25.02,25.51,35.01,21.42,16.66,22.2,14.43,27.26,50.37,7.86,45.05,51.18,53.62,54.95],
        'Table Section 5 Load': [20.38,10.47,14.13,33.33,22.7,24.31,3.42,40.25,21.46,23.47,17.26,34.75,14.64,20.78,56.17,29.94,57.4,56.67,36.03,31.81,10.59,57.68,7.98,57.79],
        'Table Section 6 Load': [19.42,4.92,36.3,9.5,49.66,56.52,56.2,54.34,56.11,27.02,4.12,36.28,40.19,40.59,29.62,46.81,27.55,11.57,54.34,13.34,31.58,11.94,34.11,25.52],
        'Table Section 1 Generation': [47.71,52.36,38.1,43.2,11.48,59.83,50.7,24.54,36.14,48.29,30.47,42.93,33,55.08,36.97,23.24,19.6,41.78,59.9,10.33,27.12,3.62,35.27,35.4],
        'Table Section 2 Generation': [53.98,32.84,17.57,13.21,59.87,50.56,4.4,59.68,41.2,9.32,56.78,21.09,26.63,30.64,42.08,53.13,7.31,16.91,18.18,56.63,39.78,3.94,53.55,35.14],
        'Table Section 3 Generation': [7.19,25.93,23.06,4.81,36.13,53.8,15.1,10.26,47.79,59.58,39.78,33.35,59.95,55.14,37.66,16.27,24.49,12.25,36.65,20.41,3.3,53.75,47.8,56.19],
        'Table Section 4 Generation': [41.75,13.36,20.71,14.82,13.23,57,56.25,5.72,21.5,54.22,25.02,25.51,35.01,21.42,16.66,22.2,14.43,27.26,50.37,7.86,45.05,51.18,53.62,54.95],
        'Table Section 5 Generation': [20.38,10.47,14.13,33.33,22.7,24.31,3.42,40.25,21.46,23.47,17.26,34.75,14.64,20.78,56.17,29.94,57.4,56.67,36.03,31.81,10.59,57.68,7.98,57.79],
        'Table Section 6 Generation': [19.42,4.92,36.3,9.5,49.66,56.52,56.2,54.34,56.11,27.02,4.12,36.28,40.19,40.59,29.62,46.81,27.55,11.57,54.34,13.34,31.58,11.94,34.11,25.52]
    },
    'powerPerVoltageLevel': {
        'LV Load': [47.71,52.36,38.1,43.2,11.48,59.83,50.7,24.54,36.14,48.29,30.47,42.93,33,55.08,36.97,23.24,19.6,41.78,59.9,10.33,27.12,3.62,35.27,35.4],
        'MV Load': [53.98,32.84,17.57,13.21,59.87,50.56,4.4,59.68,41.2,9.32,56.78,21.09,26.63,30.64,42.08,53.13,7.31,16.91,18.18,56.63,39.78,3.94,53.55,35.14],
        'HV Load': [7.19,25.93,23.06,4.81,36.13,53.8,15.1,10.26,47.79,59.58,39.78,33.35,59.95,55.14,37.66,16.27,24.49,12.25,36.65,20.41,3.3,53.75,47.8,56.19],
        'LV Generation': [41.75,13.36,20.71,14.82,13.23,57,56.25,5.72,21.5,54.22,25.02,25.51,35.01,21.42,16.66,22.2,14.43,27.26,50.37,7.86,45.05,51.18,53.62,54.95],
        'MV Generation': [20.38,10.47,14.13,33.33,22.7,24.31,3.42,40.25,21.46,23.47,17.26,34.75,14.64,20.78,56.17,29.94,57.4,56.67,36.03,31.81,10.59,57.68,7.98,57.79],
        'HV Generation': [19.42,4.92,36.3,9.5,49.66,56.52,56.2,54.34,56.11,27.02,4.12,36.28,40.19,40.59,29.62,46.81,27.55,11.57,54.34,13.34,31.58,11.94,34.11,25.52]
    },
    'powerTotal': {
        'Total Load':       [47.71,52.36,38.1,43.2,11.48,59.83,50.7,24.54,36.14,48.29,30.47,42.93,33,55.08,36.97,23.24,19.6,41.78,59.9,10.33,27.12,3.62,35.27,35.4],
        'Total Generation': [53.98,32.84,17.57,13.21,59.87,50.56,4.4,59.68,41.2,9.32,56.78,21.09,26.63,30.64,42.08,53.13,7.31,16.91,18.18,56.63,39.78,3.94,53.55,35.14],
        'Total Storage':    [7.19,25.93,23.06,4.81,36.13,53.8,15.1,10.26,47.79,59.58,39.78,33.35,59.95,55.14,37.66,16.27,24.49,12.25,36.65,20.41,3.3,53.75,47.8,56.19]
    }
}

capacity_graphs_static = {
    'transformerCapacityGraphs': {
        'Transformer 1': {
            'Capacity Usage': 9.59, 
        },
        'Transformer 2': {
            'Capacity Usage': 9.53,
        },
        'Transformer 3': {
            'Capacity Usage': 44.44, 
        },
        'Transformer 4': {
            'Capacity Usage': 65.08,
        },
    },
    'powerPerTableSection': {
        'Table Section 1': {
            'Load': 24.5,
            'Generation': 40.3
        },
        'Table Section 2': {
            'Load': 10.7,
            'Generation': 30.6
        },
        'Table Section 3': {
            'Load': 50.8,
            'Generation': 15.4
        },
        'Table Section 4': {
            'Load': 24.5,
            'Generation': 40.3
        },
        'Table Section 5': {
            'Load': 10.7,
            'Generation': 30.6,
        },
        'Table Section 6': {
            'Load': 50.8,
            'Generation': 15.4
        },
    },
    'powerPerVoltageLevel': {
        'LV': {
            'Load': 50.8,
            'Generation': 15.4
        },
        'MV': {
            'Load': 24.5,
            'Generation': 40.3
        },
        'HV': {
            'Load': 10.7,
            'Generation': 30.6
        },
    },
    'powerTotal': {
        'Network': {
            'Load': 50.8,
            'Generation': 35.5,
            'Storage': 15.3
        },
    }
}

def get_scenario_list(isStatic):
    if isStatic: 
        return static_scenarios
    else:
        return dynamic_scenarios

def on_message(client, userdata, message):
    global orig_json
    global session_json
    global module_restrictions
    global scenarioStatic

    pt = str(message.payload.decode("utf-8"))
    pt = json.loads(pt)
    print("message received " ,pt)
    # print("message topic=",message.topic)

    if pt['type'] == 'SEND_SCENARIO_JSON':
        client.publish(outTopic, json.dumps(orig_properties_msg))

        changed_ids = []
        # Difference between original json and session
        for diff in list(dictdiffer.diff(session_json,orig_json)):         
            if type(diff[1]) == list:
                changed_ids.append(diff[1][0])
            else:
                changed_ids.append(diff[1].split('.')[0])

        updates = {}
        for id in changed_ids:
            updates.update({id: session_json[id]})

        if updates:
            res = {"type": "SCENARIO_UPDATE", "payload": {"scenario_updates": updates}}
            client.publish(outTopic, json.dumps(res))

    
    if pt['type'] == 'SEND_RESTRICTIONS':
        restrictions_msg["payload"] = module_restrictions
        client.publish(outTopic, json.dumps(restrictions_msg))

    if pt['type'] == 'CHANGE_MODULE_PARAMETER':

        updates = {}
        for k,v in pt['payload'].items():
            session_json[k] = v
            print(session_json[k])

            updates.update({k:v})
        
        res = {"type": "SCENARIO_UPDATE", "payload": {"scenario_updates": updates}}
        client.publish(outTopic, json.dumps(res))

    if pt['type'] == 'SEND_ACTIVE_MODULES':
        client.publish(outTopic, payload=json.dumps(module_update_msgs))
        client.publish(outTopic, payload=json.dumps(module_update_msgs3))
        client.publish(outTopic, payload=json.dumps(module_update_msgs5))

    if pt['type'] == 'SEND_LINE_STATUSES':
        client.publish(outTopic, payload=json.dumps(multi_line_update_msg))

    if pt['type'] == 'CHANGE_LINE':
        table = pt['payload']["table"]
        line = pt['payload']["line"]
        active = pt['payload']["active"]

        response = {
            "type": "LINE_UPDATE",
            "payload": [pt['payload']]
        }

        client.publish(outTopic, payload=json.dumps(response))

    if pt['type'] == 'SEND_SCENARIO_LIST':
        scenario_list = get_scenario_list(isStatic = pt['payload']['is_static'])
        response = {"type": "SCENARIO_LIST", "payload": {"scenario_list": scenario_list, "is_static": pt['payload']['is_static']}}

        client.publish(outTopic, json.dumps(response))

    if pt['type'] == 'CHANGE_SCENARIO':
        print('SCENARIO CHANGED!')

        is_static = pt['payload']['is_static']
        scenarioStatic = is_static

        if is_static:
            orig_json = copy.copy(static_orig_json)
            session_json = copy.copy(static_session_json)
            module_restrictions = copy.copy(static_module_restrictions)

        else:
            orig_json = copy.copy(dynamic_orig_json)
            session_json = copy.copy(dynamic_session_json)
            module_restrictions = copy.copy(dynamic_module_restrictions)
            
        orig_json['name'] = pt['payload']['scenario_name']
        orig_properties_msg['payload']['scenario_json'] = orig_json
        orig_properties_msg['payload']['is_static'] = is_static

        client.publish(outTopic, json.dumps(orig_properties_msg))

        restrictions_msg["payload"] = module_restrictions
        client.publish(outTopic, json.dumps(restrictions_msg))

        if scenarioStatic:
            g = capacity_graphs_static
        else:
            g = capacity_graphs

        response = {
            'type': 'NETWORK_SNAPSHOTS', 
            'payload': g
        }
        client.publish(outTopic, json.dumps(response))


    if pt['type'] == 'CHANGE_RESTRICTIONS':
        for change in pt['payload']:
            restrict_type = change['restrictionField']
            userField = change['userField']
            mainField =  change['mainField']
            subField = change['subField']
            value = change['value']

            if userField == None:
                if subField == None:
                    module_restrictions[restrict_type][mainField] = value
                else:
                    module_restrictions[restrict_type][mainField][subField] = value
            else:
                if subField == None:
                    module_restrictions[restrict_type][userField][mainField] = value
                else:
                    module_restrictions[restrict_type][userField][mainField][subField] = value
            
        # Notify other clients of changes made
        res = {"type": "RESTRICTIONS_UPDATE", "payload": pt['payload']}
        client.publish(outTopic, json.dumps(res))

    # Command for sending network snapshots of total generation and consumption.
    if pt['type'] == 'SEND_SNAPSHOTS':
        if scenarioStatic:
            g = capacity_graphs_static
        else:
            g = capacity_graphs

        response = {
            'type': 'NETWORK_SNAPSHOTS', 
            'payload': g
        }
        client.publish(outTopic, json.dumps(response))


client = mqtt.Client(str(uuid.uuid4()))
client.on_message=on_message #attach function to callback
client.connect(host=host_name, port=port)

client.loop_start()
client.subscribe(inTopic)

while True:
    ans = input()

    if ans == 'q':
        break

    if ans == 'u':
        client.publish(outTopic, payload=json.dumps(module_update_msgs))

    if ans == 'i':
        client.publish(outTopic, payload=json.dumps(module_update_msgs2))

    if ans == 'o':
        client.publish(outTopic, payload=json.dumps(module_update_msgs3))

    if ans == 'p':
        client.publish(outTopic, payload=json.dumps(module_update_msgs4))

    if ans == 'y':
        client.publish(outTopic, payload=json.dumps(orig_properties_msg))

    if ans == 'm':
        print(module_restrictions)
    
    
client.loop_stop()

if not os.path.exists('sessions'):
    os.mkdir('sessions')

#with open(f"sessions/session{time.time()}.json", "w+") as outfile:
#    json.dump(session_json, outfile)

udp_broadcaster.stop_broadcasting()
client.disconnect()