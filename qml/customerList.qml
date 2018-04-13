import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

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
    stack.push("qrc:///qml/dateTimePage.qml")
   }
  }
 }
 Component.onCompleted: {
  if (customerListView.currentIndex >= 0) {
   parent.parent.forwardEnabled = true
  }
 }
}
