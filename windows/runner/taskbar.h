#ifndef RUNNER_TASKBAR_H_
#define RUNNER_TASKBAR_H_

#include <windows.h>
#include <shobjidl.h>

// The window's taskbar button: an overlay icon with the unread mention
// count, and a flash that asks for attention.
class Taskbar {
 public:
  explicit Taskbar(HWND window);
  ~Taskbar();

  Taskbar(const Taskbar&) = delete;
  Taskbar& operator=(const Taskbar&) = delete;

  // 0 removes the overlay, 1-9 show that number and 10 shows "9+".
  void SetOverlay(int badge);

  // Flashes the button once; it stays highlighted until the window is
  // activated.
  void Flash();

  // Explorer drops the overlay when it creates the button again, such as
  // when the window shows after hiding in the tray.
  void HandleMessage(UINT message);

 private:
  void Apply();

  HWND window_;
  UINT button_created_;
  ITaskbarList3* list_ = nullptr;
  int badge_ = 0;
};

#endif  // RUNNER_TASKBAR_H_
