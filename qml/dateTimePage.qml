import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import "qml-date-tumblers"

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
  currentJob.datetime = getMonthAbr(monthPicker.month) + " "
                      + dayPicker.day + " "
                      + yearPicker.year + " "
                      + ("00" + hourPicker.hour).slice(-2) + ":"
                      + minutePicker.minute
  if (LabelModel.rowCount() > 0) {
   stack.push("qrc:///qml/customPage.qml")
  }
  else {
   stack.push("qrc:///qml/descPage.qml")
  }
 }

	YearPicker {
		id: yearPicker
		anchors.top: parent.top
		endYear: (new Date()).getFullYear()
		startYear: endYear - 10
		onSubmit: {
			dateTimePage.forward()
		}
		onAbort: {
			stack.pop()
		}
		Component.onCompleted: {
			if (currentJob.date)	{
			 yearPicker.year = (new Date(currentJob.date)).getFullYear()
			}
			else {
				yearPicker.year = (new Date).getFullYear()
			}
		}
	}

	MonthPicker {
		id: monthPicker
		anchors.top: yearPicker.bottom
		onSubmit: {
			dateTimePage.forward()
		}
		onAbort: {
			stack.pop()
		}
		Component.onCompleted: {
			if (currentJob.date)	{
			 monthPicker.month = (new Date(currentJob.date)).getMonth()
			}
			else {
				monthPicker.month = (new Date).getMonth()
			}
		}
	}

	DayPicker {
		id: dayPicker
		anchors.top: monthPicker.bottom
		daysInMonth: (new Date(yearPicker.year, monthPicker.month + 1, 0)).getDate()
		onSubmit: {
			dateTimePage.forward()
		}
		onAbort: {
			stack.pop()
		}
		Component.onCompleted: {
			if (currentJob.date)	{
			 dayPicker.day = (new Date(currentJob.date)).getDate()
			}
			else {
				dayPicker.day = (new Date).getDate()
			}
		}
	}

	HourPicker {
		id: hourPicker
		anchors.top: dayPicker.bottom
		onSubmit: {
			dateTimePage.forward()
		}
		onAbort: {
			stack.pop()
		}
		Component.onCompleted: {
			if (currentJob.date)	{
			 hourPicker.hour = (new Date(currentJob.date)).getHours()
			}
			else {
				hourPicker.hour = (new Date).getHours()
			}
		}
	}

	MinutePicker {
		id: minutePicker
		anchors.top: hourPicker.bottom
		onSubmit: {
			dateTimePage.forward()
		}
		onAbort: {
			stack.pop()
		}
		Component.onCompleted: {
			if (currentJob.date)	{
			 minutePicker.minute = (new Date(currentJob.date)).getMinutes()
			}
			else {
				minutePicker.minute = (new Date).getMinutes()
			}
		}
	}
}
