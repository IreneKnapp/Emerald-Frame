#include "Emerald-Frame.h"
#include <windows.h>
#include <sys/timeb.h>
#include <time.h>


struct timer {
    UINT_PTR id;
    int repeating;
    void (*callback)(EF_Timer timer, void *context);
    void *context;
};


static void CALLBACK timer_callback(HWND window, UINT uMessage, UINT_PTR id, DWORD time);


static size_t n_timers;
static struct timer **all_timers;


EF_Error ef_internal_time_init() {
    n_timers = 0;
    all_timers = NULL;
    return 0;
}


EF_Timer ef_time_new_oneshot_timer(int milliseconds,
				   void (*callback)(EF_Timer timer, void *context),
				   void *context)
{
    UINT_PTR id = SetTimer(NULL, 0, milliseconds, timer_callback);

    struct timer *timer = malloc(sizeof(struct timer));
    timer->id = id;
    timer->repeating = 0;
    timer->callback = callback;
    timer->context = context;
    
    n_timers++;
    all_timers = realloc(all_timers, sizeof(struct timer *) * n_timers);
    
    all_timers[n_timers-1] = timer;
    
    return (EF_Timer) id;
}


EF_Timer ef_time_new_repeating_timer(int milliseconds,
				     void (*callback)(EF_Timer timer, void *context),
				     void *context)
{
    UINT_PTR id = SetTimer(NULL, 0, milliseconds, timer_callback);

    struct timer *timer = malloc(sizeof(struct timer));
    timer->id = id;
    timer->repeating = 1;
    timer->callback = callback;
    timer->context = context;
    
    n_timers++;
    all_timers = realloc(all_timers, sizeof(struct timer *) * n_timers);
    
    all_timers[n_timers-1] = timer;
    
    return (EF_Timer) id;
}


void ef_timer_cancel(EF_Timer timer) {
    UINT_PTR id = (UINT_PTR) timer;
    
    KillTimer(NULL, (UINT_PTR) id);
    
    for(size_t i = 0; i < n_timers; i++) {
	if(all_timers[i]->id == id) {
	    for(size_t j = i; j < n_timers-1; j++)
		all_timers[j] = all_timers[j+1];
	    
	    n_timers--;
	    all_timers = realloc(all_timers,
				 sizeof(struct timer *) * n_timers);
	    
	    break;
	}
    }
}


uint64_t ef_time_unix_epoch() {
    struct timeb time;
    ftime(&time);
    return time.time * 1000 + time.millitm;
}


static void CALLBACK timer_callback(HWND window, UINT uMessage, UINT_PTR id, DWORD time)
{
    struct timer *timer = NULL;
    for(size_t i = 0; i < n_timers; i++) {
	if(all_timers[i]->id == id) {
	    timer = all_timers[i];
	    break;
	}
    }
    
    if(timer) {
	if(timer->callback) {
	    timer->callback((EF_Timer) id, timer->context);
	}
	
	if(!timer->repeating) {
	    ef_timer_cancel((EF_Timer) id);
	}
    }
}
