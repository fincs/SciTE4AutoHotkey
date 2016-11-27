
#Include VarTreeGui.ahk
#Include VarEditGui.ahk

DvInspectProperty(dbg, fullname, extra_args:="", show_opt:="") {
    dbg.feature_set("-n max_depth -v 1")
    ; 1MB seems reasonably permissive.  Note that -m 0 (unlimited
    ; according to the spec) doesn't work with v1.1.24.02 and earlier.
    dbg.property_get("-m 1048576 -n " fullname (extra_args="" ? "" : " " extra_args), response)
    dbg.feature_set("-n max_depth -v 0")
    prop := DvLoadXml(response).selectSingleNode("/response/property")
    
    if (prop.getAttribute("name") = "(invalid)") {
        MsgBox, 48,, Invalid variable name: %fullname%
        return false
    }
    
    type := prop.getAttribute("type")
    if (type != "object") {
        isReadOnly := prop.getAttribute("facet") = "Builtin"
        value := DBGp_Base64UTF8Decode(prop.text)
        dv := new DebugVarGui(dbg, {name: fullname, value: value, type: type, readonly: isReadOnly})
    }
    else {
        dv := new DebugVarsGui(new DvPropertyNode(dbg, prop))
    }
    dv.Show(show_opt)
}

class DebugVarGui extends VarEditGui
{
    __New(dbg, var) {
        base.__New(var)
        this.dbg := dbg
    }
    
    OnSave(value, type) {
        DvSetProperty(this.dbg, this.var.name, value, type)
        this.var.value := value
        this.var.type := type
        DvRefreshAll()
    }
}

DvSetProperty(dbg, fullname, ByRef value, type, ByRef response:="") {
    if (type = "integer")
        value := format("{:i}", value) ; Force decimal format.
    if (type = "integer" || type = "float") && dbg.no_base64_numbers
        data := value
    else
        data := DBGp_Base64UTF8Encode(value)
    dbg.property_set("-n " fullname " -t " type " -- " data, response)
}

class DvNodeBase extends TreeListView._Base
{
    expanded {
        set {
            if value {
                ; Expanded for the first time: populate.
                this.children := this.GetChildren()
                ObjRawSet(this, "expanded", true)
            }
            return value
        }
        get {
            return false
        }
    }
    
    SetValue(value) {
        return false
    }
    
    Clone() {
        node := ObjClone(this)
        node.children := this.GetChildren()
        return node
    }
    
    Update(tlv) {
        for i, child in this.children
            child.Update(tlv)
    }
}

class DvPropertyParentNode extends DvNodeBase
{
    UpdateChildren(tlv, props) {
        children := this.children
        if !children {
            if !props.length
                return
            this.children := children := []
        }
        np := 0, nc := 1
        loop {
            if (np < props.length) {
                prop := props.item(np)
                if (nc > children.Length() || prop.getAttribute("name") < children[nc].name) {
                    tlv.InsertChild(this, nc, new DvPropertyNode(this.dbg, prop))
                    ++nc, ++np
                    continue
                }
                if (prop.getAttribute("name") = children[nc].name) {
                    children[nc].Update(tlv, prop)
                    ++nc, ++np
                    continue
                }
            }
            if (nc > children.Length())
                break
            tlv.RemoveChild(this, nc)
        }
    }
}

class DvPropertyNode extends DvPropertyParentNode
{
    __new(dbg, prop) {
        this.dbg := dbg
        this.fullname := prop.getAttribute("fullname")
        this.name := prop.getAttribute("name")
        this.xml := prop
        props := prop.selectNodes("property")
        if props.length {
            this.children := this.FromXmlNodes(props, dbg)
            ObjRawSet(this, "expanded", false)
        }
        else {
            this._value := DBGp_Base64UTF8Decode(prop.text)
        }
        this.values := [this.name, this.GetValueString()]
    }
    
    value {
        set {
            this._value := value
            this.values[2] := this.GetValueString()
            return value
        }
        get {
            return this._value
        }
    }
    
    FromXmlNodes(props, dbg) {
        nodes := []
        for prop in props
            nodes.Push(new DvPropertyNode(dbg, prop))
        return nodes
    }
    
    expandable {
        get {
            return this.xml.getAttribute("children")
        }
    }
    
    GetProperty() {
        this.dbg.feature_set("-n max_depth -v 1")
        this.dbg.property_get("-n " this.fullname, response)
        this.dbg.feature_set("-n max_depth -v 0")
        xml := DvLoadXml(response)
        return this.xml := xml.selectSingleNode("/response/property")
    }
    
    GetChildren() {
        prop := this.GetProperty()
        props := prop.selectNodes("property")
        return DvPropertyNode.FromXmlNodes(props, this.dbg)
    }
    
    GetValueString() {
        if (cn := this.xml.getAttribute("classname"))
            return cn
        utf8_len := StrPut(this.value, "UTF-8") - 1
        return this.value (this.xml.getAttribute("size") > utf8_len ? "..." : "")
    }
    
    GetWindowTitle() {
        title := "Inspector - " this.fullname
        if prop := this.xml {
            if !(type := prop.getAttribute("classname"))
                type := prop.getAttribute("type")
            title .= " (" type ")"
        }
        return title
    }
    
    SetValue(ByRef value) {
        type := this.xml.getAttribute("type") ; Try to match type of previous value.
        if (type = "float" || type = "integer") && value+0 != ""
            type := InStr(value, ".") ? "float" : "integer"
        else
            type := "string"
        DvSetProperty(this.dbg, this.xml.getAttribute("fullname")
            , value, type, response)
        if InStr(response, "<error") || InStr(response, "success=""0""")
            return false
        ; Update .xml for @classname and @children, and in case the value
        ; differs from what we set (e.g. for setting A_KeyDelay in v2).
        this.GetProperty()
        this.value := value := DBGp_Base64UTF8Decode(this.xml.text)
    }
    
    Update(tlv, prop:="") {
        had_children := this.xml.getAttribute("children")
        if !prop || prop.getAttribute("children") && !prop.selectSingleNode("property")
            prop := this.GetProperty()
        else
            this.xml := prop
        props := prop.selectNodes("property")
        value2 := this.values[2]
        this.value := props.length ? "" : DBGp_Base64UTF8Decode(prop.text)
        if !(this.values[2] "" ==  "" value2) ; Prevent unnecessary redraw and flicker.
            || (had_children != prop.getAttribute("children"))
            tlv.RefreshValues(this)
        this.UpdateChildren(tlv, props)
    }
}

class DvContextNode extends DvPropertyParentNode
{
    static expandable := true
    
    __new(dbg, context) {
        this.dbg := dbg
        this.context := context
    }
    
    values {
        get {
            return [this.GetWindowTitle(), ""]
        }
    }
    
    GetProperties() {
        this.dbg.context_get("-c " this.context, response)
        xml := DvLoadXml(response)
        return xml.selectNodes("/response/property")
    }
    
    GetChildren() {
        props := this.GetProperties()
        return DvPropertyNode.FromXmlNodes(props, this.dbg)
    }
    
    GetWindowTitle() {
        return this.context=0 ? "Local vars" : "Global vars"
    }
    
    Update(tlv) {
        props := this.GetProperties()
        this.UpdateChildren(tlv, props)
    }
}

class Dv2ContextsNode extends DvNodeBase
{
    static expandable := true
    
    __new(dbg) {
        this.dbg := dbg
    }
    
    GetChildren() {
        children := []
        Loop 2 {
            children[A_Index] := new DvContextNode(this.dbg, A_Index-1)
            children[A_Index].expanded := true
        }
        return children
    }
    
    GetWindowTitle() {
        return "Variables"
    }
}

class DebugVarsGui extends VarTreeGui
{
    Show(options:="", title:="") {
        return base.Show(options
            , title != "" ? title : this.TLV.root.GetWindowTitle())
    }
    
    UnregisterHwnd() {
        base.UnregisterHwnd()
        this.SetAutoRefresh(0)
    }
    
    class Control extends VarTreeGui.Control
    {
        LV_Key_F5() {
            VarTreeGui.Instances[this.hGui].Refresh()
        }
        
        LV_Key_Enter(r, node) {
            DvInspectProperty(node.dbg, node.xml.getAttribute("fullname"))
        }
    }
    
    OnContextMenu(node, isRightClick, x, y) {
        try Menu DvContext, DeleteAll  ; In case we're interrupting a prior call.
        if node.base != DvPropertyNode
            Menu DvContext, Add, New window, DV_CM_NewWindow
        else
            Menu DvContext, Add, Inspect, DV_CM_InspectNode
        Menu DvContext, Add, Refresh, DV_CM_Refresh
        Menu DvRefresh, Add, Off, DV_CM_AutoRefresh
        Menu DvRefresh, Add, 0.5 s, DV_CM_AutoRefresh
        Menu DvRefresh, Add, 1.0 s, DV_CM_AutoRefresh
        Menu DvRefresh, Add, 5.0 s, DV_CM_AutoRefresh
        static refresh_intervals := [0, 500, 1000, 5000]
        for i, interval in refresh_intervals
            Menu DvRefresh, % interval=this.refresh_interval ? "Check" : "Uncheck", %i%&
        Menu DvContext, Add, Auto refresh, :DvRefresh
        Menu DvContext, Show, % x, % y
        try Menu DvContext, Delete
        return
        DV_CM_NewWindow:
        DV_CM_InspectNode:
        this[SubStr(A_ThisLabel,7)](node)
        return
        DV_CM_Refresh:
        this.Refresh()
        return
        DV_CM_AutoRefresh:
        this.SetAutoRefresh(refresh_intervals[A_ThisMenuItemPos])
        return
    }
    
    OnDoubleClick(node) {
        if node.base != DvPropertyNode
            this.NewWindow(node)
        else
            this.InspectNode(node)
    }
    
    InspectNode(node) {
        DvInspectProperty(node.dbg, node.xml.getAttribute("fullname"))
    }
    
    NewWindow(node) {
        dv := new this.base(node.Clone())
        dv.Show()
    }
    
    refresh_interval := 0
    SetAutoRefresh(interval) {
        this.refresh_interval := interval
        timer := this.timer
        if !interval {
            if timer {
                SetTimer % timer, Delete
                this.timer := ""
            }
            return 
        }
        if !timer
            this.timer := timer := ObjBindMethod(this, "Refresh")
        SetTimer % timer, % interval
    }
    
    Refresh() {
        this.TLV.root.Update(this.TLV)
        WinSetTitle % "ahk_id " this.hGui,, % this.TLV.root.GetWindowTitle()
    }
}

DvRefreshAll() {
    for hwnd, dv in VarTreeGui.Instances
        dv.Refresh()
}

DvLoadXml(ByRef data) {
    o := ComObjCreate("MSXML2.DOMDocument")
    o.async := false
    o.setProperty("SelectionLanguage", "XPath")
    o.loadXml(data)
    return o
}
