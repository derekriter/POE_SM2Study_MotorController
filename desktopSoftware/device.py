from serial import *
import json
from collections.abc import Callable
from enum import Enum, unique

import interface

@unique
class DeviceControlMode(Enum):
    NONE = 0
    DUTY_CYCLE = 1
    VOLTAGE = 2
    PID_POSITION = 3
    PID_VELOCITY = 4
    TRAP_POSITION = 5

class DeviceState:
    def __init__(self):
        self.enabled:(bool | None) = None
        self.sourceVoltage:(float | None) = None
        self.controlMode:(DeviceControlMode | None) = None
        self.controlRef:(float | None) = None
        self.positionTicks:(int | None) = None
        self.positionRots:(float | None) = None
        self.velocityTicksPerSecond:(float | None) = None
        self.velocityRPM:(float | None) = None
        self.lastTimestampMillis:(int | None) = None
        self.commandedOutput:(float | None) = None
        self.error:(float | None) = None

@unique
class DeviceBadFrameSeverity(Enum):
    WARNING = 0
    ERROR = 1

class DeviceResponse:
    def __init__(self):
        self.ok:bool = True
        self.message:(str | None) = None
        self.severity:(DeviceBadFrameSeverity | None) = None
    
    def toString(self)->str:
        if self.ok:
            return "OK"
        else:
            return "No message given" if self.message is None else self.message

_device:(Serial | None) = None
_deviceState:(DeviceState | None) = None

def connect(port:str, baud:int)->bool:
    global _device, _deviceState
    
    try:
        _device = Serial(port=port, baudrate=baud, timeout=0.05)
    except SerialException:
        interface.consoleError(f"failed to connect to device on port {port}")
        return False
    
    _deviceState = None
    interface.consoleInfo(f"Connected to device on port {port}")
    return True

def disconnect()->None:
    global _device, _deviceState
    
    if _device is None or not _device.is_open:
        return
    
    try:
        _device.flush()
        _device.close()
        interface.consoleInfo("Disconnected from the device")
    except SerialException:
        interface.consoleWarning("Failed to flush and close, device may not be connected")
        interface.consoleError("Failed to disconnect from the device")
    finally:
        _device = None
        _deviceState = None

def isConnected()->bool:
    return _device is not None and _device.is_open

def getConnectionPort()->(str | None):
    if isConnected():
        return _device.port
    else:
        return None

def getDeviceState()->(DeviceState | None):
    return _deviceState if isConnected() else None

def _getMessageIfAvailable()->(bytes | None):
    if _device is None or not _device.is_open or not _device.readable():
        interface.consoleWarning("Cannot listen to device until a readable device connection is established")
        return None
    
    raw:bytes
    try:
        raw = _device.readline()
    except SerialException:
        interface.consoleWarning("Failed to readline, device may not be connected")
        return None
    if len(raw) == 0:
        return None
    
    return raw

def _parseFrameIfValid(msg:bytes)->(dict | None):
    parsed:any
    try:
        parsed = json.loads(msg)
    except:
        return None
    if not isinstance(parsed, dict):
        return None
    
    if "ty" not in parsed.keys():
        interface.consoleError("Frame has invalid structure")
        return None
    
    return parsed

def _processDataFrame(payload:dict)->None:
    global _deviceState
    
    if _deviceState is None:
        _deviceState = DeviceState()
    
    if "en" in payload.keys():
        if not isinstance(payload["en"], bool):
            interface.consoleError(f"'en' data of '{payload["en"]}' must be of type bool")
        else:
            _deviceState.enabled = payload["en"]
    
    if "sv" in payload.keys():
        if not isinstance(payload["sv"], float):
            interface.consoleError(f"'sv' data of '{payload["sv"]}' must be of type float")
        else:
            _deviceState.sourceVoltage = payload["sv"]
    
    if "cm" in payload.keys():
        if not isinstance(payload["cm"], int):
            interface.consoleError(f"'cm' data of '{payload["cm"]}' must be of type int")
        else:
            try:
                _deviceState.controlMode = DeviceControlMode(payload["cm"])
            except ValueError:
                interface.consoleError(f"'cm' data of '{payload["cm"]}' is not a valid control mode")
    
    if "cr" in payload.keys():
        if not isinstance(payload["cr"], float):
            interface.consoleError(f"'cr' data of '{payload['cr']}' must be of type float")
        else:
            _deviceState.controlRef = payload["cr"]
    
    if "pt" in payload.keys():
        if not isinstance(payload["pt"], int):
            interface.consoleError(f"'pt' data of '{payload["pt"]}' must be of type int")
        else:
            _deviceState.positionTicks = payload["pt"]
    
    if "pr" in payload.keys():
        if not isinstance(payload["pr"], float):
            interface.consoleError(f"'pr' data of '{payload["pr"]}' must be of type float")
        else:
            _deviceState.positionRots = payload["pr"]
    
    if "vt" in payload.keys():
        if not isinstance(payload["vt"], float):
            interface.consoleError(f"'vt' data of '{payload["vt"]}' must be of type float")
        else:
            _deviceState.velocityTicksPerSecond = payload["vt"]
    
    if "vr" in payload.keys():
        if not isinstance(payload["vr"], float):
            interface.consoleError(f"'vr' data of '{payload["vr"]}' must be of type float")
        else:
            _deviceState.velocityRPM = payload["vr"]
    
    if "ms" in payload.keys():
        if not isinstance(payload["ms"], int):
            interface.consoleError(f"'ms' data of '{payload["ms"]}' must be of type int")
        else:
            _deviceState.lastTimestampMillis = payload["ms"]
    
    if "co" in payload.keys():
        if not isinstance(payload["co"], float):
            interface.consoleError(f"'co' data of '{payload["co"]}' must be of type float")
        else:
            _deviceState.commandedOutput = payload["co"]
    
    if "er" in payload.keys():
        if not isinstance(payload["er"], float):
            interface.consoleError(f"'er' data of '{payload["er"]}' must be of type float")
        else:
            _deviceState.error = payload["er"]

def _processMsgFrame(payload:str)->None:
    interface.consoleInfo(f"[Device] {payload}")
    # print(f"MSG: {payload}")

def _processOKFrame(onResponse:Callable[[DeviceResponse], None])->None:
    resp:DeviceResponse = DeviceResponse()
    resp.ok = True
    resp.message = None
    resp.severity = None
    
    onResponse(resp)

def _processBadFrame(payload:dict, onResponse:Callable[[DeviceResponse], None])->None:
    if "sv" not in payload.keys():
        interface.consoleError("'sv' missing from bad frame payload")
        return
    if not isinstance(payload["sv"], int):
        interface.consoleError(f"'sv' data of '{payload["sv"]}' must be of type int")
        return
    if "msg" not in payload.keys():
        interface.consoleError("'msg' missing from bad frame payload")
        return
    if not isinstance(payload["msg"], str):
        interface.consoleError(f"'msg' data of '{payload["msg"]}' must be of type str in bad frame payload")
        return
    
    severity:DeviceBadFrameSeverity
    try:
        severity = DeviceBadFrameSeverity(payload["sv"])
    except ValueError:
        interface.consoleError(f"'sv' data of '{payload["sv"]}' is not a valid severity")
        return
    
    resp:DeviceResponse = DeviceResponse()
    resp.ok = False
    resp.message = payload["msg"]
    resp.severity = severity
    
    onResponse(resp)

def _processFrame(frame:dict, onResponse:Callable[[DeviceResponse], None], onDataReceived:Callable[[], None])->None:
    match frame["ty"]:
        case "data":
            if "py" not in frame.keys() or not isinstance(frame["py"], dict):
                interface.consoleError("invalid payload on data frame")
                return
            
            _processDataFrame(frame["py"])
            onDataReceived()
        case "msg":
            if "py" not in frame.keys() or not isinstance(frame["py"], str):
                interface.consoleError("invalid payload on msg frame")
                return
            
            _processMsgFrame(frame["py"])
        case "ok":
            _processOKFrame(onResponse)
        case "bad":
            if "py" not in frame.keys() or not isinstance(frame["py"], dict):
                interface.consoleError("invalid payload on bad frame")
                return
            
            _processBadFrame(frame["py"], onResponse)
        case _:
            interface.consoleError(f"frame was unknown type '{frame["ty"]}'")

def listenLoop(shouldClose:Callable[[], bool], onResponse:Callable[[DeviceResponse], None], onDataReceived:Callable[[], None])->None:
    while not shouldClose():
        data:(bytes | None) = _getMessageIfAvailable()
        if data is None or len(data) == 0:
            continue
        
        frame:(dict | None) = _parseFrameIfValid(data)
        if frame is None:
            continue
        
        _processFrame(frame, onResponse, onDataReceived)

def _sendMessage(msg:bytes)->bool:
    if _device is None or not _device.is_open or not _device.writable():
        interface.consoleWarning("Cannot send message to device until a writeable device connection is established")
        return False
    
    try:
        _device.write(msg)
    except SerialTimeoutException:
        interface.consoleWarning("Timed out while sending message to device")
        return False
    except SerialException:
        interface.consoleWarning("Failed to write, device may not be connected")
        return False
    
    return True

def _sendString(msg:str)->bool:
    return _sendMessage((msg + "\0").encode("utf-8", "replace"))

def setEnabled(enabled:bool)->bool:
    return _sendString("enable" if enabled else "disable")

def setControlMode(mode:DeviceControlMode)->bool:
    match mode:
        case DeviceControlMode.NONE:
            return _sendString("stop")
        case DeviceControlMode.DUTY_CYCLE:
            return _sendString("dutyCycle")
        case DeviceControlMode.VOLTAGE:
            return _sendString("voltage")
        case DeviceControlMode.PID_POSITION:
            return _sendString("pidPos")
        case DeviceControlMode.PID_VELOCITY:
            return _sendString("pidVel")
        case DeviceControlMode.TRAP_POSITION:
            return _sendString("trapPos")
        case _:
            interface.consoleError(f"Cannot set device control mode to unknown mode '{mode}'")

def setControlReference(ref:float)->bool:
    return _sendString("ref {:.4f}".format(ref))

def setKP(kP:float)->bool:
    return _sendString("kP {:.8f}".format(kP))

def setKI(kI:float)->bool:
    return _sendString("kI {:.8f}".format(kI))

def setKD(kD:float)->bool:
    return _sendString("kD {:.8f}".format(kD))

def setKS(kS:float)->bool:
    return _sendString("kS {:.8f}".format(kS))

def setVmax(vMax:float)->bool:
    return _sendString("vMax {:.2f}".format(vMax))

def setAstart(aStart:float)->bool:
    return _sendString("aStart {:.2f}".format(aStart))

def setAend(aEnd:float)->bool:
    return _sendString("aEnd {:.2f}".format(aEnd))
