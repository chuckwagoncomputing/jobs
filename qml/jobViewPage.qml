import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: jobViewPage
 anchors.fill: parent
 property bool forwardEnabled: false
 property bool editEnabled: true
 signal edit()
 onEdit: {
  stack.push("qrc:///qml/customerListPage.qml")
 }
 Rectangle {
  id: scrollHolder
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  anchors.bottom: deleteButton.top
  ScrollView {
   height: scrollHolder.height
   width: scrollHolder.width
   clip: true
   Column {
    Label {
     id: customerNameLabel
     width: parent.width
     text: window.customersLoaded, CustomerModel.getData(currentJob.jobCustomerId, 1)
     font.pixelSize: 26
     anchors.margins: 10
    }
    Label {
     id: dateTimeLabel
     width: parent.width
     text: currentJob.datetime
     font.pixelSize: 20
     anchors.margins: 10
    }
    Label {
     id: descriptionLabel
     width: jobViewPage.width
     text: currentJob.description
     wrapMode: Text.Wrap
     font.pixelSize: 18
     anchors.margins: 10
    }
    ListView {
     id: customList
     width: scrollHolder.width
     height: 0
     model: LabelModel
     delegate: Label {
      font.pixelSize: 18
      // Set the text to the label with the value held by the label as a key
      Component.onCompleted: {
       // Make the list bigger so everything gets shown properly
       customList.height += height
       var jText = JSON.parse(currentJob.custom)[model.labelText]
       // It won't necessarily exist or have anything in it, so we need to check
       if (typeof(jText) == "string") {
        if (jText.length > 0) {
         text = model.labelText
              + ": "
              + jText
        }
       }
      }
     }
    }
   }
  }
 }
 Button {
  id: copyButton
  text: "Copy TSV"
  width: parent.width
  anchors.bottom: deleteButton.top
  onClicked: {
   var addrLine = CustomerModel.getData(currentJob.jobCustomerId, 3)
   var addr = addrLine.split(";");
   var address = "";
   var city = "";
   var state = "";
   var zip = "";

   if (addr.length > 1) {
    if (addr[2].length > 0 && addr[3].length > 0) {
     address = addr[2];
    }

    if (addr[3].length > 0) {
     city = addr[3];
    }

    if (addr[4].length > 0) {
     state = addr[4];
    }

    if (addr[5].length > 0) {
     zip = addr[5];
    }

    if (address.length === 0 && city.length === 0) {
     var cutAddr = addr[2].split(" ").reverse();
     zip = cutAddr[0];
     state = cutAddr[1];
     city = cutAddr[2];
     address = cutAddr.slice(3).reverse().join(" ");
    }
   }
   var custom = JSON.parse(currentJob.custom)
   var tsvText = "description\tdatetime\tcustomername\tcustomeraddress\tcustomercity\tcustomerstate\tcustomerzip"
   for (var i = 0; i < Object.keys(custom).length; i++) {
    tsvText += "\t" + Object.keys(custom)[i]
   }
   tsvText += "\n"
            + currentJob.description
            + '"\t'
            + currentJob.datetime
            + "\t"
            + CustomerModel.getData(currentJob.jobCustomerId, 1)
            + "\t"
            + address
            + "\t"
            + city
            + "\t"
            + state
            + "\t"
            + zip
   for (var i = 0; i < Object.keys(custom).length; i++) {
    tsvText += '\t' + custom[Object.keys(custom)[i]]
   }
   QmlBridge.copyText(tsvText)
  }
 }
 Button {
  id: deleteButton
  text: "Delete"
  width: parent.width
  anchors.bottom: parent.bottom
  onClicked: {
   QmlBridge.removeJob(currentJob.index)
   stack.pop()
  }
 }
}
