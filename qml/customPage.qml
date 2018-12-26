import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
	id: customPage
	// Let the page indicator be visible, and this is the fourth page
	property bool indicatorEnabled: true
	property int indicatorIndex: 3
	property bool forwardEnabled: true
	signal forward
	onForward: {
		var custom = {}
		// Fill the custom object with each textfield's placeholder (i.e. the label name) as the key,
		//  and its text as the value
		for (var i = 0; i < customList.contentItem.children.length; i++) {
			custom[customList.contentItem.children[i].placeholderText] = customList.contentItem.children[i].text
		}
		// Save it to the current job
		currentJob.custom = JSON.stringify(custom)
		stack.push("qrc:///qml/descPage.qml")
	}
	ListView {
		id: customList
		anchors.fill: parent
		model: LabelModel
		delegate: TextField {
			width: parent.width
			placeholderText: labelText
		}
	}
	Component.onCompleted: {
		// If there is a current job
		if (currentJob.custom.length > 0) {
			// For each textfield, set the text to that from the current job
			for (var i = 0; i < customList.contentItem.children.length; i++) {
				customList.contentItem.children[i].text = JSON.parse(
							currentJob.custom)[customList.contentItem.children[i].placeholderText]
			}
		}
	}
}
