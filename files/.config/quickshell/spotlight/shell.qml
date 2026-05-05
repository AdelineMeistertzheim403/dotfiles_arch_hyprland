import QtQuick
import Quickshell

ShellRoot {
    id: root
    property bool open: false

    IpcHandler {
        target: "launcher"

        function toggle() {
            root.open = !root.open
        }

        function show() {
            root.open = true
        }

        function hide() {
            root.open = false
        }
    }

    PanelWindow {
        visible: root.open
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.35
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }
    }
}
