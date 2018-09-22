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

 // Settings can't store arrays for some reason, so we have to store our custom labels as a string
 // Don't get empty labels from the string. If we do, due to the fact that the stored string starts out empty,
 //  we end up with an empty string as array element 0
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
   window.jobsLoaded = 0
  }
  onJobsLoaded: {
   if (count === 0) {
    window.jobLabelMessage = "No Jobs Available. Use the + button to add a job."
    window.jobLoaderSource = jobLabel
   }
   else {
    window.jobLoaderSource = Qt.createComponent("qrc:///qml/jobList.qml")
   }
   window.jobsLoaded = count
  }

  onErrorLoadingCustomers: {
   window.customersDoneLoading = 0
   QmlBridge.error("Error Loading Customers: " + errmsg)
  }
  onCustomersLoaded: {
   window.customersLoaded = count
   window.customersDoneLoading = done
  }

  onError: {
   errorToolTip.text = errmsg
   errorToolTip.visible = true
  }
 }

 property var jobLoaderSource: jobLabel
 property string jobLabelMessage: "Loading Jobs..."

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
    // If there are no customers, dateTimePage needs to pop twice, so it sets doublePop true
    if (stack.currentItem.doublePop) {
     stack.pop()
    }
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

  ToolButton {
   id: refreshButton
   visible: stack.currentItem.refreshEnabled || false
   anchors.left: settingsButton.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/refresh.png"
   }
   onClicked: {
    JobModel.reset()
    CustomerModel.reset()
    window.jobLoaderSource = jobLabel
    window.jobLabelMessage = "Loading Jobs..."
    QmlBridge.loadJobs(settings.jobDbType,
                       settings.jobDbHost,
                       settings.jobDbPort,
                       settings.jobDbName,
                       settings.jobDbUsername,
                       settings.jobDbPassword)
    QmlBridge.loadCustomers(settings.customerUrl,
                            settings.customerUsername,
                            settings.customerPassword)
    window.jobsLoaded = -1
    window.customersLoaded = -1
    window.customersDoneLoading = -1
   }
  }

  // This a new type of page indicator which I invented...
  PageIndicator {
   id: editIndicator
   z: 1
   spacing: 10
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.top: titleLabel.bottom
   currentIndex: stack.currentItem.indicatorIndex || false
   visible: stack.currentItem.indicatorEnabled || false
   count: 5
   delegate: Loader {
    property var thisIndex: index
    sourceComponent: {
     // Each indicator dot has three states: Loading, Loaded, or N/A
     switch (index) {
      case 0:
       if (window.jobsLoaded > 1) {
        return indicatorRect
       }
       else if (window.jobsLoaded === -1) {
        return indicatorLoading
       }
       else {
        return indicatorNa
       }
       break;
      case 1:
       if (window.customersDoneLoading >= 1) {
        return indicatorRect
       }
       else if (window.customersDoneLoading === -1) {
        return indicatorLoading
       }
       else {
        return indicatorNa
       }
       break;
      // Only the first two pages actually have states other than Loaded
      default:
       return indicatorRect
     }
    }
   }
  }
 }

 // -1: Loading
 //  0: N/A
 // >0: Loaded
 property int jobsLoaded: -1
 property int customersLoaded: -1
 property int customersDoneLoading: -1

 Component {
  id: indicatorLoading
  BusyIndicator {
   height: 28
   width: 28
   y: -8
   running: true
   opacity: parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
  }
 }

 Component {
  id: indicatorRect
  // The rect-in-rect is to achieve the same sizing as the loading indicator
  Rectangle {
   height: 28
   width: 28
   y: -8
   color: "transparent"
   Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 15
    implicitHeight: 15
    radius: width
    color: "#21be2b"
    opacity: parent.parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
   }
  }
 }

 Component {
  id: indicatorNa
  Rectangle {
   height: 28
   width: 28
   y: -8
   color: "transparent"
   Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 15
    implicitHeight: 5
    color: "#21be2b"
    opacity: parent.parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
   }
  }
 }

 StackView {
  id: stack
  anchors.fill: parent
  initialItem: "qrc:///qml/jobListPage.qml"
 }

 Rectangle {
  anchors.bottom: parent.bottom
  anchors.margins: 10
  anchors.left: parent.left
  anchors.right: parent.right
  z: 1
  ToolTip {
   id: errorToolTip
   width: parent.width
   timeout: 3000
   contentItem: Text {
    width: parent.width
    text: errorToolTip.text
    font: errorToolTip.font
    color: "#ffffff"
    wrapMode: Text.Wrap
   }
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

 // Handle the back button in Android
 onClosing: {
  if (Qt.platform.os == "android" && backButton.visible) {
   stack.pop()
   close.accepted = false
  }
 }
}
