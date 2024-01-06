/*
  WARNING: client must define local (namespaced) DEBUG_LEVEL
  and TRACE_FLAG macros:
#if defined(PROFILE_fastbuild)
#define DEBUG_LEVEL foo_debug
int  DEBUG_LEVEL;
#define TRACE_FLAG foo_trace
bool TRACE_FLAG;
#endif

This makes fine-grained logging possible; different files can
use different DEBUG_LEVEL flag names in the same build.
 */

#include "liblogc.h"

#if INTERFACE
#define INFOFD stderr
#endif

#define TRACE_ENTRY if (TRACE_FLAG) log_trace(RED "ENTRY:" CRESET " %s", __func__);

#define TRACE_LOG(fmt, ...) if (TRACE_FLAG) log_trace(fmt, __VA_ARGS__)

#define TRACE_EXIT if (TRACE_FLAG) log_trace(RED "EXIT:" CRESET " %s", __func__);

#define TRACE_ENTRY_MSG(fmt, ...) \
    if (TRACE_FLAG) log_trace(RED "ENTRY:" CRESET " %s, " fmt, __func__, __VA_ARGS__);

#define LOG_DEBUG(lvl, fmt, ...) if (DEBUG_LEVEL>lvl) log_debug(fmt, __VA_ARGS__)
#define LOG_ERROR(lvl, fmt, ...) if (DEBUG_LEVEL>lvl) log_error(fmt, __VA_ARGS__)
#define LOG_INFO(lvl, fmt, ...)  if (DEBUG_LEVEL>lvl) log_info(fmt, __VA_ARGS__)
#define LOG_TRACE(lvl, fmt, ...) if (DEBUG_LEVEL>lvl) log_trace(fmt, __VA_ARGS__)
#define LOG_WARN(lvl, fmt, ...)  if (DEBUG_LEVEL>lvl) log_warn(fmt, __VA_ARGS__)
