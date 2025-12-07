# Install script for directory: /workspaces/Storie/vendor/SDL3-src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/x86_64-w64-mingw32-objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/workspaces/Storie/build-win/vendor/SDL3-build/sdl3.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/workspaces/Storie/build-win/vendor/SDL3-build/libSDL3.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/workspaces/Storie/build-win/vendor/SDL3-build/libSDL3_test.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3headersTargets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3headersTargets.cmake"
         "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3headersTargets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3headersTargets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3headersTargets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3" TYPE FILE FILES "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3headersTargets.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3staticTargets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3staticTargets.cmake"
         "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3staticTargets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3staticTargets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3staticTargets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3" TYPE FILE FILES "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3staticTargets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3" TYPE FILE FILES "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3staticTargets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3testTargets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3testTargets.cmake"
         "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3testTargets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3testTargets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3/SDL3testTargets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3" TYPE FILE FILES "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3testTargets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3" TYPE FILE FILES "/workspaces/Storie/build-win/vendor/SDL3-build/CMakeFiles/Export/35815d1d52a6ea1175d74784b559bdb6/SDL3testTargets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/SDL3" TYPE FILE FILES
    "/workspaces/Storie/build-win/vendor/SDL3-build/SDL3Config.cmake"
    "/workspaces/Storie/build-win/vendor/SDL3-build/SDL3ConfigVersion.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/SDL3" TYPE FILE FILES
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_assert.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_asyncio.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_atomic.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_audio.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_begin_code.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_bits.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_blendmode.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_camera.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_clipboard.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_close_code.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_copying.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_cpuinfo.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_dialog.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_dlopennote.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_egl.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_endian.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_error.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_events.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_filesystem.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_gamepad.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_gpu.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_guid.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_haptic.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_hidapi.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_hints.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_init.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_intrin.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_iostream.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_joystick.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_keyboard.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_keycode.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_loadso.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_locale.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_log.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_main.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_main_impl.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_messagebox.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_metal.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_misc.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_mouse.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_mutex.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_oldnames.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengl.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengl_glext.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengles.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengles2.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengles2_gl2.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengles2_gl2ext.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengles2_gl2platform.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_opengles2_khrplatform.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_pen.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_pixels.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_platform.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_platform_defines.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_power.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_process.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_properties.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_rect.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_render.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_scancode.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_sensor.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_stdinc.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_storage.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_surface.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_system.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_thread.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_time.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_timer.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_touch.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_tray.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_version.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_video.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_vulkan.h"
    "/workspaces/Storie/build-win/vendor/SDL3-build/include-revision/SDL3/SDL_revision.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/SDL3" TYPE FILE FILES
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_assert.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_common.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_compare.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_crc32.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_font.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_fuzzer.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_harness.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_log.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_md5.h"
    "/workspaces/Storie/vendor/SDL3-src/include/SDL3/SDL_test_memory.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/licenses/SDL3" TYPE FILE FILES "/workspaces/Storie/vendor/SDL3-src/LICENSE.txt")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/workspaces/Storie/build-win/vendor/SDL3-build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
