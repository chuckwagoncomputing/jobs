import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

ListView {
 id: jobList
 model: JobModel
 // Set this list so the last added items are at top
 verticalLayoutDirection: ListView.BottomToTop
 delegate: ItemDelegate {
  anchors.left: parent.left
  anchors.right: parent.right
  Text {
   anchors.left: parent.left
   anchors.top: parent.top
   font.pixelSize: 20
   text: window.customersLoaded, CustomerModel.getData(jobCustomerId, 1)
  }
  Text {
   anchors.left: parent.left
   anchors.bottom: parent.bottom
   font.pixelSize: 14
   elide: Text.ElideRight
   // Remove newlines
   text: description.replace(/(\r\n|\n|\r)/gm, " ")
  }
  onClicked: {
   if (jobList.currentIndex != index) {
    jobList.currentIndex = index
   }
   currentJob.jobCustomerId = model.jobCustomerId
   currentJob.datetime = model.datetime
   currentJob.custom = model.custom
   currentJob.description = model.description
   currentJob.index = index
   stack.push("qrc:///qml/jobViewPage.qml")
  }
 }
 // This header is added to push the items to the top of the view if there aren't enough to fill the view.
 header: Item {}
 onContentHeightChanged: {
  if (contentHeight < height) {
   headerItem.height += (height - contentHeight)
  }
  currentIndex = count-1
  positionViewAtEnd()
 }
 Component.onCompleted: {
  jobList.positionViewAtEnd()
 }
}
