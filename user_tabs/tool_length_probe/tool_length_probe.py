import os
import linuxcnc

#from PyQt6 import QtCore

#from PyQt5.QtGui import QRegExpValidator, QFont
from qtpy import uic
from qtpy.QtCore import Qt
from qtpy.QtWidgets import QWidget,QPushButton, QDialogButtonBox, QLabel

from qtpyvcp.plugins import getPlugin
from qtpyvcp.utilities import logger
from qtpyvcp.widgets.input_widgets.setting_slider import VCPSettingsPushButton, VCPSettingsComboBox, VCPSettingsDoubleSpinBox, VCPSettingsLineEdit
from qtpyvcp.widgets.input_widgets.line_edit import VCPLineEdit

from qtpyvcp import hal

from qtpy.QtCore import Slot, QRegExp, Qt
from qtpy.QtWidgets import QAbstractButton

from qtpy.QtWidgets import QWidget, QMessageBox, QProgressDialog

#from probe_basic.probe_basic import ProbeBasic

from threading import Timer

import re

LOG = logger.getLogger(__name__)

STATUS = getPlugin('status')
TOOL_TABLE = getPlugin('tooltable')
NOTIFICATION = getPlugin('notifications')

INI_FILE = linuxcnc.ini(os.getenv('INI_FILE_NAME'))


#### TODO
# Change Pos auf zweiten Parametersatz als Backup
# Methoden Dokumentieren
# Eingabe von "spindle zero" prüfen. Auch nach Änderung von Setter Z

class UserTab(QWidget):
    def __init__(self, parent=None):
        super(UserTab, self).__init__(parent)
        ui_file = os.path.splitext(os.path.basename(__file__))[0] + ".ui"
        uic.loadUi(os.path.join(os.path.dirname(__file__), ui_file), self)

        self.inited_spindle_zero_maximum:bool = False

        
        self.hal_button_pins = []
        self.hal_spinbox_pins = []
        self.hal_combobox_pins = []
        self.hal_lineedit_ro_pins = []

        self.comboboxs:VCPSettingsComboBox = [self.break_after_same_tool_2961_tlp,
            self.break_after_change_tool_2962_tlp]
        
        self.offset_buttons:VCPSettingsPushButton = [self.tool_offset_left_btn_tlp, 
            self.tool_offset_right_btn_tlp, 
            self.tool_offset_back_btn_tlp, 
            self.tool_offset_front_btn_tlp]

        self.buttons:VCPSettingsPushButton = [self.disable_change_pos_btn_tlp, 
            self.use_tool_table_btn_tlp, 
            self.go_back_start_btn_tlp, 
            self.last_try_btn_tlp, 
            self.tool_diam_probe_btn_tlp, 
            self.debug_mode_btn_tlp]
        
        self.buttons.extend(self.offset_buttons)
        
        # spinboxes
        self.spinboxs:VCPSettingsDoubleSpinBox = [self.spindle_zero_height_3010_tlp,
            self.fast_probe_fr_3004_tlp,
            self.slow_probe_fr_3005_tlp,
            self.traverse_fr_3006_tlp,
            self.z_max_travel_3007_tlp,
            self.xy_max_travel_3008_tlp,
            self.retract_distance_3009_tlp,
            self.tool_min_distance_2957_tlp,
            self.add_repetitions_2958_tlp,
            self.probe_z_offset_2956_tlp,
            self.probe_tool_number_2960_tlp,
            self.spindle_stop_m_2959_tlp]
        
        
        

        # read only lineedits
        self.lineedits_ro:VCPSettingsLineEdit = [self.x_tool_change_position_5181_tlp,
                        self.y_tool_change_position_5182_tlp,
                        self.z_tool_change_position_5183_tlp,
                        self.x_tool_setter_position_2951_tlp,
                        self.y_tool_setter_position_2952_tlp,
                        self.z_tool_setter_position_2953_tlp,
                        self.x_tool_probe_position_2954_tlp,
                        self.y_tool_probe_position_2955_tlp]
        
        self.c = linuxcnc.command()
        

        # Creates an error message when a read only lineedit widget has not the correct testFormat.
        for lineedit in self.lineedits_ro:
            if not lineedit._text_format == "{:.4f}":
                #LOG.error("textFormat \""+lineedit._text_format+"\" incorrect at widget: \""+lineedit.objectName()+"\"")
                self.c.error_msg("textFormat \""+lineedit._text_format+"\" incorrect at widget: \""+lineedit.objectName()+"\"")  

            

        # lineedit widgets that help to get the values for the buttons and the comboboxes
        self.lineedit_help_ro:VCPLineEdit = [self.all_buttons_2949_tlp,
                        self.break_after_st_2961_tlp,
                        self.break_after_tc_2962_tlp]
        
        # No one need to see the help widgets
        for lineedit in self.lineedit_help_ro:
            lineedit.setVisible(False)

        
        

        
        self.progressbar: QProgressDialog
        
        

        # Create HAL-pins
        self.set_hal_button_pins()
        self.set_hal_spinbox_pins()
        self.set_hal_combobox_pins()
        self.set_hal_lineedit_ro_pins()
      
        
        t = Timer(2.0, self.delayed)
        t.start()
        
        
        # Connect widgets with functions
        for button in self.offset_buttons:
            button.clicked.connect(self.uncheck_offset_buttons)
        self.set_backup_tlp.clicked.connect(self.send_values_to_var)
        self.get_backup_tlp.clicked.connect(self.get_values_from_var)
        self.set_g30_1_position_tlp.clicked.connect(self.set_change_position)
        self.set_tool_setter_position_tlp.clicked.connect(self.set_setter_position)
        self.set_3d_probe_position_tlp.clicked.connect(self.set_probe_position)
        self.set_spindle_zero_tlp.clicked.connect(self.set_spindle_zero)
        self.spindle_zero_height_3010_tlp.editingFinished.connect(self.init_spindle_zero_maximum)
        
        

    # Starts some process delayed. Some actions cannot be made during __init__ .
    def delayed(self):
        self.disable_io_buttons()
        self.update_hal_pins_status()
        
    # Init the maximum value for the widget "spindle_zero_height_3010_tlp" depending on the tool setter z position when changing for the first time.
    def init_spindle_zero_maximum(self):
        if self.inited_spindle_zero_maximum == False:
            self.spindle_zero_height_3010_tlp.setMaximum(abs(float(self.z_tool_setter_position_2953_tlp.text())))
            self.update_hal_pins_status()
            self.inited_spindle_zero_maximum = True
            

    # Updates the status of the HAL-pins
    def update_hal_pins_status(self):
        for pin in self.hal_button_pins:
            pin.refreshCheckState()
        
        for pin in self.hal_spinbox_pins:
            pin.onEditFinished()

        for pin in self.hal_combobox_pins:
            pin.onChangeEvent()

        self.update_lineedit_ro_pins()
        

    # Updates the read only lineedit hal pins
    def update_lineedit_ro_pins(self):
        for pin in self.hal_lineedit_ro_pins:
            pin.onEditFinished()
                
    # Deactivate all buttons from the buttons list
    def disable_io_buttons(self):        
        for button in self.buttons:
            button.setEnabled(False)
        
    # Switches the HAL-pins of the unset offset-buttons off.
    # The buttons switch them off but the HAL-pins do not react.
    def uncheck_offset_buttons(self):
        for pin in self.hal_button_pins:
            if pin.button.isChecked() == False:
                pin.refreshCheckState()


    
    ### Button state ####
    #####################
    # Stores the state of all buttons in "buttons" list to the "2949" parameter in the .var-file.
    def store_buttons_state(self):
        out = 0
        for i in range(len(self.buttons)):
            if self.buttons[i].isChecked():
                out = self.set_bit(out, i)
        
        mode:int = STATUS.stat.task_mode
        self.c.mode(linuxcnc.MODE_MDI)
        self.c.mdi("#2949 = " + str(out))
        
        if mode == 1:
            self.c.mode(linuxcnc.MODE_MANUAL)
        return int
    
    # Set the state of all buttons in "buttons" list by a given number.
    def set_buttons_state(self, i):
        for n in range(len(self.buttons)):
            self.buttons[n].setChecked(self.is_bit_set(i,n))

    # Checks a single bit of a float value
    def is_bit_set(self, float, bit_position):
        return (int(float) & (1 << bit_position)) != 0
    
    # Sets a bit of a variable
    def set_bit(self, value, bit):
        return value | (1<<bit)
    

    ### Send and get value to/from .var-file ###
    ############################################
    # Sends the values of all spinboxes, comboboxes, lineedits and the combint value of all buttons to the .var-file
    def send_values_to_var(self):
        if self.showdialog(QMessageBox.Warning, "OVERWRITE BACKUP!", "Really overwrite the backup?"):
            mode:int = STATUS.stat.task_mode
            self.c.mode(linuxcnc.MODE_MDI)

            out = 0
            for i in range(len(self.buttons)):
                if self.buttons[i].isChecked():
                    out = self.set_bit(out, i)

            self.c.mdi("#2949 = " + str(out))

            for spinbox in self.spinboxs:
                self.c.mdi("#" + re.sub(r'[^0-9]', '', spinbox.objectName()) + " = " + spinbox.text())

            for combobox in self.comboboxs:
                self.c.mdi("#" + re.sub(r'[^0-9]', '', combobox.objectName()) + " = " + str(combobox.currentIndex()))

            for lineedit in self.lineedits_ro:
                self.c.mdi("#" + re.sub(r'[^0-9]', '', lineedit.objectName()) + " = " + lineedit.text())
        
            if mode == 1:
                self.c.mode(linuxcnc.MODE_MANUAL)

    # Triggers to send the parameters from the .var-file to the widgets.
    def get_values_from_var(self):
        self.progressbar = QProgressDialog("Please wait..", None, 0, 100, self)
        try:
            self.progressbar.findChildren(QLabel)[0].setStyleSheet('.QLabel { font-size: 30pt;}')
        except:
            print("Could not find QLabel in self.progressbar!!")
        self.progressbar.open()

        mode:int = STATUS.stat.task_mode
        self.c.mode(linuxcnc.MODE_MDI)
        self.progressbar.setValue(5)
        #(DEBUG, EVAL[vcp.getWidget{"WIDGET-NAME"}.setValue{#1000}])
        for spinbox in self.spinboxs:
            self.c.mdi("(DEBUG, EVAL[vcp.getWidget{\"" + spinbox.objectName()+ "\"}.setValue{#" + re.sub(r'[^0-9]', '', spinbox.objectName()) + "}])")
        self.progressbar.setValue(10)
        
        for lineedit in self.lineedits_ro:
            self.c.mdi("(DEBUG, EVAL[vcp.getWidget{\"" + lineedit.objectName()+ "\"}.setValue{#" + re.sub(r'[^0-9]', '', lineedit.objectName()) + "}])")
        self.progressbar.setValue(15)

        for lineedit in self.lineedit_help_ro:
            self.c.mdi("(DEBUG, EVAL[vcp.getWidget{\"" + lineedit.objectName()+ "\"}.setText{\"#" + re.sub(r'[^0-9]', '', lineedit.objectName()) + "\"}])")
        self.progressbar.setValue(20)

        if mode == 1:
            self.c.mode(linuxcnc.MODE_MANUAL)
        t = Timer(6, self.refresh)
        t.start()
        self.progressbar.setValue(30)

    # Refreshes the widget status
    def refresh(self):
        self.progressbar.setValue(40)
        
        self.progressbar.setValue(50)
        for spinbox in self.spinboxs:
            spinbox.editingEnded()
        self.progressbar.setValue(60)
        self.set_buttons_state(int(float(self.all_buttons_2949_tlp.text())))
        self.progressbar.setValue(70)
        self.update_hal_pins_status()
        self.set_combobox_status()
        self.progressbar.setValue(80)
        self.progressbar.setValue(100)

    # Set the status of the comboboxes.
    def set_combobox_status(self):
        self.break_after_same_tool_2961_tlp.setCurrentIndex(int(float(self.break_after_st_2961_tlp.text())))
        self.break_after_change_tool_2962_tlp.setCurrentIndex(int(float(self.break_after_tc_2962_tlp.text())))
        

    ### Positions ###
    #################
    # Read the abslolut position(G53) of X-, Y- and Z-axis and return it as list.
    def get_xyz_position(self):
        pos = list(STATUS.stat.actual_position)
        pos[0] = round(pos[0], 4)
        pos[1] = round(pos[1], 4)
        pos[2] = round(pos[2], 4)
        
        return pos
    
    # Set the X, Y and Z position for tool change (G30).
    def set_change_position(self):
        if self.showdialog(QMessageBox.Question, "SET POSITION", "Really take over the position?"):
            pos = self.get_xyz_position()
            self.x_tool_change_position_5181_tlp.setValue(pos[0])
            self.y_tool_change_position_5182_tlp.setValue(pos[1])
            self.z_tool_change_position_5183_tlp.setValue(pos[2])
            self.update_lineedit_ro_pins()
            mode:int = STATUS.stat.task_mode
            self.c.mode(linuxcnc.MODE_MDI)
            self.c.mdi("#5181 = " + str(pos[0]))
            self.c.mdi("#5182 = " + str(pos[1]))
            self.c.mdi("#5183 = " + str(pos[2]))
            if mode == 1:
                self.c.mode(linuxcnc.MODE_MANUAL)

    # Set the X, Y and Z position for tool setter and set the maximum value for "spindle zero".
    def set_setter_position(self):
        if self.showdialog(QMessageBox.Question, "SET POSITION", "Really take over the position?"):
            pos = self.get_xyz_position()
            self.x_tool_setter_position_2951_tlp.setValue(pos[0])
            self.y_tool_setter_position_2952_tlp.setValue(pos[1])
            self.z_tool_setter_position_2953_tlp.setValue(pos[2])
            self.spindle_zero_height_3010_tlp.setMaximum(abs(pos[2]))
            self.update_hal_pins_status()

    # Set the X and Y position for probe tool reference surface.
    def set_probe_position(self):
        if self.showdialog(QMessageBox.Question, "SET POSITION", "Really take over the position?"):
            pos = self.get_xyz_position()
            self.x_tool_probe_position_2954_tlp.setValue(pos[0])
            self.y_tool_probe_position_2955_tlp.setValue(pos[1])
            self.update_lineedit_ro_pins()

    

    # Set the value for "spindle zero" depending on the tool setter z position.
    def set_spindle_zero(self):
        pos = self.get_xyz_position()
        value = abs(float(self.z_tool_setter_position_2953_tlp.text())) + pos[2]
        self.spindle_zero_height_3010_tlp.setValue(value)
        self.update_hal_pins_status()



    # Shows a dialog with bigger text and buttons
    def showdialog(self, icon, title, text):
        msgBox = QMessageBox()
        msgBox.setIcon(icon)
        msgBox.setText("<font family = BebasKai size = 10 >"+text+"</font>")
        msgBox.setWindowTitle(title)
        msgBox.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
        try:
            butts = msgBox.findChild(QDialogButtonBox, "qt_msgbox_buttonbox").buttons()
            butts[0].setMinimumHeight(40)
            butts[0].setMinimumWidth(73)

            butts[1].setMinimumHeight(40)
            butts[1].setMinimumWidth(90)
        except:
            print("Not able to get buttons!")
        
        return msgBox.exec() == QMessageBox.Ok

    

    @Slot(QAbstractButton)
    def on_settertabGroup_buttonClicked(self, button):
        self.setter_tab_widget_tlp.setCurrentIndex(button.property('page'))

    ### Hal-pins ###
    ################
    # Creates a HAL-pins for every button in buttons list
    def set_hal_button_pins(self):
        for button in self.buttons:
            if button.isCheckable():
                pin = HalButtonPin(button)
                self.hal_button_pins.append(pin)

    # Creates a HAL-pins for every spinbox in spinboxs list
    def set_hal_spinbox_pins(self):
        for spinbox in self.spinboxs:
            pin = HalSpinBoxPin(spinbox)
            self.hal_spinbox_pins.append(pin)
            

    # Creates a HAL-pins for every combobox in comboboxs list
    def set_hal_combobox_pins(self):
        for combobox in self.comboboxs:
            pin = HalComboBoxPin(combobox)
            self.hal_combobox_pins.append(pin)

    # Creates a HAL-pins for every read only lineedit in lineedit_ro list
    def set_hal_lineedit_ro_pins(self):
        for lineedit in self.lineedits_ro:
            pin = HalLineEditReadOnlyPin(lineedit)
            self.hal_lineedit_ro_pins.append(pin)

### HAL-pin classes ###
#######################
# Class to create HAL-pins for buttons and connecting them
class HalButtonPin:
    def __init__(self, button:VCPSettingsPushButton):
        self.button:VCPSettingsPushButton = button
        self._checked_pin = None
        comp = hal.getComponent()
        obj_name = "tlp." + self.button.objectName().replace("_", "-").replace("-tlp", "")
        
        self._checked_pin = comp.addPin(obj_name + ".checked", "bit", "out")
        self._checked_pin.value = self.button.isChecked()

        self.button.clicked.connect(self.onCheckedStateChanged)

    ### Ändert den Zustand des Pins auf Basis des Button-zustandes
    def onCheckedStateChanged(self, checked):
        if STATUS.isLocked():
            LOG.debug('Skip HAL onCheckedStateChanged')
            return 
        if self._checked_pin is not None:
            self._checked_pin.value = checked

    # Updates the HAL-pin state based on the button.
    def refreshCheckState(self):
        self.onCheckedStateChanged(self.button.isChecked())


# Class to create HAL-pins for spinboxes and connecting them
class HalSpinBoxPin:
    def __init__(self, spinbox:VCPSettingsDoubleSpinBox):
        self.spinbox:VCPSettingsDoubleSpinBox = spinbox
        self._value_pin = None
        comp = hal.getComponent()
        obj_name = "tlp." + self.spinbox.objectName().replace("_", "-")[:-9]
        
        self._value_pin = comp.addPin(obj_name + ".value", "float", "out")
        self.spinbox.editingFinished.connect(self.onEditFinished)
        

    #def onEditFinished(self, text):
    #    if STATUS.isLocked():
    #        LOG.debug('Skip HAL onEditingFinished')
    #        return 
    #    if self._value_pin is not None:
    #        self._value_pin.value = text

    # Updates the HAL-pin state based on the spinbox.
    def onEditFinished(self):
        if STATUS.isLocked():
            LOG.debug('Skip HAL onEditingFinished')
            return 
        if self._value_pin is not None:
            self._value_pin.value = self.spinbox.value()
            
     
# Class to create HAL-pins for comboboxes and connecting them
class HalComboBoxPin:
    def __init__(self, combobox:VCPSettingsComboBox):
        self.combobox:VCPSettingsComboBox = combobox
        self._index_pin = None
        comp = hal.getComponent()
        obj_name = "tlp." + self.combobox.objectName().replace("_", "-")[:-9]
        
        self._index_pin = comp.addPin(obj_name + ".index", "float", "out")
        
        self.combobox.currentIndexChanged.connect(self.onChangeEvent)


    # Updates the HAL-pin state based on the combobox.
    def onChangeEvent(self):
        if STATUS.isLocked():
            LOG.debug('Skip HAL onEditingFinished')
            return 
        if self._index_pin is not None:
            self._index_pin.value = self.combobox.currentIndex()

   
# Class to create HAL-pins for lineedits and connecting them
class HalLineEditReadOnlyPin:
    def __init__(self, lineedit:VCPSettingsLineEdit):
        self.lineedit:VCPSettingsLineEdit = lineedit
        self._value_pin = None
        comp = hal.getComponent()
        obj_name = "tlp." + self.lineedit.objectName().replace("_", "-")[:-9]
        
        self._value_pin = comp.addPin(obj_name + ".value", "float", "out")
        
    # Updates the HAL-pin state based on the lineedit.
    def onEditFinished(self):
        if STATUS.isLocked():
            LOG.debug('Skip HAL onEditingFinished')
            return 
        if self._value_pin is not None:
            self._value_pin.value = float(self.lineedit.text())



