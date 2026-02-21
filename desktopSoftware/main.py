from threading import *
import time
from PySide6.QtCore import *

import device
import interface

exiting:bool = False
listenThread:Thread
updatesSinceLastCount:int = 0
lastConnectAttemptTime:float = 0
lastUPSTime:float = 0
needsTableUpdate:bool = False
lastGraphTime = time.time()
posGraphBuffer:list[tuple[float, float]] = []
velGraphBuffer:list[tuple[float, float]] = []
dutyGraphBuffer:list[tuple[float, float]] = []
errorGraphBuffer:list[tuple[float, float]] = []

@Slot()
def update()->None:
    global updatesSinceLastCount, lastConnectAttemptTime, lastUPSTime, needsTableUpdate, posGraphBuffer, lastGraphTime, velGraphBuffer, errorGraphBuffer
    
    if not interface.hasGUIStarted():
        return
    
    if not device.isConnected() and time.time() - lastConnectAttemptTime >= 2:
        lastConnectAttemptTime = time.time()
        
        if device.connect("COM6", 115200):
            lastConnectAttemptTime = 0
            lastUPSTime = time.time()
            updatesSinceLastCount = 0
            
            listenThread.start()
            
            interface.updateConnectionStatus(True, device.getConnectionPort())
        else:
            interface.updateConnectionStatus(False, None)
            interface.updateUPS(None)
            
            return
    
    if time.time() - lastUPSTime >= 1:
        lastUPSTime += 1
        interface.updateUPS(updatesSinceLastCount)
        updatesSinceLastCount = 0
    
    state = device.getDeviceState()
    if state is not None:
        if state.lastTimestampMillis is not None:
            secs = state.lastTimestampMillis / 1000
            
            if state.positionTicks is not None:
                posGraphBuffer.append((secs, state.positionTicks))
            if state.velocityTicksPerSecond is not None:
                velGraphBuffer.append((secs, state.velocityTicksPerSecond))
            if state.commandedOutput is not None:
                dutyGraphBuffer.append((secs, state.commandedOutput))
            if state.error is not None:
                errorGraphBuffer.append((secs, state.error))
            
            if time.time() - lastGraphTime >= 0.1:
                for point in posGraphBuffer:
                    interface.addPositionGraphReading(point[0], point[1])
                for point in velGraphBuffer:
                    interface.addVelocityGraphReading(point[0], point[1])
                for point in dutyGraphBuffer:
                    interface.addDutyCycleGraphReading(point[0], point[1])
                for point in errorGraphBuffer:
                    interface.addErrorGraphReading(point[0], point[1])
                
                interface.refitPosVelGraph(secs)
                interface.refitDutyGraph(secs)
                interface.refitErrorGraph(secs)
                
                posGraphBuffer.clear()
                velGraphBuffer.clear()
                dutyGraphBuffer.clear()
                errorGraphBuffer.clear()
                lastGraphTime = time.time()
    
    if needsTableUpdate:
        interface.updateTableFromDeviceState(state)
        needsTableUpdate = False
    
    interface.updateConsole()

def onDataReceived()->None:
    global updatesSinceLastCount, needsTableUpdate
    
    updatesSinceLastCount += 1
    needsTableUpdate = True

def onDeviceResponse(resp:device.DeviceResponse)->None:
    if resp.ok:
        interface.consoleInfo(f"[Device] {resp.toString()}")
    else:
        if resp.severity == device.DeviceBadFrameSeverity.WARNING:
            interface.consoleWarning(f"[Device] {resp.toString()}")
        else:
            interface.consoleError(f"[Device] {resp.toString()}")

if __name__ == "__main__":
    interface.setupGUI(update)
    listenThread = Thread(target=device.listenLoop, args=[lambda: exiting, onDeviceResponse, onDataReceived], daemon=True)
    
    try:
        interface.startGUI()
    except KeyboardInterrupt:
        pass
    
    exiting = True
    if listenThread is not None and listenThread.is_alive():
        listenThread.join()
    
    if device.isConnected():
        device.setControlMode(device.DeviceControlMode.NONE)
        device.setEnabled(False)
    device.disconnect()
