from PySide6.QtCore import *
from PySide6.QtWidgets import *
from PySide6.QtGui import *
from PySide6.QtCharts import *
from collections.abc import Callable

from widgets import *
import device

class Root(QFrame):
    def __init__(self):
        super().__init__()
        
        self.header = Header()
        self.graphs = GraphView()
        self.data = DataView()
        self.controls = ControlPanel()
        
        self.consoleContents = Console()
        self.console = QScrollArea()
        self.console.setContentsMargins(0, 0, 10, 0)
        self.console.setFrameShape(QFrame.Shape.NoFrame)
        self.console.setSizePolicy(QSizePolicy.Policy.MinimumExpanding, QSizePolicy.Policy.Ignored)
        self.console.setWidgetResizable(True)
        self.console.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.console.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOn)
        self.console.setWidget(self.consoleContents)
        
        self.middle = QSplitter(Qt.Orientation.Horizontal)
        self.middle.setChildrenCollapsible(False)
        self.middle.setHandleWidth(2)
        self.middle.addWidget(self.graphs)
        self.middle.addWidget(self.data)
        
        self.bottom = QSplitter(Qt.Orientation.Horizontal)
        self.bottom.setChildrenCollapsible(False)
        self.bottom.setHandleWidth(2)
        self.bottom.addWidget(self.controls)
        self.bottom.addWidget(self.console)
        
        self.content = QSplitter(Qt.Orientation.Vertical)
        self.content.setChildrenCollapsible(False)
        self.content.setHandleWidth(2)
        self.content.addWidget(self.middle)
        self.content.addWidget(self.bottom)
        
        splitterPalette = self.middle.handle(1).palette()
        splitterPalette.setColor(self.middle.handle(1).backgroundRole(), Qt.GlobalColor.gray)
        self.middle.handle(1).setPalette(splitterPalette)
        self.bottom.handle(1).setPalette(splitterPalette)
        self.content.handle(1).setPalette(splitterPalette)
        
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(QMargins(0, 0, 0, 0))
        self.layout.setSpacing(0)
        self.layout.addWidget(self.header)
        self.layout.addWidget(self.content)
        
        #https://runebook.dev/en/docs/qt/qsplitter/setSizes
        QTimer.singleShot(0, self._resizeSplitters)
    
    def _resizeSplitters(self):
        middleWidth = self.middle.size().width()
        self.middle.setSizes((middleWidth * 3/4, middleWidth * 1/4))
        
        bottomWidth = self.bottom.size().width()
        self.bottom.setSizes((bottomWidth * 3/4, bottomWidth * 1/4))
        
        contentHeight = self.content.size().height()
        self.content.setSizes((contentHeight * 3/4, contentHeight* 1/4))

class Header(QFrame):
    def __init__(self):
        super().__init__()
        
        self.setStyleSheet("""
            font-size: 11pt;
        """)
        self.setSizePolicy(QSizePolicy.Policy.MinimumExpanding, QSizePolicy.Policy.Maximum)
        self.setFrameShape(QFrame.Shape.StyledPanel)
        self.setFrameShadow(QFrame.Shadow.Plain)
        
        self.connectedText = QLabel("")
        
        self.updatesText = QLabel("", alignment=Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
        
        self.setDisconnected()
        self.setUPS(None)
        
        self.layout = QHBoxLayout(self)
        self.layout.setContentsMargins(QMargins(4, 0, 4, 0))
        self.layout.addWidget(self.connectedText)
        self.layout.addWidget(self.updatesText)
    
    def sizeHint(self)->QSize:
        connectedSize = self.connectedText.sizeHint()
        updatesSize = self.updatesText.sizeHint()
        
        return QSize(connectedSize.width() + updatesSize.width() + 10, max(connectedSize.height(), updatesSize.height()) + 8)
    
    def setDisconnected(self)->None:
        self._setConnectedColor(Qt.GlobalColor.red)
        self.connectedText.setText("Disconnected")
    
    def setConnected(self, port:str)->None:
        self._setConnectedColor(Qt.GlobalColor.green)
        self.connectedText.setText(f"Connected on {port}")
        
    def setUPS(self, ups:int | None)->None:
        self.updatesText.setText(f"UPS: {"-" if ups is None else ups}")
    
    def _setConnectedColor(self, col:int)->None:
        palette = self.connectedText.palette()
        palette.setColor(self.connectedText.foregroundRole(), col)
        self.connectedText.setPalette(palette)

class GraphView(QFrame):
    def __init__(self):
        super().__init__()
        
        self.posVelGraph = LiveGraph(
            title="Position & Velocity v. Time",
            showLegend=False,
            seriesConfigs=[
                SeriesConfig("Position", "#d20f39", "Position (Ticks)", Qt.AlignmentFlag.AlignLeft),
                SeriesConfig("Velocity", "#40a02b", "Velocity (TPS)", Qt.AlignmentFlag.AlignRight),
            ]
        )
        
        self.errorGraph = LiveGraph(
            title="Error v. Time",
            showLegend=False,
            seriesConfigs=[
                SeriesConfig("Error", "#df8e1d", "Error (Ticks)", Qt.AlignmentFlag.AlignLeft)
            ]
        )
        
        self.outGraph = LiveGraph(
            title="Commanded Output v. Time",
            showLegend=False,
            seriesConfigs=[
                SeriesConfig("Duty Cycle", "#8839ef", "Duty Cycle", Qt.AlignmentFlag.AlignLeft)
            ]
        )
        
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(0, 0, 0, 0)
        self.layout.setSpacing(4)
        self.layout.addWidget(self.posVelGraph)
        self.layout.addWidget(self.errorGraph)
        self.layout.addWidget(self.outGraph)

class DataView(QTableWidget):
    def __init__(self):
        self.data:dict[str, str | None] = {
            "Enabled": None,
            "Source Voltage": None,
            "Control Mode": None,
            "Control Reference": None,
            "Commanded Output": None,
            "Position (Ticks)": None,
            "Position (Rots)": None,
            "Velocity (TPS)": None,
            "Velocity (RPM)": None,
            "Last Time Stamp (Millis)": None,
            "Error (Ticks)": None
        }
        
        super().__init__(len(self.data), 2)
        
        self.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        
        self.setSizePolicy(QSizePolicy.Policy.MinimumExpanding, QSizePolicy.Policy.MinimumExpanding)
        self.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        self.verticalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Fixed)
        
        self.setHorizontalHeaderLabels(("Property", "Value"))
        # self.verticalHeader().hide()
        
        self.updateTable()
    
    def updateTable(self)->None:
        for i, (key, val) in enumerate(self.data.items()):
            itemLabel = QTableWidgetItem(key)
            
            itemVal = QTableWidgetItem()
            itemVal.setFont("monospace")
            if val is None:
                itemVal.setText("-")
                itemVal.setTextAlignment(Qt.AlignmentFlag.AlignCenter)
            else:
                itemVal.setText(val)
                itemVal.setTextAlignment(Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
            
            self.setItem(i, 0, itemLabel)
            self.setItem(i, 1, itemVal)

class ControlPanel(QFrame):
    def __init__(self):
        super().__init__()
        
        #enabled
        self.enabledLabel = QLabel("Enabled:")
        
        self.enableButton = QPushButton("Enable")
        self.enableButton.clicked.connect(lambda: device.setEnabled(True))
        self.disableButton = QPushButton("Disable")
        self.disableButton.clicked.connect(lambda: device.setEnabled(False))
        
        self.enableGroup = RadioButtonGroup(1)
        self.enableGroup.addButton(self.enableButton)
        self.enableGroup.addButton(self.disableButton)
        
        self.enabledRow = QHBoxLayout()
        self.enabledRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.enabledRow.addWidget(self.enabledLabel)
        self.enabledRow.addWidget(self.enableGroup)
        
        #mode
        self.modeLabel = QLabel("Control Mode:")
        
        self.modeNoneButton = QPushButton("None")
        self.modeDutyCycleButton = QPushButton("Duty Cycle")
        self.modeVoltageButton = QPushButton("Voltage")
        self.modePIDPosButton = QPushButton("PID Position")
        self.modePIDVelButton = QPushButton("PID Velocity")
        self.modeTrapPosButton = QPushButton("Trap. Profile Position")
        
        self.modeGroup = RadioButtonGroup(0)
        self.modeGroup.addButton(self.modeNoneButton)
        self.modeGroup.addButton(self.modeDutyCycleButton)
        self.modeGroup.addButton(self.modeVoltageButton)
        self.modeGroup.addButton(self.modePIDPosButton)
        self.modeGroup.addButton(self.modePIDVelButton)
        self.modeGroup.addButton(self.modeTrapPosButton)
        self.modeGroup.selectedChanged.connect(self._controlModeChanged)
        
        self.modeRow = QHBoxLayout()
        self.modeRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.modeRow.addWidget(self.modeLabel)
        self.modeRow.addWidget(self.modeGroup)
        
        #reference
        self.refLabel = QLabel("Control Reference:")
        
        ##none
        self.refNoneLabel = QLabel("N/A")
        
        self.refNoneRow = QHBoxLayout()
        self.refNoneRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refNoneRow.addWidget(self.refNoneLabel)
        
        self.noneContainer = QFrame()
        self.noneContainer.setLayout(self.refNoneRow)
        
        ##dutyCycle
        self.refDutyCycleTextbox = QDoubleSpinBox()
        self.refDutyCycleTextbox.setDecimals(4)
        self.refDutyCycleTextbox.setSingleStep(0.1)
        self.refDutyCycleTextbox.setRange(-1, 1)
        self.refDutyCycleTextbox.setValue(0)
        
        self.refDutyCycleButton = QPushButton("Set")
        self.refDutyCycleButton.clicked.connect(lambda: device.setControlReference(self.refDutyCycleTextbox.value()))
        
        self.refDutyCycleRow = QHBoxLayout()
        self.refDutyCycleRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refDutyCycleRow.addWidget(self.refDutyCycleTextbox)
        self.refDutyCycleRow.addWidget(self.refDutyCycleButton)
        
        self.dutyCycleContainer = QFrame()
        self.dutyCycleContainer.setLayout(self.refDutyCycleRow)
        self.dutyCycleContainer.setVisible(False)
        
        ##voltage
        self.refVoltageTextbox = QDoubleSpinBox()
        self.refVoltageTextbox.setDecimals(2)
        self.refVoltageTextbox.setSingleStep(0.5)
        self.refVoltageTextbox.setRange(-12, 12)
        self.refVoltageTextbox.setValue(0)
        self.refVoltageTextbox.setSuffix(" V")
        
        self.refVoltageButton = QPushButton("Set")
        self.refVoltageButton.clicked.connect(lambda: device.setControlReference(self.refVoltageTextbox.value()))
        
        self.refVoltageRow = QHBoxLayout()
        self.refVoltageRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refVoltageRow.addWidget(self.refVoltageTextbox)
        self.refVoltageRow.addWidget(self.refVoltageButton)
        
        self.voltageContainer = QFrame()
        self.voltageContainer.setLayout(self.refVoltageRow)
        self.voltageContainer.setVisible(False)
        
        ##PID pos
        self.refPIDPosTextbox = QSpinBox()
        self.refPIDPosTextbox.setSingleStep(100)
        self.refPIDPosTextbox.setRange(-2_147_483_648, 2_147_483_647) #https://docs.arduino.cc/language-reference/en/variables/data-types/long/
        self.refPIDPosTextbox.setValue(0)
        self.refPIDPosTextbox.setSuffix(" Ticks")
        
        self.refPIDPosButton = QPushButton("Set")
        self.refPIDPosButton.clicked.connect(lambda: device.setControlReference(self.refPIDPosTextbox.value()))
        
        self.refPIDPosRow = QHBoxLayout()
        self.refPIDPosRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refPIDPosRow.addWidget(self.refPIDPosTextbox)
        self.refPIDPosRow.addWidget(self.refPIDPosButton)
        
        self.pidPosContainer = QFrame()
        self.pidPosContainer.setLayout(self.refPIDPosRow)
        self.pidPosContainer.setVisible(False)
        
        ##PID vel
        self.refPIDVelTextbox = QDoubleSpinBox()
        self.refPIDVelTextbox.setSingleStep(5000)
        self.refPIDVelTextbox.setRange(-3.4028235e+38, 3.4028235e+38) #https://docs.arduino.cc/language-reference/en/variables/data-types/float/
        self.refPIDVelTextbox.setValue(0)
        self.refPIDVelTextbox.setSuffix(" TPS")
        
        self.refPIDVelButton = QPushButton("Set")
        self.refPIDVelButton.clicked.connect(lambda: device.setControlReference(self.refPIDVelTextbox.value()))
        
        self.refPIDVelRow = QHBoxLayout()
        self.refPIDVelRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refPIDVelRow.addWidget(self.refPIDVelTextbox)
        self.refPIDVelRow.addWidget(self.refPIDVelButton)
        
        self.pidVelContainer = QFrame()
        self.pidVelContainer.setLayout(self.refPIDVelRow)
        self.pidVelContainer.setVisible(False)
        
        ##Trap pos
        self.refTrapPosTextbox = QSpinBox()
        self.refTrapPosTextbox.setSingleStep(100)
        self.refTrapPosTextbox.setRange(-2_147_483_648, 2_147_483_647) #https://docs.arduino.cc/language-reference/en/variables/data-types/long/
        self.refTrapPosTextbox.setValue(0)
        self.refTrapPosTextbox.setSuffix(" Ticks")
        
        self.refTrapPosButton = QPushButton("Set")
        self.refTrapPosButton.clicked.connect(lambda: device.setControlReference(self.refTrapPosTextbox.value()))
        
        self.refTrapPosRow = QHBoxLayout()
        self.refTrapPosRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refTrapPosRow.addWidget(self.refTrapPosTextbox)
        self.refTrapPosRow.addWidget(self.refTrapPosButton)
        
        self.trapPosContainer = QFrame()
        self.trapPosContainer.setLayout(self.refTrapPosRow)
        self.trapPosContainer.setVisible(False)
        
        ##ref row
        self.refRow = QHBoxLayout()
        self.refRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.refRow.addWidget(self.refLabel)
        self.refRow.addWidget(self.noneContainer)
        self.refRow.addWidget(self.dutyCycleContainer)
        self.refRow.addWidget(self.voltageContainer)
        self.refRow.addWidget(self.pidPosContainer)
        self.refRow.addWidget(self.pidVelContainer)
        self.refRow.addWidget(self.trapPosContainer)
        
        #PID config
        self.pidConfigKPLabel = QLabel("kP:")
        
        self.pidConfigKP = QDoubleSpinBox()
        self.pidConfigKP.setDecimals(8)
        self.pidConfigKP.setSingleStep(0.001)
        self.pidConfigKP.setRange(-1, 1)
        self.pidConfigKP.setValue(0.02)
        
        self.pidConfigKILabel = QLabel("kI:")
        
        self.pidConfigKI = QDoubleSpinBox()
        self.pidConfigKI.setDecimals(8)
        self.pidConfigKI.setSingleStep(0.000001)
        self.pidConfigKI.setRange(-1, 1)
        self.pidConfigKI.setValue(0)
        
        self.pidConfigKDLabel = QLabel("kD:")
        
        self.pidConfigKD = QDoubleSpinBox()
        self.pidConfigKD.setDecimals(8)
        self.pidConfigKD.setSingleStep(0.001)
        self.pidConfigKD.setRange(-1, 1)
        self.pidConfigKD.setValue(0.002)
        
        self.pidConfigKSLabel = QLabel("kS:")
        
        self.pidConfigKS = QDoubleSpinBox()
        self.pidConfigKS.setDecimals(8)
        self.pidConfigKS.setSingleStep(0.01)
        self.pidConfigKS.setRange(-1, 1)
        self.pidConfigKS.setValue(0.165)
        
        self.pidConfigSend = QPushButton("Send")
        self.pidConfigSend.clicked.connect(self._sendPIDSConfig)
        
        self.pidConfigRow = QHBoxLayout()
        self.pidConfigRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.pidConfigRow.addWidget(self.pidConfigKPLabel)
        self.pidConfigRow.addWidget(self.pidConfigKP)
        self.pidConfigRow.addWidget(self.pidConfigKILabel)
        self.pidConfigRow.addWidget(self.pidConfigKI)
        self.pidConfigRow.addWidget(self.pidConfigKDLabel)
        self.pidConfigRow.addWidget(self.pidConfigKD)
        self.pidConfigRow.addWidget(self.pidConfigKSLabel)
        self.pidConfigRow.addWidget(self.pidConfigKS)
        self.pidConfigRow.addWidget(self.pidConfigSend)
        
        self.pidConfigContainer = QFrame()
        self.pidConfigContainer.setLayout(self.pidConfigRow)
        self.pidConfigContainer.setVisible(False)
        
        #Profile config
        self.profileConfigVmaxLabel = QLabel("v_max:")
        
        self.profileConfigVmax = QDoubleSpinBox()
        self.profileConfigVmax.setSingleStep(5000)
        self.profileConfigVmax.setRange(0, 3.4028235e+38)
        self.profileConfigVmax.setValue(25000)
        self.profileConfigVmax.setSuffix(" TPS")
        
        self.profileConfigAstartLabel = QLabel("a_start:")
        
        self.profileConfigAstart = QDoubleSpinBox()
        self.profileConfigAstart.setSingleStep(25)
        self.profileConfigAstart.setRange(0, 3.4028235e+38)
        self.profileConfigAstart.setValue(10000)
        self.profileConfigAstart.setSuffix(" TPS^2")
        
        self.profileConfigAendLabel = QLabel("a_end:")
        
        self.profileConfigAend = QDoubleSpinBox()
        self.profileConfigAend.setSingleStep(25)
        self.profileConfigAend.setRange(0, 3.4028235e+38)
        self.profileConfigAend.setValue(10000)
        self.profileConfigAend.setSuffix(" TPS^2")
        
        self.profileConfigSend = QPushButton("Send")
        self.profileConfigSend.clicked.connect(self._sendProfileConfig)
        
        self.profileConfigRow = QHBoxLayout()
        self.profileConfigRow.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.profileConfigRow.addWidget(self.profileConfigVmaxLabel)
        self.profileConfigRow.addWidget(self.profileConfigVmax)
        self.profileConfigRow.addWidget(self.profileConfigAstartLabel)
        self.profileConfigRow.addWidget(self.profileConfigAstart)
        self.profileConfigRow.addWidget(self.profileConfigAendLabel)
        self.profileConfigRow.addWidget(self.profileConfigAend)
        self.profileConfigRow.addWidget(self.profileConfigSend)
        
        self.profileConfigContainer = QFrame()
        self.profileConfigContainer.setLayout(self.profileConfigRow)
        self.profileConfigContainer.setVisible(False)
        
        #layout
        self.layout = QVBoxLayout(self)
        self.layout.setAlignment(Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop)
        self.layout.addLayout(self.enabledRow)
        self.layout.addLayout(self.modeRow)
        self.layout.addLayout(self.refRow)
        self.layout.addWidget(self.pidConfigContainer)
        self.layout.addWidget(self.profileConfigContainer)
        
        #mappings
        self._controlModesIndicies:list[device.DeviceControlMode] = [
            device.DeviceControlMode.NONE,
            device.DeviceControlMode.DUTY_CYCLE,
            device.DeviceControlMode.VOLTAGE,
            device.DeviceControlMode.PID_POSITION,
            device.DeviceControlMode.PID_VELOCITY,
            device.DeviceControlMode.TRAP_POSITION
        ]
        self._controlModeContainers:dict[device.DeviceControlMode, QWidget] = {
            device.DeviceControlMode.NONE: self.noneContainer,
            device.DeviceControlMode.DUTY_CYCLE: self.dutyCycleContainer,
            device.DeviceControlMode.VOLTAGE: self.voltageContainer,
            device.DeviceControlMode.PID_POSITION: self.pidPosContainer,
            device.DeviceControlMode.PID_VELOCITY: self.pidVelContainer,
            device.DeviceControlMode.TRAP_POSITION: self.trapPosContainer
        }
    
    @Slot(int, int)
    def _controlModeChanged(self, prevIndex:int, newIndex:int)->None:
        newMode = self._controlModesIndicies[newIndex]
        device.setControlMode(newMode)
        
        prevContainer = self._controlModeContainers[self._controlModesIndicies[prevIndex]]
        newContainer = self._controlModeContainers[self._controlModesIndicies[newIndex]]
        prevContainer.setVisible(False)
        newContainer.setVisible(True)
        
        self.pidConfigContainer.setVisible(newMode == device.DeviceControlMode.PID_POSITION or newMode == device.DeviceControlMode.PID_VELOCITY or newMode == device.DeviceControlMode.TRAP_POSITION)
        self.profileConfigContainer.setVisible(newMode == device.DeviceControlMode.TRAP_POSITION)
    
    @Slot()
    def _sendPIDSConfig(self)->None:
        device.setKP(self.pidConfigKP.value())
        device.setKI(self.pidConfigKI.value())
        device.setKD(self.pidConfigKD.value())
        device.setKS(self.pidConfigKS.value())
    
    @Slot()
    def _sendProfileConfig(self)->None:
        device.setVmax(self.profileConfigVmax.value())
        device.setAstart(self.profileConfigAstart.value())
        device.setAend(self.profileConfigAend.value())

class Console(QFrame):
    def __init__(self):
        super().__init__()
        
        self.messages:list[ConsoleEntry] = []
        
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(QMargins(0, 0, 0, 0))
        self.layout.setSpacing(0)
        self.layout.setAlignment(Qt.AlignmentFlag.AlignHCenter | Qt.AlignmentFlag.AlignTop)
    
    def addEntry(self, entry:ConsoleEntry)->None:
        self.messages.append(entry)
        self.layout.addWidget(entry)
        
        if len(self.messages) > 100:
            old = self.messages.pop(0)
            self.layout.removeWidget(old)

_app:(QApplication | None) = None
_root:(Root | None) = None
_updateTimer:(QTimer | None) = None
_consoleQueue:list[list[any]] = []

_INFO_ICON:QPixmap
_WARNING_ICON:QPixmap
_ERROR_ICON:QPixmap

def setupGUI(update:Callable[[], None])->None:
    global _app, _root, _updateTimer, _INFO_ICON, _WARNING_ICON, _ERROR_ICON
    
    _app = QApplication()
    _app.setApplicationName("Device Controller")
    
    _root = Root()
    _root.resize(2300, 1200)
    _root.show()
    
    _updateTimer = QTimer(singleShot=False, interval=40)
    _updateTimer.timeout.connect(update)
    
    _INFO_ICON = QPixmap("info.png")
    _WARNING_ICON = QPixmap("warning.png")
    _ERROR_ICON = QPixmap("error.png")

def startGUI()->None:
    _updateTimer.start()
    _app.exec()

def hasGUIStarted()->bool:
    return _root is not None

def updateConnectionStatus(connected:bool, port:str | None)->None:
    if not hasGUIStarted():
        return
    
    if connected:
        _root.header.setConnected("Uknown Port" if port is None else port)
        _root.controls.setEnabled(True)
    else:
        _root.header.setDisconnected()
        _root.controls.setEnabled(False)

def updateUPS(ups:int | None)->None:
    if not hasGUIStarted():
        return
    
    _root.header.setUPS(ups)

def updateTableFromDeviceState(state:device.DeviceState | None)->None:
    if not hasGUIStarted():
        return
    
    if state is None:
        _root.data.data = {
            "Enabled": None,
            "Source Voltage": None,
            "Control Mode": None,
            "Control Reference": None,
            "Commanded Output": None,
            "Position (Ticks)": None,
            "Position (Rots)": None,
            "Velocity (TPS)": None,
            "Velocity (RPM)": None,
            "Last Time Stamp (Millis)": None,
            "Error (Ticks)": None
        }
    else:
        _root.data.data = {
            "Enabled": str(state.enabled),
            "Source Voltage": None if state.sourceVoltage is None else "{:.2f}".format(state.sourceVoltage),
            "Control Mode": None if state.controlMode is None else state.controlMode.name,
            "Control Reference": None if state.controlRef is None else "{:.4f}".format(state.controlRef),
            "Commanded Output": None if state.commandedOutput is None else "{:.2f}".format(state.commandedOutput),
            "Position (Ticks)": None if state.positionTicks is None else str(state.positionTicks),
            "Position (Rots)": None if state.positionRots is None else "{:.4f}".format(state.positionRots),
            "Velocity (TPS)": None if state.velocityTicksPerSecond  is None else "{:.2f}".format(state.velocityTicksPerSecond),
            "Velocity (RPM)": None if state.velocityRPM is None else "{:.2f}".format(state.velocityRPM),
            "Last Time Stamp (Millis)": None if state.lastTimestampMillis is None else str(state.lastTimestampMillis),
            "Error (Ticks)": None if state.error is None else "{:.2f}".format(state.error)
        }
    
    _root.data.updateTable()

def consoleInfo(msg:str)->None:
    _consoleQueue.append([_INFO_ICON, msg])
    print(f"INFO: {msg}")

def consoleWarning(msg:str)->None:
    _consoleQueue.append([_WARNING_ICON, msg, "#eae80b"])
    print(f"WARN: {msg}")

def consoleError(msg:str)->None:
    _consoleQueue.append([_ERROR_ICON, msg, "#dd0000"])
    print(f"ERR: {msg}")

def updateConsole()->None:
    if not hasGUIStarted():
        return
    
    for queued in _consoleQueue:
        #horrible code, I don't really care tho
        entry:ConsoleEntry
        if len(queued) == 2:
            entry = ConsoleEntry(queued[0], queued[1])
        else:
            entry = ConsoleEntry(queued[0], queued[1], queued[2])
        _root.consoleContents.addEntry(entry)
    
    _consoleQueue.clear()

def addPositionGraphReading(secs:float, ticks:float)->None:
    if not hasGUIStarted():
        return
    
    posSeries = _root.graphs.posVelGraph.getSeries(0)
    posSeries.append(secs, ticks)

def addVelocityGraphReading(secs:float, tps:float)->None:
    if not hasGUIStarted():
        return
    
    velSeries = _root.graphs.posVelGraph.getSeries(1)
    velSeries.append(secs, tps)

def refitPosVelGraph(currentSecs:float)->None:
    if not hasGUIStarted():
        return
    
    posSeries = _root.graphs.posVelGraph.getSeries(0)
    velSeries = _root.graphs.posVelGraph.getSeries(1)
    
    toRemove:int = 0
    for i in range(posSeries.count()):
        point = posSeries.at(i)
        if currentSecs - point.x() >= 15:
            toRemove += 1
        else:
            break
    
    if toRemove > 0:
        posSeries.removePoints(0, toRemove)
    
    toRemove = 0
    for i in range(velSeries.count()):
        point = velSeries.at(i)
        if currentSecs - point.x() >= 15:
            toRemove += 1
        else:
            break
    
    if toRemove > 0:
        velSeries.removePoints(0, toRemove)
    
    _root.graphs.posVelGraph.autorange()

def addDutyCycleGraphReading(secs:float, dutyCycle:float)->None:
    if not hasGUIStarted():
        return
    
    dutySeries = _root.graphs.outGraph.getSeries(0)
    dutySeries.append(secs, dutyCycle)

def refitDutyGraph(currentSecs:float)->None:
    if not hasGUIStarted():
        return
    
    dutySeries = _root.graphs.outGraph.getSeries(0)
    
    toRemove:int = 0
    for i in range(dutySeries.count()):
        point = dutySeries.at(i)
        if currentSecs - point.x() >= 15:
            toRemove += 1
        else:
            break
    
    if toRemove > 0:
        dutySeries.removePoints(0, toRemove)
    
    _root.graphs.outGraph.autorange(initialYMax=1, initialYMin=-1)

def addErrorGraphReading(secs:float, error:float)->None:
    if not hasGUIStarted():
        return
    
    errorSeries = _root.graphs.errorGraph.getSeries(0)
    errorSeries.append(secs, error)

def refitErrorGraph(currentSecs:float)->None:
    if not hasGUIStarted():
        return
    
    errorSeries = _root.graphs.errorGraph.getSeries(0)
    
    toRemove:int = 0
    for i in range(errorSeries.count()):
        point = errorSeries.at(i)
        if currentSecs - point.x() >= 15:
            toRemove += 1
        else:
            break
    
    if toRemove > 0:
        errorSeries.removePoints(0, toRemove)
    
    _root.graphs.errorGraph.autorange(initialYMax=10, initialYMin=-10)
