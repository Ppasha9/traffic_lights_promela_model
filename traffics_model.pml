#define NE 0
#define ES 1
#define SW 2
#define NS 3
#define WE 4

#define ROADS_NUM 5

#define green true
#define red false

#define free 0
#define locked 1
#define unLocked 2

byte roadLocks[ROADS_NUM];

bool requests[ROADS_NUM];
bool senses[ROADS_NUM];
bool lights[ROADS_NUM];

/* --------- Traffics --------- */

proctype NE_traffic() {
    do
    :: (requests[NE] == true) ->
        atomic
        {
            (roadLocks[ES] != locked) -> roadLocks[NE] = locked;
        };
        lights[NE] = green;
        (!senses[NE]);
        lights[NE] = red;
        roadLocks[NE] = unLocked;
        requests[NE] = false;
    od
}

proctype ES_traffic() {
    do
    :: (requests[ES] == true) ->
        atomic
        {
            (roadLocks[NE] != locked && roadLocks[SW] != locked && roadLocks[WE] != locked) -> roadLocks[ES] = locked;
        };
        lights[ES] = green;
        (!senses[ES]);
        lights[ES] = red;
        roadLocks[ES] = unLocked;
        requests[ES] = false;
    od
}

proctype SW_traffic() {
    do
    :: (requests[SW] == true) ->
        atomic 
        {
            (roadLocks[WE] != locked && roadLocks[ES] != locked && roadLocks[NS] != locked) -> roadLocks[SW] = locked;
        };
        lights[SW] = green;
        (!senses[SW]);
        lights[SW] = red;
        roadLocks[SW] = unLocked;
        requests[SW] = false;
    od
}

proctype NS_traffic() {
    do
    :: (requests[NS] == true) ->
        atomic 
        {
            (roadLocks[SW] != locked && roadLocks[WE] != locked) -> roadLocks[NS] = locked;
        };
        lights[NS] = green;
        (!senses[NS]);
        lights[NS] = red;
        roadLocks[NS] = unLocked;
        requests[NS] = false;
    od
}

proctype WE_traffic() {
    do
    :: (requests[WE] == true) ->
        atomic 
        {
            (roadLocks[NS] != locked && roadLocks[ES] != locked && roadLocks[SW] != locked) -> roadLocks[WE] = locked;
        };
        lights[WE] = green;
        (!senses[WE]);
        lights[WE] = red;
        roadLocks[WE] = unLocked;
        requests[WE] = false;
    od
}

/* --------- Environments --------- */

proctype NE_environment() {
    do
    :: (lights[NE] == red && !senses[NE]) -> senses[NE] = true;
    :: (!requests[NE] && senses[NE] && roadLocks[NE] != unLocked) -> requests[NE] = true;
    :: (lights[NE] == green && senses[NE]) -> senses[NE] = false;
    od
}

proctype ES_environment() {
    do
    :: (lights[ES] == red && !senses[ES]) -> senses[ES] = true;
    :: (!requests[ES] && senses[ES] && roadLocks[ES] != unLocked) -> requests[ES] = true;
    :: (lights[ES] == green && senses[ES]) -> senses[ES] = false;
    od
}

proctype SW_environment() {
    do
    :: (lights[SW] == red && !senses[SW]) -> senses[SW] = true;
    :: (!requests[SW] && senses[SW] && roadLocks[SW] != unLocked) -> requests[SW] = true;
    :: (lights[SW] == green && senses[SW]) -> senses[SW] = false;
    od
}

proctype NS_environment() {
    do
    :: (lights[NS] == green && senses[NS]) -> senses[NS] = false;
    :: (!requests[NS] && senses[NS] && roadLocks[NS] != unLocked) -> requests[NS] = true;
    :: (lights[NS] == red && !senses[NS]) -> senses[NS] = true;
    od
}

proctype WE_environment() {
    do
    :: (lights[WE] == green && senses[WE]) -> senses[WE] = false;
    :: (!requests[WE] && senses[WE] && roadLocks[WE] != unLocked) -> requests[WE] = true;
    :: (lights[WE] == red && !senses[WE]) -> senses[WE] = true;
    od
}

/* ----------- Controller ----------- */

proctype env_controller() {
    do
    :: (roadLocks[NE] == unLocked && roadLocks[ES] == unLocked && roadLocks[SW] == unLocked && roadLocks[NS] == unLocked && roadLocks[WE] == unLocked) ->
        roadLocks[NE] = free;
        roadLocks[ES] = free;
        roadLocks[SW] = free;
        roadLocks[NS] = free;
        roadLocks[WE] = free;
    od
}

init {
    run NE_traffic();
    run ES_traffic();
    run SW_traffic();
    run NS_traffic();
    run WE_traffic();

    run NE_environment();
    run ES_environment();
    run SW_environment();
    run NS_environment();
    run WE_environment();

    run env_controller();
}
