import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

ListView {
 id: jobList
 model: JobModel
 verticalLayoutDirection: ListView.BottomToTop
 delegate: ItemDelegate {
  anchors.left: parent.left
  anchors.right: parent.right
  Text {
   anchors.left: parent.left
   anchors.top: parent.top
   font.pixelSize: 20
   text: datetime
  }
  Text {
   anchors.left: parent.left
   anchors.bottom: parent.bottom
   font.pixelSize: 14
   elide: Text.ElideRight
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
 Component.onCompleted: {
  jobList.positionViewAtEnd()
 }
}
