cmake_minimum_required(VERSION 3.16)

project(QMLBestPractice
    VERSION 0.1
    LANGUAGES CXX
    DESCRIPTION "QML Best Practice"
)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick LinguistTools)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appQMLBestPractice
    main.cpp
)

set(QML_SINGLETON_FILES
    # Add QML Singleton Files here
    Backend.qml
)

set_source_files_properties(
    ${QML_SINGLETON_FILES}
    PROPERTIES
        QT_QML_SINGLETON_TYPE true
)

qt_add_qml_module(appQMLBestPractice
    URI QMLBestPractice
    VERSION 1.0

    QML_FILES
        ${QML_SINGLETON_FILES}
        Main.qml
    RESOURCES
        # using BIG_RESOURCES
)

qt_add_resources(appQMLBestPractice "appQMLBestPractice_large_resources"
    # add generated BIG_RESOURCES files to the QML Module target
    PREFIX /qt/qml/QMLBestPractice
    BIG_RESOURCES
    FILES
        QML.png
)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.6)
    set_target_properties(appQMLBestPractice PROPERTIES
        QT_QMLCACHEGEN_ARGUMENTS "--verbose"
    )
endif()

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appQMLBestPractice PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQMLBestPractice
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQMLBestPractice
    PRIVATE
        Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appQMLBestPractice
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)