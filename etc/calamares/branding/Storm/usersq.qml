/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2020 - 2022 Anke Boersma <demm@kaosx.us>
 *   SPDX-FileCopyrightText: 2021 Adriaan de Groot <groot@kde.org>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Window

Kirigami.ScrollablePage {
    // Dark mode colors
    readonly property color pageBackground: "#121212"
    readonly property color unfilledFieldColor: "#1E1E1E"
    readonly property color positiveFieldColor: "#1F3A2F"
    readonly property color negativeFieldColor: "#4A2C32"
    readonly property color unfilledFieldOutlineColor: "#2A2A2A"
    readonly property color positiveFieldOutlineColor: "#3E6F5A"
    readonly property color negativeFieldOutlineColor: "#9B4E5B"
    readonly property color headerTextColor: "#FFFFFF"
    readonly property color commentsColor: "#CFCFCF"

    background: Rectangle {
        color: pageBackground
    }

    width: parent.width
    height: parent.height

    header: Kirigami.Heading {
        Layout.fillWidth: true
        height: 50
        horizontalAlignment: Qt.AlignHCenter
        color: headerTextColor
        font.weight: Font.Medium
        font.pointSize: 12
        text: qsTr("Pick your user name and credentials to login and perform admin tasks")
    }

    ColumnLayout {
        id: _formLayout
        spacing: Kirigami.Units.smallSpacing
        anchors.margins: Kirigami.Units.largeSpacing

        Column {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                width: parent.width
                color: headerTextColor
                text: qsTr("What is your name?")
            }

            TextField {
                id: _userNameField
                width: parent.width
                enabled: config.isEditable("fullName")
                placeholderText: qsTr("Your full name")
                text: config.fullName
                onTextChanged: config.setFullName(text)

                palette.base: _userNameField.text.length
                               ? positiveFieldColor : unfilledFieldColor
                palette.highlight: _userNameField.text.length
                                   ? positiveFieldOutlineColor : unfilledFieldOutlineColor
                color: "#FFFFFF"
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                width: parent.width
                color: headerTextColor
                text: qsTr("What name do you want to use to log in?")
            }

            TextField {
                id: _userLoginField
                width: parent.width
                enabled: config.isEditable("loginName")
                placeholderText: qsTr("Login name")
                text: config.loginName
                validator: RegularExpressionValidator { regularExpression: /[a-z_][a-z0-9_-]*[$]?$/ }

                onTextChanged: acceptableInput
                               ? ( _userLoginField.text === "root"
                                   ? forbiddenMessage.visible = true
                                   : ( config.setLoginName(text),
                                       userMessage.visible = false,
                                       forbiddenMessage.visible = false ) )
                               : ( userMessage.visible = true, console.log("Invalid") )

                palette.base: _userLoginField.text.length
                              ? ( acceptableInput
                                  ? ( _userLoginField.text === "root"
                                      ? negativeFieldColor
                                      : positiveFieldColor )
                                  : negativeFieldColor )
                              : unfilledFieldColor
                palette.highlight: _userLoginField.text.length
                                   ? ( acceptableInput
                                       ? ( _userLoginField.text === "root"
                                           ? negativeFieldOutlineColor
                                           : positiveFieldOutlineColor )
                                       : negativeFieldOutlineColor )
                                   : unfilledFieldOutlineColor
                color: "#FFFFFF"
            }

            Label {
                width: parent.width
                text: qsTr("If more than one person will use this computer, you can create multiple accounts after installation.")
                font.weight: Font.Thin
                font.pointSize: 8
                color: commentsColor
            }
        }

        Kirigami.InlineMessage {
            id: userMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Error
            text: qsTr("Only lowercase letters, numbers, underscore and hyphen are allowed.")
        }

        Kirigami.InlineMessage {
            id: forbiddenMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Error
            text: qsTr("root is not allowed as username.")
        }

        Column {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                width: parent.width
                color: headerTextColor
                text: qsTr("What is the name of this computer?")
            }

            TextField {
                id: _hostName
                width: parent.width
                placeholderText: qsTr("Computer name")
                text: config.hostname
                validator: RegularExpressionValidator { regularExpression: /[a-zA-Z0-9][-a-zA-Z0-9_]+/ }

                onTextChanged: acceptableInput
                               ? ( _hostName.text === "localhost"
                                   ? forbiddenHost.visible = true
                                   : ( config.setHostName(text),
                                       hostMessage.visible = false,
                                       forbiddenHost.visible = false ) )
                               : hostMessage.visible = true

                palette.base: _hostName.text.length
                              ? ( acceptableInput
                                  ? ( _hostName.text === "localhost"
                                      ? negativeFieldColor
                                      : positiveFieldColor )
                                  : negativeFieldColor )
                              : unfilledFieldColor
                palette.highlight: _hostName.text.length
                                   ? ( acceptableInput
                                       ? ( _hostName.text === "localhost"
                                           ? negativeFieldOutlineColor
                                           : positiveFieldOutlineColor )
                                       : negativeFieldOutlineColor )
                                   : unfilledFieldOutlineColor
                color: "#FFFFFF"
            }

            Label {
                width: parent.width
                text: qsTr("This name will be used if you make the computer visible to others on a network.")
                font.weight: Font.Thin
                font.pointSize: 8
                color: commentsColor
            }
        }

        Kirigami.InlineMessage {
            id: hostMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Error
            text: qsTr("Only letters, numbers, underscore and hyphen are allowed, minimal of two characters.")
        }

        Kirigami.InlineMessage {
            id: forbiddenHost
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Error
            text: qsTr("localhost is not allowed as hostname.")
        }

        // Password section
        Column {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                width: parent.width
                color: headerTextColor
                text: qsTr("Choose a password to keep your account safe.")
            }

            Row {
                width: parent.width
                spacing: 20

                TextField {
                    id: _passwordField
                    width: parent.width / 2 - 10
                    placeholderText: qsTr("Password")
                    text: config.userPassword
                    onTextChanged: config.setUserPassword(text)

                    palette.base: _passwordField.text.length
                                   ? positiveFieldColor : unfilledFieldColor
                    palette.highlight: _passwordField.text.length
                                       ? positiveFieldOutlineColor : unfilledFieldOutlineColor

                    echoMode: TextInput.Password
                    passwordMaskDelay: 300
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    color: "#FFFFFF"
                }

                TextField {
                    id: _verificationPasswordField
                    width: parent.width / 2 - 10
                    placeholderText: qsTr("Repeat password")
                    text: config.userPasswordSecondary

                    onTextChanged: _passwordField.text === _verificationPasswordField.text
                                   ? ( config.setUserPasswordSecondary(text),
                                       passMessage.visible = false,
                                       validityMessage.visible = false )
                                   : ( passMessage.visible = true,
                                       validityMessage.visible = false )

                    palette.base: _verificationPasswordField.text.length
                                  ? ( _passwordField.text === _verificationPasswordField.text
                                      ? positiveFieldColor
                                      : negativeFieldColor )
                                  : unfilledFieldColor
                    palette.highlight: _verificationPasswordField.text.length
                                       ? ( _passwordField.text === _verificationPasswordField.text
                                           ? positiveFieldOutlineColor
                                           : negativeFieldOutlineColor )
                                       : unfilledFieldOutlineColor

                    echoMode: TextInput.Password
                    passwordMaskDelay: 300
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    color: "#FFFFFF"
                }
            }

            // Text no longer says "at least eight characters long"
            Label {
                width: parent.width
                text: qsTr("Enter the same password twice so it can be checked for typing errors. You can use a short password here.")
                font.weight: Font.Thin
                font.pointSize: 8
                wrapMode: Text.WordWrap
                color: commentsColor
            }
        }

        Kirigami.InlineMessage {
            id: passMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Error
            text: qsTr("The two passwords do not match.")
        }

        // We make the validity message effectively optional
        Kirigami.InlineMessage {
            id: validityMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Positive
            text: qsTr("Password accepted.")
        }

        CheckBox {
            id: root
            visible: config.writeRootPassword
            text: qsTr("Reuse user password as root password")
            checked: config.reuseUserPasswordForRoot
            onCheckedChanged: config.setReuseUserPasswordForRoot(checked)
            palette.windowText: "#FFFFFF"
        }

        Label {
            visible: root.checked
            width: parent.width
            text: qsTr("Use the same password for the administrator account.")
            font.weight: Font.Thin
            font.pointSize: 8
            color: commentsColor
        }

        Column {
            visible: !root.checked
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                width: parent.width
                color: headerTextColor
                text: qsTr("Choose a root password.")
            }

            Row {
                width: parent.width
                spacing: 20

                TextField {
                    id: _rootPasswordField
                    width: parent.width / 2 - 10
                    placeholderText: qsTr("Root password")
                    text: config.rootPassword

                    onTextChanged: config.setRootPassword(text)

                    palette.base: _rootPasswordField.text.length
                                   ? positiveFieldColor : unfilledFieldColor
                    palette.highlight: _rootPasswordField.text.length
                                       ? positiveFieldOutlineColor : unfilledFieldOutlineColor

                    echoMode: TextInput.Password
                    passwordMaskDelay: 300
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    color: "#FFFFFF"
                }

                TextField {
                    id: _verificationRootPasswordField
                    width: parent.width / 2 - 10
                    placeholderText: qsTr("Repeat root password")
                    text: config.rootPasswordSecondary

                    onTextChanged: _rootPasswordField.text === _verificationRootPasswordField.text
                                   ? ( config.setRootPasswordSecondary(text),
                                       rootPassMessage.visible = false,
                                       rootValidityMessage.visible = false )
                                   : ( rootPassMessage.visible = true,
                                       rootValidityMessage.visible = false )

                    palette.base: _verificationRootPasswordField.text.length
                                  ? ( _rootPasswordField.text === _verificationRootPasswordField.text
                                      ? positiveFieldColor : negativeFieldColor )
                                  : unfilledFieldColor
                    palette.highlight: _verificationRootPasswordField.text.length
                                       ? ( _rootPasswordField.text === _verificationRootPasswordField.text
                                           ? positiveFieldOutlineColor : negativeFieldOutlineColor )
                                       : unfilledFieldOutlineColor

                    echoMode: TextInput.Password
                    passwordMaskDelay: 300
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    color: "#FFFFFF"
                }
            }

            Label {
                visible: !root.checked
                width: parent.width
                text: qsTr("Enter the same password twice so it can be checked for typing errors.")
                font.weight: Font.Thin
                font.pointSize: 8
                color: commentsColor
            }
        }

        Kirigami.InlineMessage {
            id: rootPassMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Error
            text: qsTr("The two root passwords do not match.")
        }

        Kirigami.InlineMessage {
            id: rootValidityMessage
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
            type: Kirigami.MessageType.Positive
            text: qsTr("Root password accepted.")
        }

        CheckBox {
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Log in automatically without asking for the password")
            checked: config.doAutoLogin
            onCheckedChanged: config.setAutoLogin(checked)
            palette.windowText: "#FFFFFF"
        }

        // We keep this checkbox but default to "no strict check"
        CheckBox {
            visible: config.permitWeakPasswords
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Validate passwords quality")
            checked: false
            onCheckedChanged: config.setRequireStrongPasswords(checked)
            palette.windowText: "#FFFFFF"
        }

        Label {
            visible: config.permitWeakPasswords
            width: parent.width
            Layout.alignment: Qt.AlignLeft
            text: qsTr("When this box is checked, stricter password checks will be used.")
            font.weight: Font.Thin
            font.pointSize: 8
            color: commentsColor
        }
    }
}
