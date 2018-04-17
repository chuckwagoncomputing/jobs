import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: jobListPage
 anchors.fill: parent
 // Let the page indicator be visible, and this is the first page
 property bool indicatorEnabled: true
 property int indicatorIndex: 0
 property bool backDisabled: true
 property bool addEnabled: true
 property bool settingsEnabled: true
 signal add()
 onAdd: {
  // Reset the current job to empty values
  currentJob.reset()
  if (CustomerModel.count() > 0) {
   stack.push("qrc:///qml/customerListPage.qml")
  }
  // If there are no customers, skip straight to the date/time picker
  else {
   stack.push(["qrc:///qml/customerListPage.qml", "qrc:///qml/dateTimePage.qml"])
  }
 }
 Loader {
  id: jobLoader
  anchors.fill: parent
  sourceComponent: window.jobLoaderSource
 }
}

