from PySide6.QtCore import *
from PySide6.QtWidgets import *
from PySide6.QtGui import *
from PySide6.QtCharts import *
import sys

class RadioButtonGroup(QFrame, QObject):
    selectedChanged = Signal(int, int)
    
    def __init__(self, defaultSelected:int):
        super().__init__()
        
        self.setFrameShape(QFrame.Shape.StyledPanel)
        self.setFrameShadow(QFrame.Shadow.Sunken)
        self.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        
        self._buttons:list[QPushButton] = []
        self._selected = defaultSelected
        
        self._buttonSize = self._findMaxButtonDimensions()
        
        self.layout = QHBoxLayout(self)
        self.layout.setContentsMargins(0, 0, 0, 0)
        self.layout.setSpacing(0)
        
    def sizeHint(self)->QSize:
        return QSize(self._buttonSize.width() * len(self._buttons), self._buttonSize.height())
    
    def _findMaxButtonDimensions(self)->QSize:
        maxCase = QSize(0, 0)
        for b in self._buttons:
            maxCase = QSize(max(maxCase.width(), b.sizeHint().width()), max(maxCase.height(), b.sizeHint().height()))
        
        return maxCase
    
    def addButton(self, btn:QPushButton)->None:
        btnIndex = len(self._buttons)
        
        btn.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        btn.clicked.connect(lambda: self._buttonClicked(btnIndex))
        btn.setEnabled(btnIndex != self._selected)
        
        self._buttons.append(btn)
        self._buttonSize = self._findMaxButtonDimensions()
        self.layout.addWidget(btn)
        
        for b in self._buttons:
            b.setMinimumSize(self._buttonSize)
    
    @Slot()
    def _buttonClicked(self, index:int)->None:
        self.selectedChanged.emit(self._selected, index)
        self.setSelected(index)
    
    def setSelected(self, index:int)->None:
        self._selected = index
        for i, b in enumerate(self._buttons):
            b.setEnabled(i != self._selected)

class ConsoleEntry(QFrame):
    def __init__(self, _icn:QPixmap, msg:str, msgColor:str | None = None):
        super().__init__()
        
        self.setFrameShape(QFrame.Shape.StyledPanel)
        self.setFrameShadow(QFrame.Shadow.Plain)
        self.setSizePolicy(QSizePolicy.Policy.MinimumExpanding, QSizePolicy.Policy.Fixed)
        
        self.icon = QLabel(pixmap=_icn)
        
        self.message = QLabel(msg, wordWrap=True)
        self.message.setAlignment(Qt.AlignmentFlag.AlignVCenter | Qt.AlignmentFlag.AlignLeft)
        self.message.setSizePolicy(QSizePolicy.Policy.MinimumExpanding, QSizePolicy.Policy.Fixed)
        if msgColor is not None:
            self.message.setStyleSheet(f"color: {msgColor};")
        #setting the background changes something in the styling that fixes wordwrap, DO NOT TOUCH
        self.message.setStyleSheet(self.message.styleSheet() + "background: transparent;")
        
        self.layout = QHBoxLayout(self)
        self.layout.setContentsMargins(0, 0, 0, 0)
        self.layout.setSpacing(6)
        self.layout.setAlignment(Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop)
        self.layout.addWidget(self.icon)
        self.layout.addWidget(self.message)
    
    def sizeHint(self)->QSize:
        return QSize(self.icon.sizeHint().width() + 300 + self.layout.spacing(), max(self.icon.sizeHint().height(), self.message.sizeHint().height()))

class SeriesConfig:
    def __init__(self, name:str, color:str, verticalLabel:str, verticalLabelAlignment:Qt.AlignmentFlag):
        self.name = name
        self.color = color
        self.verticalLabel = verticalLabel
        self.verticalLabelAlignment = verticalLabelAlignment

class LiveGraph(QChartView):
    def __init__(self, title:str, seriesConfigs:list[SeriesConfig], showLegend:bool):
        super().__init__()
        
        self.chart:QChart = QChart()
        
        self.chart.setTheme(QChart.ChartTheme.ChartThemeDark)
        self.chart.setBackgroundBrush(QColor("#2D2D2D"))
        self.chart.setPlotAreaBackgroundBrush(QColor("#1e1e1e"))
        self.chart.setPlotAreaBackgroundVisible(True)
        
        #https://stackoverflow.com/a/39243275
        self.chart.setMargins(QMargins(5, 5, 5, 5))
        # self.chart.setBackgroundRoundness(0)
        self.chart.layout().setContentsMargins(0, 0, 0, 0)
        
        if showLegend:
            self.chart.legend().setAlignment(Qt.AlignmentFlag.AlignBottom)
        else:
            self.chart.legend().setVisible(False)
        
        self.chart.setTitle(title)
        
        horzAxis = QValueAxis()
        horzAxis.setTitleText("Time (s)")
        horzAxis.setTickInterval(1)
        horzAxis.setTickType(QValueAxis.TickType.TicksDynamic)
        horzAxis.setGridLineColor("#3c3c3c")
        self.chart.addAxis(horzAxis, Qt.AlignmentFlag.AlignBottom)
        
        self.serieses:list[QLineSeries] = []
        for configs in seriesConfigs:
            vertAxis = QValueAxis()
            vertAxis.setTitleText(configs.verticalLabel)
            vertAxis.setTickCount(6)
            vertAxis.setLabelsColor(configs.color)
            vertAxis.setGridLineColor("#3c3c3c")
            self.chart.addAxis(vertAxis, configs.verticalLabelAlignment)
            
            s = QLineSeries()
            s.setName(configs.name)
            s.setColor(configs.color)
            
            # s.setUseOpenGL(True) #causes rendering issues
            
            # s.append(0, 0)
            
            self.chart.addSeries(s)
            self.serieses.append(s)
            
            s.attachAxis(horzAxis)
            s.attachAxis(vertAxis)
        
        self.setChart(self.chart)
    
    def getSeries(self, index:int)->QLineSeries:
        return self.serieses[index]
    
    def autorange(self, initialXMin:float=sys.float_info.max, initialXMax:float=-sys.float_info.max, initialYMin:float=sys.float_info.max, initialYMax:float=-sys.float_info.max)->None:
        xMax:float = initialXMax
        xMin:float = initialXMin
        for series in self.serieses:
            yMax:float = initialYMax
            yMin:float = initialYMin
            
            for i in range(series.count()):
                point = series.at(i)
                
                xMax = max(xMax, point.x())
                xMin = min(xMin, point.x())
                yMax = max(yMax, point.y())
                yMin = min(yMin, point.y())
            
            # if abs(yMax - yMin) <= 1:
            #     yMax += 1
            #     yMin -= 1
            
            for axis in series.attachedAxes():
                if axis.orientation() == Qt.Orientation.Vertical:
                        axis.setRange(yMin, yMax)
        
        self.chart.axes(Qt.Orientation.Horizontal)[0].setRange(xMin, xMax)
