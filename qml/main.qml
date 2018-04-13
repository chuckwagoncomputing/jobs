import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0

ApplicationWindow {
 id: window
 visible: true
 title: "Jobs"
 minimumWidth: 400
 minimumHeight: 400

 property var customLabels: settings.customLabels.split(",").filter(function(s){ return s != "" })

 Settings {
  id: settings
  property alias x: window.x
  property alias y: window.y
  property alias width: window.width
  property alias height: window.height

  property string jobDbType: "postgres"
  property string jobDbHost: ""
  property string jobDbPort: "5432"
  property string jobDbName: ""
  property string jobDbUsername: "postgres"
  property string jobDbPassword: ""
  property string customerUrl: ""
  property string customerUsername: ""
  property string customerPassword: ""

  property string customLabels: ""
 }

 Connections {
  target: QmlBridge
  onErrorLoadingJobs: {
   window.jobLabelMessage = "Error Loading Jobs: " + errmsg + "\nHave you set up your server?"
   window.jobLoaderSource = jobLabel
  }
  onJobsLoaded: {
   if (count === 0) {
    window.jobLabelMessage = "No Jobs Available. Use the + button to add a job."
    window.jobLoaderSource = jobLabel
   }
   else {
    window.jobLoaderSource = Qt.createComponent("qrc:///qml/jobList.qml")
   }
  }

  onErrorLoadingCustomers: {
   window.customerLabelMessage = "Error Loading Customers: " + errmsg + "\nHave you set up your server?"
   window.customerLoaderSource = customerLabel
  }
  onCustomersLoaded: {
   if (count === 0) {
    window.customerLabelMessage = "No Customers Available."
    window.customerLoaderSource = customerLabel
   }
   else {
    window.customerLoaderSource = Qt.createComponent("qrc:///qml/customerList.qml")
   }
  }

  onError: {
   errorTip.ToolTip.show(errmsg, 3000)
  }
 }

 property var jobLoaderSource: jobLabel
 property var customerLoaderSource: customerLabel
 property string jobLabelMessage: "Loading Jobs..."
 property string customerLabelMessage: "Loading Customers..."

 Component {
  id: jobLabel
  Rectangle {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   Label {
    text: window.jobLabelMessage
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 24
   }
  }
 }

 Component {
  id: customerLabel
  Rectangle {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   Label {
    text: window.customerLabelMessage
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 24
   }
  }
 }

 header: ToolBar {
  Material.foreground: "white"

  Label {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   id: titleLabel
   text: "Jobs"
   font.pixelSize: 20
   horizontalAlignment: Qt.AlignHCenter
   verticalAlignment: Qt.AlignVCenter
   Layout.fillWidth: true
  }

  ToolButton {
   id: backButton
   visible: !stack.currentItem.backDisabled
   anchors.left: parent.left
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/back.png"
   }
   onClicked: {
    stack.pop()
   }
  }

  ToolButton {
   id: addButton
   visible: stack.currentItem.addEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/plus.png"
   }
   onClicked: {
    stack.currentItem.add()
   }
  }

  ToolButton {
   id: forwardButton
   visible: stack.currentItem.forwardEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/forward.png"
   }
   onClicked: {
    stack.currentItem.forward()
   }
  }

  ToolButton {
   id: settingsButton
   visible: stack.currentItem.settingsEnabled || false
   anchors.left: parent.left
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/settings.png"
   }
   onClicked: {
    stack.push("qrc:///qml/settingsPage.qml")
   }
  }

  ToolButton {
   id: editButton
   visible: stack.currentItem.editEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/edit.png"
   }
   onClicked: {
    stack.currentItem.edit()
   }
  }
 }

 StackView {
  id: stack
  anchors.fill: parent
  initialItem: "qrc:///qml/jobListPage.qml"
 }

 Rectangle {
  id: errorTip
  width: parent.width
  anchors.top: parent.bottom
  ToolTip {
   width: parent.width
  }
 }

 Item {
  id: currentJob
  property string jobCustomerId: ""
  property string datetime: ""
  property string custom: ""
  property string description: ""
  property int index: -1
  signal reset()
  onReset: {
   currentJob.jobCustomerId = ""
   currentJob.datetime = ""
   currentJob.custom = ""
   currentJob.description = ""
   currentJob.index = -1
  }
 }

 Component.onCompleted: {
  if (window.customLabels.length > 0) {
   QmlBridge.loadLabels(window.customLabels)
  }
  QmlBridge.loadJobs(settings.jobDbType,
                     settings.jobDbHost,
                     settings.jobDbPort,
                     settings.jobDbName,
                     settings.jobDbUsername,
                     settings.jobDbPassword)
  QmlBridge.loadCustomers(settings.customerUrl,
                          settings.customerUsername,
                          settings.customerPassword)
 }
}
