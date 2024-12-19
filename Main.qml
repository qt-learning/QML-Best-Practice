pragma ComponentBehavior: Bound
pragma ValueTypeBehavior: Addressable
import QtQuick

// Use run-time style selection!
import QtQuick.Controls.Basic

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("QML Best Practice")


    /* ------------------------------------------------------------------------------------------------------
         The following code contains examples and comments relating to the course sections covering:

        - Use Properly Typed Properties
        - Use declarative bindings rather than imperative assignments - but bindings can break!
        - Property evaluation and signal emission order must not be relied on.
        - Use typed list properties
    ------------------------------------------------------------------------------------------------------ */



    // Use Properly Typed Properties
    component CustomType: Control {
        id: customType


        // Use declarative bindings rather than imperative assignments - but bindings can break!
        width: 100
        height: width                           // binding to width
        Component.onCompleted: height = 200     // assignment will break the binding


        // Property evaluation and signal emission order must not be relied on.
        // - the declared order of the handlers does not affect the order of execution.
        onHeightChanged: console.log(`height: ${customType.height}`)
        onWidthChanged: console.log(`width: ${customType.width}`)
    }


    // Use Properly Typed Properties (cont.)
    property var customType1: CustomType {}         // bad
    property CustomType customType2: CustomType {}  // good - explicit type
    property var animal: QtObject {}                // assume some kind of beaked, winged river dwelling animal


    Component.onCompleted: {
        customType1.width = 123     // no autocompletion; "duck typing"
        customType2.width = 123     // auto completion works
        animal.quack()              // if it looks like a duck and quacks like a duck... (but not all animals quack)
    }


    // Use typed list properties
    CustomType { id: customType1 }
    CustomType { id: customType2 }
    CustomType { id: customType3 }
    Rectangle { id: notACustomType }

    // bad list - poorly typed for this case
    property var customTypeList1: [
        customType1,
        customType2,
        customType3,
        notACustomType // and it would still compile
    ]

    // good list - specifies the correct type for the list
    property list<CustomType> customTypeList2: [
        customType1,
        customType2,
        customType3,
        notACustomType // while this ends up being null, the tooling doesn't tell you this is wrong - why? >> See QTBUG-127343
    ]


    /* ------------------------------------------------------------------------------------------------------
         The following code contains examples and comments relating to the course sections covering:

        - Use Required Properties in Components and Delegates
        - Use Object Names
        - Be explicit about your colors!
        - Don't use ids if you don't need them
        - Use String Interpolation (Template Literals)
    ------------------------------------------------------------------------------------------------------ */



    // Use Required Properties in Components and Delegates
    component StricterLabel: Label {
        id: stricterLabel

        // you must provide all the required properties when creating a delegate instance
        required property int index
        required property string name
        required property string age
        required color // example of "upgrading" an existing property to make it required


        // Use ObjectNames (to help debugging, especially in a delegate for access by Squish)
        objectName: `Label ${index}`
        Component.onCompleted: console.log(stricterLabel)


        // Be explicit about your colors!
        property var badColorVar: "red"                                 // string conversion on assignment, var contains a string (use string instead of var to improve performance)
        property var okColorVar: Qt.color("red")                        // string passed as parameter, var contains a color
        property color betterColorVar1: "red"                           // string conversion on assignment, property IS A color
        property color betterColorVar2: "#FF0000"                       // string conversion on assignment, property IS A color
        property color bestColorVar1: Qt.color("red")                   // string passed as parameter, property IS A color
        property color bestColorVar2: Qt.color("#FF0000")               // string passed as a parameter, property IS A color
        property color bestColorVar3: Qt.rgba(1, 0, 0, 1)               // absolute values, property IS A color
        property color colorValueType: { "r": 1, "g": 0.5, "b": 0.25 }  // value type key-property mapping. property IS A color


        // Don't use ids if you don't need them (for styling components which may be overridden)
        background: Rectangle {
            // no id here
            color: Qt.color("white")
        }
    }

    ListModel {
        id: testModel

        ListElement { name: "peter"; age: 42; height: 1.83; color: "cyan" }
        ListElement { name: "alice"; age: 39; height: 1.77; color: "pink" }
    }

    ListView {
        anchors.fill: parent
        model: testModel
        delegate: StricterLabel {

            // StricterLabel comes with its required properties already declared
            // and are automatically populated from the model roles with the same name

            text: `${name} is ${age} years old and is ${height}m tall`

            // Use String Interpolation (Template Literals)

            // longest form, but can easily be used with translations where placeholders can need to be re-ordered.
            // arg() order and placeholder numbers must match
            property string argText: qsTr("name: %1 age: %2 height: %3").arg(name).arg(age).arg(height)

            // if this gets long it can be difficult to read and imagine the what the result looks like
            // (can't be translated in this form)
            property string hardText: "name: " + name + "age: " + age + "height: " + height

            // much more readable and compact (no arg()s)
            // (translation of this form is not properly supported)
            property string easyText: `name: ${name} age: ${age} height: ${height}`

            // literal new lines...
            property string hardNewLine: "this text\nhas inline\nline breaks"
            // ... can be easily seen in a template:
            property string easyNewLine: `this text
has inline
line breaks`

            background: Rectangle {
                // overridden background (c.f. background defined in StricterLabel definition)
                color: Qt.color("black")
            }
        }
    }


    /* ------------------------------------------------------------------------------------------------------
         The following code contains examples and comments relating to the course sections covering:

        - Use explicit URL resolution
        - Delegates should not store State
        - Use Group Property Syntax - including in PropertyChanges in States
        - Deprecated Injected signal parameters
        - Connections function syntax
        - Prefer UI Interaction Signals over Changed Signals
        - Use run-time style selection (see top of QML file)
        - Avoid shadowing properties (see QTBUG-98320)
    ------------------------------------------------------------------------------------------------------ */



    // Use Explicit URL Resolution
    background: Image {

        source: "QML.png"                                       // resolves to this QML file due to Image specific internal code.
        property url anotherSource: "QML.png"                   // doesn't auto resolve
        property url resolvedSource: Qt.resolvedUrl("QML.png")  // correct resolution to this QML file

        fillMode: Image.PreserveAspectFit

        Component.onCompleted: console.log(`anotherSource: ${anotherSource}, resolvedSource: ${resolvedSource}`)
    }



    // Delegates should not store state
    ListView {
        delegate: Button {

            // bad (a local state inside the delegate)
            property bool localStateProperty: false

            onClicked: {

                // bad: this property is only valid for the lifetime of the delegate
                localStateProperty = true

                // good: changes to the external object will remain safe after the delegate is destroyed.
                Backend.stateProperty = true
            }
        }
    }



    // Use Group Property Syntax
    Label {
        id: groupTestLabel

        /* OK: verbose anchors

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        */

        // better: grouped anchors
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        /* OK: verbose font

            font.family: "Titillium Web"
            font.bold: true
            font.pixelSize: 24
        */

        // better: grouped font
        font {
            family: "Titillium Web"
            bold: true
            pixelSize: 24
        }

        states: State {

            /* OK: multiple PropertyChanges for the same target.
               If qmlls is enabled, it warns about doing this - and even tells you how to change it!

                PropertyChanges {
                    target: groupTestLabel
                    color: Qt.color("blue")
                }
                PropertyChanges {
                    target: groupTestLabel
                    text: qsTr("some new text")
                }
            */

            // better: collapse target properties into one PropertyChanges!
            PropertyChanges {
                groupTestLabel {
                    color: "blue"
                    text: qsTr("some new text")
                }
            }
        }
    }



    // Deprecated Injected signal parameters
    MouseArea {

        // bad: use of unqualified signal (that just happens to be available still)
        // (mouse in this case is of type MouseEvent)
        // - the signal parameter "mouse" here would not be known as distinct from the id "mouse" should it be the same.
        onClicked: console.log(mouse.x, mouse.y)

        // better: capture the signal and use an anonymous function operator (=>)
        // (no type annotation is necessary)
        // - the captured parameter "mouse" is known as distinct from the id "mouse" should it be the same.
        onDoubleClicked: (mouse) => { console.log(mouse.x, mouse.y) } // braces optional in this case

        // best: don't use the signal
        onPressed: console.log(mouseX, mouseY)
    }



    // Use new Connection Syntax
    Connections {
        target: Backend
        // bad: onUpdated is not actually a signal of Connections!
        // Nor is "value" known on the updated signal here.
        onUpdated: console.log("updated", value)

        // good: provide a function with the same name as the signal handler
        // (note this won't work if you have any old syntax present)
        function onUpdated(value: int) { console.log("updated", value) }
    }



    // Prefer UI Interaction Signals over Changed Signals
    Slider {
        value: Backend.value

        // bad: this handler is called when the user interacts with the slider AND
        // also when the Backend.value changes which can lead to binding loops
        onValueChanged: Backend.value = value

        // good: this interaction handler is called ONLY when the user interacts with the slider but
        // NOT when the Backend value changes avoid binding loops
        onMoved: Backend.value = value
    }

    CheckBox {
        // similarly to Slider, use onClicked rather than onCheckedChanged to avoid the same issue
        checked: Backend.enabled

        onCheckedChanged: Backend.enabled = checked // bad (as described in Slider onValueChanged above)
        onClicked: Backend.enabled = checked        // good
    }



    // Avoid shadowing properties
    Rectangle {

        // this property shadows the Rectangle's own radius property (and has different type)
        property string radius: "not qreal"

        Item {
            // we don't know what type parent is so we're really guessing it has a radius property;
            // do we want the string one or the qreal one?
            property string r: parent.radius
        }
    }

    Rectangle {
        id: myRect // this id is unique and unchangeable in this scope

        property string radius: "not qreal"     // this property still shadows the Rectangle's own radius property but its use is assured.

        Item {
            property string r: myRect.radius    // compiler knows exactly which object to get radius from and that it is the string one.
        }
    }




    /* ------------------------------------------------------------------------------------------------------
         The following code contains examples and comments relating to the course sections covering
         "Unqualified Access Best Practices".

        - Avoid implicit lookup in the root scope
        - Avoid referencing objects outside the component
        - Avoid using parent for property qualification
    ------------------------------------------------------------------------------------------------------ */



    // Avoid implicit lookups within in the root scope
    property int offset: 10 // a root context property

    Item {
        // bad qualification (qmlls warns about this)
        x: offset

        /*
            The code doesn't tell us where we should assume the x: binding gets its offset target from.
            If Item were to ever gain an offset property of its own (version-less imports would allow this),
            then this code would silently misbehave as the offset would be resolved to its own (new) offset property,
            not the one in the root scope. Additionally, any context properties injected into this scope (e.g. if it were a delegate)
            would shadow this property.
        */
    }

    Item {
        // good qualification
        x: window.offset

        /*
            The solution ensures that the binding is completely explicit and is immune from its own object gaining an offset property and any context property injection.
            The binding resolution is also much faster for being explicit.
            An additional advantage is that it is also immune from the structure of the QML changing because the id remains the same.
        */
    }



    // Avoid referencing objects outside the component where possible
    component BadButton : Button {
        /* bad:
            such a component reaches outside of itself to call a function on some object it assumes to exist
            and that the object is a Window type having a close() function
        */
        onClicked: window.close()
    }
    BadButton { }

    component GoodButton : Button { }
    GoodButton {
        /* good:
            this is an instance of a component and has access to the window object in its creation context.
            The clicked signal is handled outside of the component rather than from inside which is much safer.
        */
        onClicked: window.close()
    }

    // example of a delegate component accessing an external object by id (requires pragma ComponentBehavior: Bound)
    ListView {
        delegate: Button {
            // accessing window by id is allowed only if pragma ComponentBehavior: Bound is used
            onClicked: window.close()
        }
    }



    // Avoid using parent for property qualification
    Item {
        id: parentItem

        /*
            using parent for anchors here within the ApplicationWindow is perfectly fine,
            but avoid doing this on the root element preferring to only do this on the element instance
            so that the anchoring parent is always known within the QML file scope. Better would be to explicitly refer
            to the anchoring target by its id!
        */
        anchors.fill: parent

        property int value

        Text {
            // bad: reparenting this Text to another item would break this binding
            text: parent.value
        }
        Text {
            // good: using qualified binding will ensure this Text will still work regardless of being reparented
            text: parentItem.value
        }
    }


    /* ------------------------------------------------------------------------------------------------------
         The following code contains examples and comments relating to the course sections covering
         "QML and JavaScript".

        - Use type annotations on functions
        - Use "let" instead of "var" inside JavaScript blocks
        - Use Nullish Coalescing '??' and Optional Chaining '?.' operators
    ------------------------------------------------------------------------------------------------------ */



    // Use type annotations on functions
    Item {
        // bad: what is this function actually doing?
        function add(a, b) {
            console.log(`adding ${a} + ${b}`)
            return a + b
        }
        property int intResult: add(10, 20) // 30
        property string stringResult: add("3", "0") // "30"

        Component.onCompleted: console.log(`intResult: ${intResult}, stringResult: ${stringResult}`)
    }

    Item {
        // good: explicit type annotation on arguments and return types
        // (Note: since function overloading isn't supported in JavaScript we must give the functions unique names)
        function add(a: int, b: int): int {
            console.log(`adding integers ${a} + ${b}`)
            return a + b
        }
        function addString(a: string, b: string): string {
            console.log(`adding strings ${a} + ${b}`)
            return a + b
        }
        property int intResult: add(10, 20) // 30
        property string stringResult: addString("3", "0") // "30"

        Component.onCompleted: console.log(`intResult: ${intResult}, stringResult: ${stringResult}`)
    }



    // Use "let" instead of "var" inside JavaScript blocks
    Item {

        function varFunction() {

            console.log(`varFunction index: ${index} internal: ${internal}`) // >> varFunction index: undefined internal: undefined

            for(var index = 0; index < 10; index++) {

                var internal = 99

                console.log("counting", index)

            }
            // bad: index and internal are actually available to the entire function!
            console.log(`varFunction index: ${index} internal: ${internal}`) // >> varFunction index: 10 internal: 99
        }

        function letFunction() {

            console.log(`letFunction index: ${index} internal: ${internal}`) // >> ReferenceError: index is not defined

            for(let index = 0; index < 10; index++) {

                let internal = 99

                // good: index is only valid inside this block
                console.log("counting", index)

            }
            // good: index and internal are not defined outside the for block which is correctly detected as an unqualified access
            console.log(`letFunction index: ${index} internal: ${internal}`) // >> letFunction index: undefined internal: undefined
        }

        Component.onCompleted: {
            varFunction()
            letFunction()
        }
    }



    // Use Nullish Coalescing '??' and Optional Chaining '?.' operators
    component Owner: QtObject {
        property var yearsOwned: 0 // note the var type
    }
    component Home: QtObject {
        property Owner owner: Owner {}
    }
    property Home home: null // Home { }

    Text {
        /* bad: verbose evaluation:

          - checks if home is valid and then home.owner is valid (uses '?' ternary operator)
          - yearsOwned might be undefined so it may erroneously show "New House" rather than 0
          - duplication of "else" clauses required in this expression.
        */
        text: window.home && window.home.owner ? (window.home.owner.yearsOwned || qsTr("New House")) : qsTr("New House")
    }

    Text {
        /* good: compact evaluation:

            If the home or subsequently owner is nullish, the rest of the left hand side is ignored and
            the chain jumps to the end and returns undefined which is then evaluated against the ?? as "nullish" resulting in "New House".
            Also, if yearsOwned is undefined then the result is also "New House" removing the duplication.
            Obviously this is much shorter!
        */
        text: window.home?.owner?.yearsOwned ?? qsTr("New House")
    }
}
