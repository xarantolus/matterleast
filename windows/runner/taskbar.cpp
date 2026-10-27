#include "taskbar.h"

#include <string>

#include "resource.h"

Taskbar::Taskbar(HWND window)
    : window_(window),
      button_created_(RegisterWindowMessage(L"TaskbarButtonCreated")) {}

Taskbar::~Taskbar() {
  if (list_) {
    list_->Release();
  }
}

void Taskbar::SetOverlay(int badge) {
  badge_ = badge < 0 ? 0 : (badge > 10 ? 10 : badge);
  Apply();
}

void Taskbar::Flash() {
  FLASHWINFO info = {};
  info.cbSize = sizeof(info);
  info.hwnd = window_;
  info.dwFlags = FLASHW_TRAY;
  info.uCount = 1;
  FlashWindowEx(&info);
}

void Taskbar::HandleMessage(UINT message) {
  if (message == button_created_) {
    Apply();
  }
}

void Taskbar::Apply() {
  if (!list_) {
    if (FAILED(CoCreateInstance(CLSID_TaskbarList, nullptr,
                                CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&list_)))) {
      list_ = nullptr;
      return;
    }
    if (FAILED(list_->HrInit())) {
      list_->Release();
      list_ = nullptr;
      return;
    }
  }
  if (badge_ == 0) {
    list_->SetOverlayIcon(window_, nullptr, nullptr);
    return;
  }
  const UINT dpi = GetDpiForWindow(window_);
  const int id = badge_ >= 10 ? IDI_BADGE_MORE : IDI_BADGE_1 + badge_ - 1;
  HICON icon = static_cast<HICON>(LoadImage(
      GetModuleHandle(nullptr), MAKEINTRESOURCE(id), IMAGE_ICON,
      GetSystemMetricsForDpi(SM_CXSMICON, dpi),
      GetSystemMetricsForDpi(SM_CYSMICON, dpi), LR_DEFAULTCOLOR));
  const std::wstring description =
      badge_ >= 10 ? L"More than 9 unread mentions"
      : badge_ == 1
          ? L"1 unread mention"
          : std::to_wstring(badge_) + L" unread mentions";
  list_->SetOverlayIcon(window_, icon, description.c_str());
  // The taskbar keeps its own copy.
  if (icon) {
    DestroyIcon(icon);
  }
}
