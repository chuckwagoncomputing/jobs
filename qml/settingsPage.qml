import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.3

Rectangle {
 id: settingsPage
 anchors.fill: parent
 property bool forwardEnabled: false
 property bool addEnabled: settingsTabs.currentIndex == 0
 signal add()
 onAdd: {
  if (settingsTabs.currentIndex == 0) {
   stack.push("qrc:///qml/labelEntryPage.qml", {index: QmlBridge.labelCount()})
  }
 }

 Component {
  id: noLabelsLabel
  Rectangle {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   Label {
    text: "No Custom Labels.\nUse the + button to add a label."
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 24
   }
  }
 }

 TabBar {
  id: settingsTabs
  width: parent.width
  z: 1
  TabButton {
   text: "Custom"
  }
  TabButton {
   text: "Jobs"
  }
  TabButton {
   text: "Customers"
  }
 }
 StackLayout {
  id: settingsStack
  anchors.top: settingsTabs.bottom
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  currentIndex: settingsTabs.currentIndex
  Item {
   id: customSettingsPage
   anchors.fill: parent
   Loader {
    id: labelListLoader
    anchors.fill: parent
    sourceComponent: settings.customLabels.length > 0 ? Qt.createComponent("qrc:///qml/labelList.qml") : noLabelsLabel
   }
  }
  Item {
   id: jobsSettingsPage
   Column {
    width: parent.width
    ComboBox {
     id: jobDbTypeField
     width: parent.width
     model: ["postgres", "mysql", "mssql", "sqlite3"]
     Component.onCompleted: {
      jobDbTypeField.currentIndex = jobDbTypeField.find(settings.jobDbType)
     }
    }
    TextField {
     id: jobDbHostField
     width: parent.width
     placeholderText: "Host/URL"
     text: settings.jobDbHost
    }
    TextField {
     id: jobDbPortField
     width: parent.width
     placeholderText: "Port"
     text: settings.jobDbPort
    }
    TextField {
     id: jobDbNameField
     width: parent.width
     placeholderText: "DB Name"
     text: settings.jobDbName
    }
    TextField {
     id: jobDbUsernameField
     width: parent.width
     placeholderText: "Username"
     text: settings.jobDbUsername
    }
    TextField {
     id: jobDbPasswordField
     width: parent.width
     echoMode: TextInput.Password
     placeholderText: "Password"
     text: settings.jobDbPassword
    }
   }
  }
  Item {
   id: customerSettingsPage
   Column {
    width: parent.width
    TextField {
     id: customerUrlField
     width: parent.width
     placeholderText: "URL"
     text: settings.customerUrl
    }
    TextField {
     id: customerUsernameField
     width: parent.width
     placeholderText: "Username"
     text: settings.customerUsername
    }
    TextField {
     id: customerPasswordField
     width: parent.width
     placeholderText: "Password"
     echoMode: TextInput.Password
     text: settings.customerPassword
    }
   }
  }
 }
 StackView.onStatusChanged: {
  // Check for changes and save them
  if (StackView.status === StackView.Deactivating) {
   var jobDbChanged, customerChanged = false
   if (settings.jobDbType != jobDbTypeField.currentText) {
    settings.jobDbType = jobDbTypeField.currentText
    jobDbChanged = true
   }
   if (settings.jobDbHost != jobDbHostField.text) {
    settings.jobDbHost = jobDbHostField.text
    jobDbChanged = true
   }
   if (settings.jobDbPort != jobDbPortField.text) {
    settings.jobDbPort = jobDbPortField.text
    jobDbChanged = true
   }
   if (settings.jobDbName != jobDbNameField.text) {
    settings.jobDbName = jobDbNameField.text
    jobDbChanged = true
   }
   if (settings.jobDbUsername != jobDbUsernameField.text) {
    settings.jobDbUsername = jobDbUsernameField.text
    jobDbChanged = true
   }
   if (settings.jobDbPassword != jobDbPasswordField.text) {
    settings.jobDbPassword = jobDbPasswordField.text
    jobDbChanged = true
   }
   if (settings.customerUrl != customerUrlField.text) {
    settings.customerUrl = customerUrlField.text
    customerChanged = true
   }
   if (settings.customerUsername != customerUsernameField.text) {
    settings.customerUsername = customerUsernameField.text
    customerChanged = true
   }
   if (settings.customerPassword != customerPasswordField.text) {
    settings.customerPassword = customerPasswordField.text
    customerChanged = true
   }
   if (jobDbChanged) {
    JobModel.reset()
    QmlBridge.loadJobs(settings.jobDbType,
                       settings.jobDbHost,
                       settings.jobDbPort,
                       settings.jobDbName,
                       settings.jobDbUsername,
                       settings.jobDbPassword)
    window.jobLabelMessage = "Loading Jobs..."
    window.jobLoaderSource = jobLabel
    window.jobsLoaded = false
   }
   if (customerChanged) {
    CustomerModel.reset()
    QmlBridge.loadCustomers(settings.customerUrl,
                            settings.customerUsername,
                            settings.customerPassword)
    window.customersLoaded = -1
   }
  }
 }
}
