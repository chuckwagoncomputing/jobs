import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

ListView {
 id: labelList
 anchors.fill: parent
 model: LabelModel
 delegate: ItemDelegate {
  text: labelText
  width: parent.width
  font.pixelSize: 20
  onClicked:{
   stack.push("qrc:///qml/labelEntryPage.qml", {index: index, fillText: model.labelText})
  }
 }
}
