import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: jobListPage
 anchors.fill: parent
 property bool backDisabled: true
 property bool addEnabled: true
 property bool settingsEnabled: true
 signal add()
 onAdd: {
  currentJob.reset()
  stack.push("qrc:///qml/customerListPage.qml")
 }
 Loader {
  id: jobLoader
  anchors.fill: parent
  sourceComponent: window.jobLoaderSource
 }
}

