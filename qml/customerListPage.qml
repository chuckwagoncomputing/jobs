import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: customerListPage
 property bool forwardEnabled: false
 signal forward()
 onForward: {
  stack.push("qrc:///qml/dateTimePage.qml")
 }
 anchors.fill: parent
 Loader {
  id: customerLoader
  anchors.fill: parent
  sourceComponent: window.customerLoaderSource
 }
}

