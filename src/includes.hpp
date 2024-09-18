#pragma once

#include <algorithm>
#include <queue>
#include <mutex>

#include <Geode/Geode.hpp>

using namespace geode::prelude;

enum GameAction : int {
	p1Jump = 0,
	p1Left = 1,
	p1Right = 2,
	p2Jump = 3,
	p2Left = 4,
	p2Right = 5
};

enum Player : bool {
	Player1 = 0,
	Player2 = 1
};

enum State : bool {
	Press = 0,
	Release = 1
};

#ifdef GEODE_IS_WINDOWS
struct __attribute__((packed)) LinuxInputEvent {
	LARGE_INTEGER time;
	USHORT type;
	USHORT code;
	int value;
};

extern HANDLE hSharedMem;
extern HANDLE hMutex;
extern LPVOID pBuf;
constexpr size_t BUFFER_SIZE = 20;
extern bool isLinux;

#endif

struct InputEvent {
#ifdef GEODE_IS_MACOS
	uint64_t time;
#elif defined (GEODE_IS_WINDOWS)
	LARGE_INTEGER time;
#endif
	PlayerButton inputType;
	bool inputState;
	bool isPlayer1;
};

struct Step {
	InputEvent input;
	double deltaFactor;
	bool endStep;
};

extern std::queue<struct InputEvent> inputQueue;

extern std::array<std::unordered_set<size_t>, 6> inputBinds;
extern std::unordered_set<uint16_t> heldInputs;

extern std::mutex inputQueueLock;
extern std::mutex keybindsLock;

extern std::atomic<bool> enableRightClick;
extern bool threadPriority;

extern bool softToggle;

#ifdef GEODE_IS_WINDOWS
void linuxCheckInputs();
void inputThread();
#endif