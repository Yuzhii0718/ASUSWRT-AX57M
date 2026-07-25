/*
 * bbtype.c - Boot state LED control for MediaTek PWM RGB LED models
 *
 * State mapping:
 *   0 - rescue/flashing mode    -> red LED
 *   1 - normal boot             -> green LED
 *   2 - error state             -> red LED + WAN red LED
 *   3 - GS7_MAGIC init          -> green LED
 */

#include <config.h>
#include <gpio.h>

void bbtype(int type)
{
	switch (type) {
	case 0:	/* rescue/flashing */
		asus_red_led_on();
		break;
	case 1:	/* normal boot */
		asus_green_led_on();
		break;
	case 2:	/* error */
		asus_red_led_on();
		wan_red_led_on();
		break;
	case 3:	/* GS7_MAGIC init */
		asus_green_led_on();
		break;
	default:
		break;
	}
}
