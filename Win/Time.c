#include <math.h>
#include "Emerald-Frame.h"


EF_Error ef_internal_time_init() {
    return 0;
}


EF_Timer ef_time_new_oneshot_timer(int milliseconds,
				   void (*callback)(EF_Timer timer, void *context),
				   void *context)
{
    // TODO
}


EF_Timer ef_time_new_repeating_timer(int milliseconds,
				     void (*callback)(EF_Timer timer, void *context),
				     void *context)
{
    // TODO
}


void ef_timer_cancel(EF_Timer timer) {
    // TODO
}


uint64_t ef_time_unix_epoch() {
    // TODO
}
