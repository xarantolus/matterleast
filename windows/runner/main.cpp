#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "app_links/app_links_plugin_c_api.h"
#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // One instance per user session: a second launch hands its link (the
  // browser starts us with an mmauth:// sign-in callback as the only
  // argument) to the running window, shows it, which may be hidden in the
  // tray, and exits. The running app decides whether the link counts.
  ::CreateMutexW(nullptr, TRUE, L"io.github.xarantolus.matterleast");
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND running =
        ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Matterleast");
    // Seen with DebugView; the link itself carries a token, so never it.
    if (running == nullptr) {
      ::OutputDebugStringW(L"Matterleast: no running window for the link\n");
      return EXIT_SUCCESS;
    }
    ::OutputDebugStringW(SendAppLink(running)
                             ? L"Matterleast: link handed to the window\n"
                             : L"Matterleast: the window didn't take the link\n");
    ::ShowWindow(running, ::IsIconic(running) ? SW_RESTORE : SW_SHOW);
    ::SetForegroundWindow(running);
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Matterleast", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
