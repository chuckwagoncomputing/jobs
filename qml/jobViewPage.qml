import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: jobViewPage
 anchors.fill: parent
 property bool forwardEnabled: false
 property bool editEnabled: true
 signal edit()
 onEdit: {
  stack.push("qrc:///qml/customerListPage.qml")
 }
 ScrollView {
  anchors.top: parent.top
  anchors.bottom: deleteButton.top
  Label {
   id: customerNameLabel
   width: parent.width
   text: CustomerModel.findName(currentJob.jobCustomerId)
   font.pixelSize: 26
   anchors.margins: 10
  }
  Label {
   id: dateTimeLabel
   anchors.top: customerNameLabel.bottom
   width: parent.width
   text: currentJob.datetime
   font.pixelSize: 20
   anchors.margins: 10
  }
  Label {
   id: descriptionLabel
   anchors.top: dateTimeLabel.bottom
   width: parent.width
   text: currentJob.description
   wrapMode: Text.Wrap
   font.pixelSize: 18
   anchors.margins: 10
  }
  ListView {
   id: customList
   anchors.top: descriptionLabel.bottom
   anchors.bottom: parent.bottom
   anchors.margins: 10
   model: LabelModel
   delegate: Label {
    width: parent.width
    font.pixelSize: 18
    Component.onCompleted: {
     if (JSON.parse(currentJob.custom)[model.labelText].length > 0) {
      text = model.labelText
           + ": "
           + JSON.parse(currentJob.custom)[model.labelText]
     }
    }
   }
  }
 }
 Button {
  id: deleteButton
  text: "Delete"
  width: parent.width
  anchors.bottom: parent.bottom
  onClicked: {
   QmlBridge.removeJob(currentJob.index)
   stack.pop()
  }
 }
}
