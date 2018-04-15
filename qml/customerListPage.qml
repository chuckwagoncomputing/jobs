import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: customerListPage
 property bool indicatorEnabled: true
 property int indicatorIndex: 1
 property bool forwardEnabled: false
 signal forward()
 onForward: {
  stack.push("qrc:///qml/dateTimePage.qml")
 }
 anchors.fill: parent
 ListView {
  id: customerListView
  anchors.fill: parent
  model: CustomerModel
  currentIndex: currentJob.jobCustomerId.length > 0 ? model.findIndex(currentJob.jobCustomerId) : -1
  delegate: ItemDelegate {
   text: customerName
   anchors.left: parent.left
   anchors.right: parent.right
   highlighted: ListView.isCurrentItem
   onClicked: {
    if (customerListView.currentIndex != index) {
     customerListView.currentIndex = index
    }
    currentJob.jobCustomerId = model.customerId
    if (index >= 0) {
     parent.parent.parent.forwardEnabled = true
    }
   }
  }
  Component.onCompleted: {
   if (customerListView.currentIndex >= 0) {
    parent.forwardEnabled = true
   }
  }
 }
}

