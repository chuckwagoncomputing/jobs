package main

import (
 "github.com/therecipe/qt/core"
 "unsafe"
)

const LabelText = int(core.Qt__UserRole) + 1<<iota

type LabelModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func() `constructor:"init"`

 _ func(*Label) `slot:"addLabel"`
 _ []*Label `property:"labels"`
}

func (lm *LabelModel) init() {
 lm.SetRoles(map[int]*core.QByteArray{
  LabelText: core.NewQByteArray2("labelText", len("labelText")),
 })
 lm.ConnectData(lm.data)
 lm.ConnectRowCount(lm.rowCount)
 lm.ConnectRoleNames(lm.roleNames)
}

func (lm *LabelModel) roleNames() map[int]*core.QByteArray {
 return lm.Roles()
}

type Label struct {
 LabelText string
}

func (lm *LabelModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= len(lm.Labels()) {
  return core.NewQVariant()
 }
 switch role {
  case LabelText:
   return core.NewQVariant14(lm.Labels()[index.Row()].LabelText)
  default:
   return core.NewQVariant()
 }
}

func (lm *LabelModel) rowCount(parent *core.QModelIndex) int {
 return len(lm.Labels())
}

func (lm *LabelModel) labelCount() int {
 return len(lm.Labels())
}

func (lm *LabelModel) loadLabelsShim(l []string) {
 go lm.loadLabels(l)
}

func (lm *LabelModel) loadLabels(ls []string) {
 var labels []*Label
 for _, l := range ls {
  labels = append(labels, &Label{l})
 }
 lm.BeginInsertRows(core.NewQModelIndex(), 0, len(labels) - 1)
 lm.SetLabels(labels)
 lm.EndInsertRows()
}

func (lm *LabelModel) newLabelShim(t string) {
 l := &Label{t}
 go lm.addLabel(l)
}

func (lm *LabelModel) addLabel(l *Label) {
 lm.BeginInsertRows(core.NewQModelIndex(), len(lm.Labels()), len(lm.Labels()))
 lm.SetLabels(append(lm.Labels(), l))
 lm.EndInsertRows()
}


func (lm *LabelModel) updateLabelShim(i int, t string) {
 go lm.updateLabel(i, t)
}

func (lm *LabelModel) updateLabel(i int, t string) {
 l := &Label{t}
 nl := lm.Labels()
 nl[i] = l
 lm.SetLabels(nl)
 lm.DataChanged(lm.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), lm.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), []int{LabelText})
}

func (lm *LabelModel) removeLabelShim(i int) {
 go lm.removeLabel(i)
}

func (lm *LabelModel) removeLabel(i int) {
 lm.BeginRemoveRows(core.NewQModelIndex(), i, i)
 lm.SetLabels(append(lm.Labels()[:i], lm.Labels()[i+1:]...))
 lm.EndRemoveRows()
 lm.DataChanged(lm.CreateIndex(0, 0, unsafe.Pointer(new(uintptr))), lm.CreateIndex(len(lm.Labels()), 0, unsafe.Pointer(new(uintptr))), []int{LabelText})
}
