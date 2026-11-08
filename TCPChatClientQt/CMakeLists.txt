cmake_minimum_required(VERSION 3.16)

project(Sonder VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets Multimedia Lottie ShaderTools)

qt_standard_project_setup(REQUIRES 6.10)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

qt_add_executable(Sonder
    main.cpp Sonder.rc
)

qt_policy(SET QTP0004 NEW)
qt_add_qml_module(Sonder
    URI TCPChatClientQt
    QML_FILES
        Main.qml
        components/SendButton.qml
        components/MessageSendArea.qml
        components/ChatInformation.qml
        components/Chat.qml
        components/People.qml
        components/ChatMenu.qml
        components/RegistrationArea.qml
        components/RegistrationButton.qml
        components/Cursor.qml
        components/OverlayScreen.qml
        components/EntryScreen.qml
        components/UpdateScreen.qml
        components/ElementButton.qml
        components/CustomToolTip.qml

    SOURCES chatclient.h chatclient.cpp clipboard.h clipboard.cpp notification.h notification.cpp

    RESOURCES
        assets/SomethingInteresting.json
        assets/SendS.wav
        fonts/Manrope-VariableFont_wght.ttf
        assets/icons/clipboard.svg
        assets/icons/copy.svg
        assets/icons/scan-text.svg
        assets/icons/scissors.svg
        assets/icons/trash.svg
        assets/icons/paperclip.svg
        assets/sonder.ico
)

qt_add_shaders(Sonder "app_shaders"
    PREFIX "/shaders"
    FILES
        assets/DitheringShader.frag
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(Sonder PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.Sonder
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(Sonder
    PRIVATE
        Qt6::Quick
        Qt6::Widgets
        Qt::Lottie
        Qt6::Multimedia
        dwmapi
        SonderBack
)

install(TARGETS Sonder
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)