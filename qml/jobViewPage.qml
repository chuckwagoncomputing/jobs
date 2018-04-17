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
 Rectangle {
  id: scrollHolder
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  anchors.bottom: deleteButton.top
  ScrollView {
   height: scrollHolder.height
   width: scrollHolder.width
   clip: true
   Column {
    Label {
     id: customerNameLabel
     width: parent.width
     text: CustomerModel.findName(currentJob.jobCustomerId)
     font.pixelSize: 26
     anchors.margins: 10
    }
    Label {
     id: dateTimeLabel
     width: parent.width
     text: currentJob.datetime
     font.pixelSize: 20
     anchors.margins: 10
    }
    Label {
     id: descriptionLabel
     width: jobViewPage.width
     text: currentJob.description
     wrapMode: Text.Wrap
     font.pixelSize: 18
     anchors.margins: 10
    }
    ListView {
     id: customList
     width: scrollHolder.width
     height: 0
     model: LabelModel
     delegate: Label {
      font.pixelSize: 18
      // Set the text to the label with the value held by the label as a key
      Component.onCompleted: {
       // Make the list bigger so everything gets shown properly
       customList.height += height
       var jText = JSON.parse(currentJob.custom)[model.labelText]
       // It won't necessarily exist or have anything in it, so we need to check
       if (typeof(jText) == "string") {
        if (jText.length > 0) {
         text = model.labelText
              + ": "
              + jText
        }
       }
      }
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
