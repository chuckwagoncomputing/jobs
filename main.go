package main

import (
	"github.com/therecipe/qt/core"
	"github.com/therecipe/qt/gui"
	"github.com/therecipe/qt/qml"
	"github.com/therecipe/qt/quickcontrols2"
	"os"
	"sync"
)

type QmlBridge struct {
	core.QObject

	_ func(errmsg string) `signal:"error"`

	_ func(jdType string, jdHost string, jdPort string, jdName string, jdUsername string, jdPassword string) `slot:"loadJobs"`
	_ func(count int)                                                                                        `signal:"jobsLoaded"`
	_ func(errmsg string)                                                                                    `signal:"errorLoadingJobs"`
	_ func(c string, t string, j string, d string)                                                           `slot:"newJob"`
	_ func(i int, c string, t string, j string, d string)                                                    `slot:"editJob"`
	_ func(i int)                                                                                            `slot:"removeJob"`

	_ func(cUrl string, cUsername string, cPassword string) `slot:"loadCustomers"`
	_ func(count int, done int)                             `signal:"customersLoaded"`
	_ func(errmsg string)                                   `signal:"errorLoadingCustomers"`

	_ func(l []string)      `slot:"loadLabels"`
	_ func(t string)        `slot:"newLabel"`
	_ func(i int, t string) `slot:"updateLabel"`
	_ func(i int)           `slot:"removeLabel"`
	_ func() int            `slot:"labelCount"`

	_ func(t string) `slot:"copyText"`
}

var qmlBridge *QmlBridge
var customerModel *CustomerModel
var jobModel *JobModel
var labelModel *LabelModel

// dbMutex is for controlling DB access.
var dbMutex sync.Mutex

var app *gui.QGuiApplication

func main() {
	qmlBridge = NewQmlBridge(nil)
	customerModel = NewCustomerModel(nil)
	jobModel = NewJobModel(nil)
	labelModel = NewLabelModel(nil)

	core.QCoreApplication_SetAttribute(core.Qt__AA_EnableHighDpiScaling, true)
	gui.NewQGuiApplication(len(os.Args), os.Args)
	quickcontrols2.QQuickStyle_SetStyle("material")
	view := qml.NewQQmlApplicationEngine(nil)

	qmlBridge.ConnectLoadJobs(jobModel.loadJobsShim)
	qmlBridge.ConnectNewJob(jobModel.newJobShim)
	qmlBridge.ConnectEditJob(jobModel.editJobShim)
	qmlBridge.ConnectRemoveJob(jobModel.removeJobShim)
	qmlBridge.ConnectLoadCustomers(customerModel.loadCustomersShim)
	qmlBridge.ConnectLoadLabels(labelModel.loadLabelsShim)
	qmlBridge.ConnectNewLabel(labelModel.newLabelShim)
	qmlBridge.ConnectUpdateLabel(labelModel.updateLabelShim)
	qmlBridge.ConnectRemoveLabel(labelModel.removeLabelShim)
	qmlBridge.ConnectLabelCount(labelModel.labelCount)
	qmlBridge.ConnectCopyText(copyText)

	view.RootContext().SetContextProperty("QmlBridge", qmlBridge)
	view.RootContext().SetContextProperty("CustomerModel", customerModel)
	view.RootContext().SetContextProperty("JobModel", jobModel)
	view.RootContext().SetContextProperty("LabelModel", labelModel)

	view.Load(core.NewQUrl3("qrc:///qml/main.qml", 0))
	gui.QGuiApplication_Exec()
}

func copyText(t string) {
	clipboard := app.Clipboard()
	clipboard.SetText(t, gui.QClipboard__Clipboard)
}
