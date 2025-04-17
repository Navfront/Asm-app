#pragma once

#include "types.h"

extern "C" void drawVerticalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS pos_opts);
extern "C" void drawHorizontalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS pos_opts);
extern "C" void drawColors(CHAR_INFO* chiBuffer, unsigned short screenWidth);