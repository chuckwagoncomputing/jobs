import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: labelEntryPage
 anchors.fill: parent
 property int index
 property string fillText
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  if (labelEntryPage.fillText.length > 0) {
   window.customLabels[labelEntryPage.index] = labelText.text
   settings.customLabels = window.customLabels.join(",")
   QmlBridge.updateLabel(labelEntryPage.index, labelText.text)
  }
  else {
   window.customLabels.push(labelText.text)
   settings.customLabels = window.customLabels.join(",")
   QmlBridge.newLabel(labelText.text)
  }
  stack.pop()
 }
 TextField {
  id: labelText
  anchors.verticalCenter: parent.verticalCenter
  width: parent.width
  text: labelEntryPage.fillText
  placeholderText: "Label"
 }
 Button {
  text: "Delete"
  width: parent.width
  anchors.bottom: parent.bottom
  onClicked: {
   if (labelEntryPage.fillText.length > 0) {
    window.customLabels.splice(labelEntryPage.index, 1)
    settings.customLabels = window.customLabels.join(",")
    QmlBridge.removeLabel(labelEntryPage.index)
   }
   stack.pop()
  }
 }
}
