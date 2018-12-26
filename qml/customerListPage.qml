import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
	id: customerListPage
	// Let the page indicator be visible, and this is the second page.
	property bool indicatorEnabled: true
	property int indicatorIndex: 1
	// No forward button
	property bool forwardEnabled: false
	signal forward
	onForward: {
		stack.push("qrc:///qml/dateTimePage.qml")
	}
	anchors.fill: parent
	ListView {
		id: customerListView
		anchors.fill: parent
		model: CustomerModel
		// If there is a current job, find the index of its customer
		currentIndex: currentJob.jobCustomerId.length > 0 ? model.findIndex(currentJob.jobCustomerId) : -1
		delegate: ItemDelegate {
			text: customerName
			anchors.left: parent.left
			anchors.right: parent.right
			highlighted: ListView.isCurrentItem
			onClicked: {
				// Set as selected
				if (customerListView.currentIndex != index) {
					customerListView.currentIndex = index
				}
				// Save to current job
				currentJob.jobCustomerId = model.customerId
				// Now that something is selected, we can go forward
				if (index >= 0) {
					parent.parent.parent.forwardEnabled = true
				}
			}
		}
		// If there's a current job, i.e. customer is already selected, we can let the user go on to the next step.
		Component.onCompleted: {
			if (customerListView.currentIndex >= 0) {
				parent.forwardEnabled = true
			}
		}
	}
}
