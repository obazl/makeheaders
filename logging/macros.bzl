LOGGING_MACROS = select({
    "@makeheaders//logging:fastbuild": [
        "@makeheaders//logging:ansi_colors.h",
        "@makeheaders//logging:macros_debug.h"
        ],
    "//conditions:default": [
        "@makeheaders//logging:macros_ndebug.h"
        ]
})
