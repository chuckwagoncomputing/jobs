import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
	id: descPage
	// Let the page indicator be visible, and this is the fifth page
	property bool indicatorEnabled: true
	property int indicatorIndex: 4
	property bool forwardEnabled: true
	signal forward
	onForward: {
		// Save to current job
		currentJob.description = description.text
		// If the current job doesn't have an index, it must be new, so save it.
		if (currentJob.index < 0) {
			QmlBridge.newJob(currentJob.jobCustomerId, currentJob.datetime,
																				currentJob.custom, currentJob.description)
		} // If it does, we must be editing, save the changes
		else {
			QmlBridge.editJob(currentJob.index, currentJob.jobCustomerId,
																					currentJob.datetime, currentJob.custom,
																					currentJob.description)
		}
		// Go back to the list
		stack.push("qrc:///qml/jobListPage.qml")
	}
	ScrollView {
		anchors.fill: parent
		TextArea {
			id: description
			placeholderText: "Description"
			wrapMode: Text.Wrap
		}
	}
	Component.onCompleted: {
		if (currentJob.description.length > 0) {
			description.text = currentJob.description
		}
	}
}
