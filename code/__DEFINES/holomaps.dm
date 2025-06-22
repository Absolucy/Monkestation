// Constants and standard colors for the holomap

/// Icon file to start with when drawing holomaps (to get a 480x480 canvas).
#define HOLOMAP_ICON 'icons/ui_icons/holomaps/480x480.dmi'
/// Pixel width & height of the holomap icon. Used for auto-centering etc.
#define HOLOMAP_ICON_SIZE 480
#define ui_holomap "CENTER-7,CENTER-7" // Screen location of the holomap "hud"

#define HOLOMAP_EXTRA_STATIONMAP "stationmapformatted"
#define HOLOMAP_EXTRA_STATIONMAPAREAS "stationareas"
#define HOLOMAP_EXTRA_STATIONMAPSMALL "stationmapsmall"

// Holomap colors
#define HOLOMAP_OBSTACLE rgb(255, 255, 255, 221)	// Color of walls and barriers
#define HOLOMAP_SOFT_OBSTACLE rgb(255, 255, 255, 84)	// Color of weak, climbable, or see-through barriers that aren't fulltile windows.
#define HOLOMAP_PATH rgb(102, 102, 102, 153)	// Color of floors
#define HOLOMAP_ROCK rgb(102, 102, 102, 68)	// Color of mineral walls
#define HOLOMAP_HOLOFIER rgb(0, 150, 187, 255)	// Whole map is multiplied by this to give it a green holoish look

#define HOLOMAP_AREACOLOR_SHIELD_1 rgb(0, 119, 255, 64)
#define HOLOMAP_AREACOLOR_SHIELD_2 rgb(0, 255, 255, 64)

#define HOLOMAP_AREACOLOR_COMMAND rgb(52, 52, 212, 153)
#define HOLOMAP_AREACOLOR_SECURITY rgb(174, 18, 18, 153)
#define HOLOMAP_AREACOLOR_MEDICAL rgb(68, 123, 194, 153)
#define HOLOMAP_AREACOLOR_SCIENCE rgb(161, 84, 166, 153)
#define HOLOMAP_AREACOLOR_ENGINEERING rgb(241, 194, 49, 153)
#define HOLOMAP_AREACOLOR_CARGO rgb(224, 111, 0, 153)
#define HOLOMAP_AREACOLOR_HALLWAYS rgb(185, 185, 185, 153)
#define HOLOMAP_AREACOLOR_MAINTENANCE rgb(94, 94, 94, 153)
#define HOLOMAP_AREACOLOR_ARRIVALS rgb(100, 100, 255, 153)
#define HOLOMAP_AREACOLOR_ESCAPE rgb(255, 88, 88, 153)
#define HOLOMAP_AREACOLOR_DORMS rgb(191, 255, 131, 153)
#define HOLOMAP_AREACOLOR_SERVICE rgb(58, 179, 54, 153)
#define HOLOMAP_AREACOLOR_HANGAR rgb(38, 129, 165, 153)
//#define HOLOMAP_AREACOLOR_MUNITION rgb(204, 136, 153, 153)


#define HOLOMAP_LEGEND_X 64
#define HOLOMAP_LEGEND_Y 96

#define HOLOMAP_LEGEND_WIDTH 64

#define HOLOMAP_CENTER_X round((HOLOMAP_ICON_SIZE - world.maxx) / 2)
#define HOLOMAP_CENTER_Y round((HOLOMAP_ICON_SIZE - world.maxy) / 2)
