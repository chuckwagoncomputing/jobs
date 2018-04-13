import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: customPage
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  var custom = {}
  for (var i = 0; i < customList.contentItem.children.length; i++) {
   custom[customList.contentItem.children[i].placeholderText] = customList.contentItem.children[i].text
  }
  currentJob.custom = JSON.stringify(custom)
  stack.push("qrc:///qml/descPage.qml")
 }
 ListView {
  id: customList
  anchors.fill: parent
  model: LabelModel
  delegate: TextField {
   width: parent.width
   placeholderText: labelText
  }
 }
 Component.onCompleted: {
  if (currentJob.custom.length > 0) {
   for (var i = 0; i < customList.contentItem.children.length; i++) {
    customList.contentItem.children[i].text = JSON.parse(currentJob.custom)[customList.contentItem.children[i].placeholderText]
   }
  }
 }
}
