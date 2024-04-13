//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <libary_componets/libary_componets_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) libary_componets_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "LibaryComponetsPlugin");
  libary_componets_plugin_register_with_registrar(libary_componets_registrar);
}
