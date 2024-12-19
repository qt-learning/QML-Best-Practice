pragma Singleton
import QtQuick

QtObject {
    property bool stateProperty: false
    property int value: 0
    property bool enabled: false

    signal updated(value: int)
}
