#include "my_application.h"

#include <glib.h>
#include <stdlib.h>

int main(int argc, char** argv) {
#ifdef PROFILE_BUILD
  // Keep the whole VM timeline, appended to any switches already set.
  const char* count = g_getenv("FLUTTER_ENGINE_SWITCHES");
  int next = (count ? atoi(count) : 0) + 1;
  g_autofree gchar* key = g_strdup_printf("FLUTTER_ENGINE_SWITCH_%d", next);
  g_autofree gchar* total = g_strdup_printf("%d", next);
  g_setenv(key, "endless-trace-buffer", TRUE);
  g_setenv("FLUTTER_ENGINE_SWITCHES", total, TRUE);
#endif
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
