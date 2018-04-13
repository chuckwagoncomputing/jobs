package main

import (
 "github.com/therecipe/qt/core"
 "time"
)

const Year = int(core.Qt__UserRole) + 1<<iota

type YearModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func() `constructor:"init"`
}

func (ym *YearModel) init() {
 ym.SetRoles(map[int]*core.QByteArray{
  Year: core.NewQByteArray2("year", len("year")),
 })
 ym.ConnectData(ym.data)
 ym.ConnectRowCount(ym.rowCount)
 ym.ConnectRoleNames(ym.roleNames)
}

func (ym *YearModel) roleNames() map[int]*core.QByteArray {
 return ym.Roles()
}

func (ym *YearModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= 10 {
  return core.NewQVariant()
 }
 return core.NewQVariant10(uint64(time.Now().Year() - index.Row()))
}

func (ym *YearModel) rowCount(parent *core.QModelIndex) int {
 return 10
}

