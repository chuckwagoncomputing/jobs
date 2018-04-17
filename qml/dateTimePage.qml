import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: dateTimePage
 // Let the page indicator be visible, and this is the third page
 property bool indicatorEnabled: true
 property int indicatorIndex: 2
 // If there are no customers, we need to pop twice when going back.
 // This is checked in main.qml, in the backButton onClicked
 property bool doublePop: CustomerModel.count() > 0 ? false : true
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  // Save the date
  currentJob.datetime = monthPicker.currentItem.text + " "
                      + dayPicker.currentItem.text + " "
                      + yearPicker.currentItem.text + " "
                      + ("00" + hourPicker.currentItem.text).slice(-2) + ":"
                      + minutePicker.currentItem.text
  if (LabelModel.rowCount() > 0) {
   stack.push("qrc:///qml/customPage.qml")
  }
  else {
   stack.push("qrc:///qml/descPage.qml")
  }
 }

 ListModel {
  id: monthModel
  ListElement {
   month: "Jan"
   days: 31
  }
  ListElement {
   month: "Feb"
   days: 28
  }
  ListElement {
   month: "Mar"
   days: 31
  }
  ListElement {
   month: "Apr"
   days: 30
  }
  ListElement {
   month: "May"
   days: 31
  }
  ListElement {
   month: "Jun"
   days: 30
  }
  ListElement {
   month: "Jul"
   days: 31
  }
  ListElement {
   month: "Aug"
   days: 31
  }
  ListElement {
   month: "Sep"
   days: 30
  }
  ListElement {
   month: "Oct"
   days: 31
  }
  ListElement {
   month: "Nov"
   days: 30
  }
  ListElement {
   month: "Dec"
   days: 31
  }
 }

 Tumbler {
  id: yearPicker
  // These tumblers are rotated horizontally, which messes up the positioning, so we must position them manually.
  y: -180
  rotation: -90
  height: parent.width
  anchors.horizontalCenter: parent.horizontalCenter
  model: YearModel
  delegate: Text {
   rotation: 90
   anchors.right: parent.horizontalCenter
   text: year
   opacity: 0.4 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 0.6
   font.pixelSize: 15 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 3
  }
  Component.onCompleted: {
   if (currentJob.datetime.length > 0) {
    // If there's a current job, we'll subtract the difference between this year and the job year to get the index.
    //  0    1    2    3    4
    //  2018 2017 2016 2015 2014
    //  2018     -     2015 = 3
    var dn = new Date
    var d = new Date(currentJob.datetime)
    yearPicker.currentIndex = dn.getYear() - d.getYear()
   }
  }
 }
 Tumbler {
  id: monthPicker
  y: -140
  rotation: -90
  height: parent.width
  anchors.horizontalCenter: parent.horizontalCenter
  model: monthModel
  delegate: Text {
   rotation: 90
   anchors.right: parent.horizontalCenter
   text: month
   opacity: 0.4 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 0.6
   font.pixelSize: 15 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 3
  }
  Component.onCompleted: {
   var d
   if (currentJob.datetime.length > 0) {
    d = new Date(currentJob.datetime)
   }
   else {
    d = new Date
   }
   monthPicker.currentIndex = d.getMonth()
   dayPicker.setToday()
  }
 }
 Tumbler {
  id: dayPicker
  y: -100
  rotation: -90
  height: parent.width
  anchors.horizontalCenter: parent.horizontalCenter
  model: monthModel.get(monthPicker.currentIndex).days
  delegate: Text {
   rotation: 90
   anchors.right: parent.horizontalCenter
   text: modelData + 1
   opacity: 0.4 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 0.6
   font.pixelSize: 15 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 3
  }
  signal setToday
  onSetToday: {
   var d
   if (currentJob.datetime.length > 0) {
    d = new Date(currentJob.datetime)
   }
   else {
    d = new Date
   }
   dayPicker.currentIndex = d.getDate() - 1
  }
 }
 Tumbler {
  id: hourPicker
  y: -60
  rotation: -90
  height: parent.width
  anchors.horizontalCenter: parent.horizontalCenter
  model: 24
  delegate: Text {
   rotation: 90
   anchors.right: parent.horizontalCenter
   text: modelData
   opacity: 0.4 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 0.6
   font.pixelSize: 15 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 3
  }
  Component.onCompleted: {
   var d
   if (currentJob.datetime.length > 0) {
    d = new Date(currentJob.datetime)
   }
   else {
    d = new Date
   }
   hourPicker.currentIndex = d.getHours()
  }
 }
 Tumbler {
  id: minutePicker
  y: -20
  rotation: -90
  height: parent.width
  anchors.horizontalCenter: parent.horizontalCenter
  model: 12
  delegate: Text {
   rotation: 90
   anchors.right: parent.horizontalCenter
   // This picker is in 5 minute intervals
   text: ("00" + (modelData * 5)).slice(-2)
   opacity: 0.4 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 0.6
   font.pixelSize: 15 + Math.max(0, 1 - Math.abs(Tumbler.displacement)) * 3
  }
  Component.onCompleted: {
   var d
   if (currentJob.datetime.length > 0) {
    d = new Date(currentJob.datetime)
   }
   else {
    d = new Date
   }
   // This division is because of the 5 minute intervals
   minutePicker.currentIndex = d.getMinutes() / 5
  }
 }
}
