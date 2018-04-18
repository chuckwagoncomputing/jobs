package main

import (
 "github.com/therecipe/qt/core"
 "github.com/jinzhu/gorm"
 _ "github.com/jinzhu/gorm/dialects/postgres"
 _ "github.com/jinzhu/gorm/dialects/sqlite"
 _ "github.com/jinzhu/gorm/dialects/mysql"
 _ "github.com/jinzhu/gorm/dialects/mssql"
 "time"
 "errors"
 "unsafe"
)

const (
 JobCustomerID = int(core.Qt__UserRole) + 1<<iota
 DateTime
 Custom
 Description
)

type JobModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func() `constructor:"init"`

 _ func(*Job) `slot:"addJob"`
 _ []*Job `property:"jobs"`

 _ func() `slot:"reset"`
}

func (jm *JobModel) init() {
 jm.SetRoles(map[int]*core.QByteArray{
  JobCustomerID: core.NewQByteArray2("jobCustomerId", len("jobCustomerId")),
  DateTime: core.NewQByteArray2("datetime", len("datetime")),
  Custom: core.NewQByteArray2("custom", len("custom")),
  Description: core.NewQByteArray2("description", len("description")),
 })
 jm.ConnectData(jm.data)
 jm.ConnectRowCount(jm.rowCount)
 jm.ConnectRoleNames(jm.roleNames)
 jm.ConnectAddJob(jm.addJob)
 jm.ConnectReset(jm.reset)
}

func (jm *JobModel) roleNames() map[int]*core.QByteArray {
 return jm.Roles()
}

func (jm *JobModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= len(jm.Jobs()) {
  return core.NewQVariant()
 }

 j := jm.Jobs()[index.Row()]

 switch role {
  case JobCustomerID:
   return core.NewQVariant14(j.JobCustomerID)
  case DateTime:
   return core.NewQVariant14(j.DateTime.Format("Jan 2 2006 15:04"))
  case Custom:
   return core.NewQVariant14(j.Custom)
  case Description:
   return core.NewQVariant14(j.Description)
  default:
   return core.NewQVariant()
 }
}

func (jm *JobModel) rowCount(parent *core.QModelIndex) int {
 return len(jm.Jobs())
}

type Job struct {
 gorm.Model

 JobCustomerID string
 DateTime time.Time
 Custom string
 Description string
}

type JobDB struct {
 dbType string
 dbHost string
 dbPort string
 dbName string
 dbUsername string
 dbPassword string
}

// Opens the database and returns a database object.
// Be sure to call db.Close() when you are done with it.
func (jd *JobDB) Open() (*gorm.DB, error) {
 var db *gorm.DB
 var err error
 switch jd.dbType {
  case "sqlite":
   db, err = gorm.Open("sqlite3", jd.dbHost)
  case "mysql":
   db, err = gorm.Open("mysql", jd.dbUsername + ":" + jd.dbPassword + "@tcp(" + jd.dbHost + ":" + jd.dbPort + ")/" + jd.dbName + "?charset=utf8&parseTime=True&loc=Local")
  case "mssql":
   db, err = gorm.Open("mssql", "sqlserver://" + jd.dbUsername + ":" + jd.dbPassword + "@" + jd.dbHost + ":" + jd.dbPort + "?database=" + jd.dbName)
  default:
   db, err = gorm.Open("postgres", "host=" + jd.dbHost + " port=" + jd.dbPort + " user=" + jd.dbUsername + " dbname=" + jd.dbName + " password=" + jd.dbPassword + " sslmode=disable")
 }
 if err != nil {
  return nil, errors.New("Could not connect to database: " + err.Error())
 }
 return db, nil
}

var jobDb JobDB

func (jm *JobModel) loadJobsShim(jdType string, jdHost string, jdPort string, jdName string, jdUsername string, jdPassword string) {
 go jm.loadJobs(jdType, jdHost, jdPort, jdName, jdUsername, jdPassword)
}

func (jm *JobModel) loadJobs(jdType string, jdHost string, jdPort string, jdName string, jdUsername string, jdPassword string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 // Set the DB info, as this is the first time it's been used.
 jobDb = JobDB{jdType, jdHost, jdPort, jdName, jdUsername, jdPassword}
 db, err := jobDb.Open()
 if err != nil {
  qmlBridge.ErrorLoadingJobs(err.Error())
  return
 }
 defer db.Close()
 if err := db.AutoMigrate(&Job{}).Error; err != nil {
  qmlBridge.ErrorLoadingJobs("Failed to automatically migrate database.")
  return
 }
 var jobs []Job
 if err := db.Order("id").Find(&jobs).Error; err != nil {
  qmlBridge.ErrorLoadingJobs("Failed to load jobs from database.")
  return
 }
 // Convert the array of Jobs into an array of *Jobs
 pJobs := make([]*Job, len(jobs))
 for i, _ := range jobs {
  pJobs[i] = &jobs[i]
 }
 jm.SetJobs(pJobs)
 qmlBridge.JobsLoaded(len(jm.Jobs()))
}

func (jm *JobModel) newJobShim(c string, t string, j string, d string) {
 go jm.buildJob(c, t, j, d)
}

func (jm *JobModel) buildJob(c string, t string, j string, d string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 db, err := jobDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to create job: " + err.Error())
  return
 }
 defer db.Close()
 tp, err := time.Parse("Jan 2 2006 15:04", t)
 if err != nil {
  qmlBridge.Error("Error Saving Job: Could not parse date")
  return
 }
 job := Job{JobCustomerID: c, DateTime: tp, Custom: j, Description: d}
 if (len(jm.Jobs()) >= 1) {
  qmlBridge.JobsLoaded(len(jm.Jobs()))
 }
 if err := db.Create(&job); err.Error != nil {
  qmlBridge.Error("Error Saving job: " + err.Error.Error())
  return
 }
 jm.AddJob(&job)
}

func (jm *JobModel) addJob(j *Job) {
 jm.BeginInsertRows(core.NewQModelIndex(), len(jm.Jobs()), len(jm.Jobs()))
 jm.SetJobs(append(jm.Jobs(), j))
 jm.EndInsertRows()
 if (len(jm.Jobs()) == 1) {
  qmlBridge.JobsLoaded(len(jm.Jobs()))
 }
}

func (jm *JobModel) editJobShim(i int, c string, t string, j string, d string) {
 go jm.editJob(i, c, t, j, d)
}

func (jm *JobModel) editJob(i int, c string, t string, j string, d string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 // Check for out-of-range index. This can occur if an item has been deleted but not yet removed from the list.
 if i < 0 || i >= len(jm.Jobs()) {
  qmlBridge.Error("Could not edit job: Index not found.")
  return
 }
 db, err := jobDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to edit job: " + err.Error())
  return
 }
 defer db.Close()
 nr := jm.Jobs()[i]
 nr.JobCustomerID = c
 tp, err := time.Parse("Jan 2 2006 15:04", t)
 if err != nil {
  qmlBridge.Error("Error Saving job: Could not parse date")
  return
 }
 nr.DateTime = tp
 nr.Custom = j
 nr.Description = d
 if err := db.Save(nr); err.Error != nil {
  qmlBridge.Error("Could not save job: " + err.Error.Error())
  return
 }
 nj := jm.Jobs()
 nj[i] = nr
 jm.SetJobs(nj)
 jm.DataChanged(jm.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), jm.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), []int{JobCustomerID, DateTime, Custom, Description})
}

func (jm *JobModel) removeJobShim(i int) {
 go jm.removeJob(i)
}

func (jm *JobModel) removeJob(i int) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 // Check for out-of-range index. This can occur if an item has been deleted but not yet removed from the list.
 if i < 0 || i >= len(jm.Jobs()) {
  qmlBridge.Error("Could not delete job: Index not found.")
  return
 }
 db, err := jobDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to delete job: " + err.Error())
  return
 }
 defer db.Close()
 if err := db.Delete(jm.Jobs()[i]); err.Error != nil {
  qmlBridge.Error("Could not delete job: " + err.Error.Error())
  return
 }
 jm.BeginRemoveRows(core.NewQModelIndex(), i, i)
 jm.SetJobs(append(jm.Jobs()[:i], jm.Jobs()[i+1:]...))
 jm.EndRemoveRows()
}

func (jm *JobModel) reset() {
 jm.BeginRemoveRows(core.NewQModelIndex(), 0, len(jm.Jobs()) - 1)
 jm.SetJobs([]*Job{})
 jm.EndRemoveRows()
}
