#include "includes.hpp"

#if defined(GEODE_IS_MACOS)
#define CommentType CommentTypeDummy
#include <mach/mach_time.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <AppKit/AppKit.h>
#undef CommentType
#endif

std::queue<struct InputEvent> inputQueue;

std::array<std::unordered_set<size_t>, 6> inputBinds;
std::unordered_set<uint16_t> heldInputs;

std::mutex inputQueueLock;
std::mutex keybindsLock;

std::atomic<bool> enableRightClick;
bool threadPriority;

static IMP s_originalSendEventIMP;

int convertKeyCodes(int code)
{

    if (code == 1)
        return 83;
    else if (code == 2)
        return 68;
    else if (code == 3)
        return 70;
    else if (code == 4)
        return 72;
    else if (code == 5)
        return 71;
    else if (code == 6)
        return 90;
    else if (code == 7)
        return 88;
    else if (code == 8)
        return 67;
    else if (code == 9)
        return 86;
    else if (code == 11)
        return 66;
    else if (code == 12)
        return 81;
    else if (code == 13)
        return 87;
    else if (code == 14)
        return 69;
    else if (code == 15)
        return 82;
    else if (code == 16)
        return 89;
    else if (code == 17)
        return 84;
    else if (code == 18)
        return 49;
    else if (code == 19)
        return 50;
    else if (code == 20)
        return 51;
    else if (code == 21)
        return 52;
    else if (code == 22)
        return 54;
    else if (code == 23)
        return 53;
    else if (code == 25)
        return 57;
    else if (code == 26)
        return 55;
    else if (code == 28)
        return 56;
    else if (code == 29)
        return 48;
    else if (code == 31)
        return 79;
    else if (code == 32)
        return 85;
    else if (code == 34)
        return 73;
    else if (code == 35)
        return 80;
    else if (code == 36)
        return 13;
    else if (code == 37)
        return 76;
    else if (code == 38)
        return 74;
    else if (code == 40)
        return 75;
    else if (code == 43)
        return 188;
    else if (code == 44)
        return 191;
    else if (code == 45)
        return 78;
    else if (code == 46)
        return 77;
    else if (code == 47)
        return 190;
    else if (code == 48)
        return 9;
    else if (code == 49)
        return 32;
    else if (code == 51)
        return 46;
    else if (code == 53)
        return 27;
    else if (code == 56)
        return 10;
    else if (code == 57)
        return 20;
    else if (code == 58)
        return 18;
    else if (code == 59)
        return 11;
    else if (code == 65)
        return 110;
    else if (code == 67)
        return 106;
    else if (code == 69)
        return 107;
    else if (code == 75)
        return 111;
    else if (code == 78)
        return 109;
    else if (code == 82)
        return 96;
    else if (code == 83)
        return 97;
    else if (code == 84)
        return 98;
    else if (code == 85)
        return 99;
    else if (code == 86)
        return 100;
    else if (code == 87)
        return 101;
    else if (code == 88)
        return 102;
    else if (code == 89)
        return 103;
    else if (code == 91)
        return 104;
    else if (code == 92)
        return 105;
    else if (code == 96)
        return 116;
    else if (code == 97)
        return 117;
    else if (code == 98)
        return 118;
    else if (code == 99)
        return 114;
    else if (code == 100)
        return 119;
    else if (code == 101)
        return 120;
    else if (code == 103)
        return 122;
    else if (code == 109)
        return 121;
    else if (code == 110)
        return 93;
    else if (code == 111)
        return 123;
    else if (code == 114)
        return 47;
    else if (code == 115)
        return 36;
    else if (code == 116)
        return 33;
    else if (code == 117)
        return 8;
    else if (code == 118)
        return 115;
    else if (code == 119)
        return 35;
    else if (code == 120)
        return 113;
    else if (code == 121)
        return 34;
    else if (code == 122)
        return 112;
    else if (code == 123)
        return 37;
    else if (code == 124)
        return 39;
    else if (code == 125)
        return 40;
    else if (code == 126)
        return 283;
    else
        return 0;
}

void sendEvent(NSApplication *self, SEL sel, NSEvent *event)
{
    NSEventType type;
    PlayerButton inputType;
    bool inputState;
    bool player;
    uint64_t time;
    std::array<std::unordered_set<size_t>, 6> binds;
    std::lock_guard lock(keybindsLock);
    std::lock_guard lock2(inputQueueLock);
    binds = inputBinds;
    bool shouldEmplace = true;
    int windows;

    if (PlayLayer::get() || LevelEditorLayer::get()) {
        type = [event type];
        if (type == NSEventTypeKeyDown) {
            switch (type) {
                case NSEventTypeKeyDown:
                    [[[self mainWindow] firstResponder] tryToPerform:@selector(keyDown:) with:event];

                    inputState = State::Press;
                    player     = Player1;
                    time       = mach_absolute_time();
                    windows = convertKeyCodes([event keyCode]);

                    if (heldInputs.contains(windows)) {
				        if (!inputState) return;
				        else heldInputs.erase(windows);
			        }

                    if (binds[p1Jump].contains(windows))
                        inputType = PlayerButton::Jump;
                    else if (binds[p1Left].contains(windows))
                        inputType = PlayerButton::Left;
                    else if (binds[p1Right].contains(windows))
                        inputType = PlayerButton::Right;
                    else {
                        player = Player2;
                        if (binds[p2Jump].contains(windows))
                            inputType = PlayerButton::Jump;
                        else if (binds[p2Left].contains(windows))
                            inputType = PlayerButton::Left;
                        else if (binds[p2Right].contains(windows))
                            inputType = PlayerButton::Right;
                    }

                    if (!inputState) heldInputs.emplace(windows);
                    if (!shouldEmplace) return;
                    inputQueue.emplace(InputEvent{ time, inputType, inputState, player });

                    return;
                default: break;
            }
        }

        if (type == NSEventTypeKeyUp) {
            switch (type) {
                case NSEventTypeKeyUp:
                    [[[self mainWindow] firstResponder] tryToPerform:@selector(keyUp:) with:event];

                    inputState = State::Release;
                    player     = Player1;
                    time       = mach_absolute_time();
                    windows = convertKeyCodes([event keyCode]);

                    if (heldInputs.contains(windows)) {
				        if (!inputState) return;
				        else heldInputs.erase(windows);
			        }

                    if (binds[p1Jump].contains(windows))
                        inputType = PlayerButton::Jump;
                    else if (binds[p1Left].contains(windows))
                        inputType = PlayerButton::Left;
                    else if (binds[p1Right].contains(windows))
                        inputType = PlayerButton::Right;
                    else {
                        player = Player2;
                        if (binds[p2Jump].contains(windows))
                            inputType = PlayerButton::Jump;
                        else if (binds[p2Left].contains(windows))
                            inputType = PlayerButton::Left;
                        else if (binds[p2Right].contains(windows))
                            inputType = PlayerButton::Right;
                    }
 
                    if (!inputState) heldInputs.emplace(windows);
                    if (!shouldEmplace) return;
                    inputQueue.emplace(InputEvent{ time, inputType, inputState, player });

                    return;
                default: break;
            }
        }

        if (type == NSEventTypeLeftMouseDown) {
            switch (type) {
                case NSEventTypeLeftMouseDown:
                    [[[self mainWindow] firstResponder] tryToPerform:@selector(mouseDown:) with:event];
                    time       = mach_absolute_time();
                    
                    inputQueue.emplace(InputEvent{ time, PlayerButton::Jump, State::Press, Player1 });

                    return;
                default: break;
            }
        }

        if (type == NSEventTypeLeftMouseUp) {
            switch (type) {
                case NSEventTypeLeftMouseDown:
                    [[[self mainWindow] firstResponder] tryToPerform:@selector(mouseUp:) with:event];
                    time       = mach_absolute_time();

                    inputQueue.emplace(InputEvent{ time, PlayerButton::Jump, State::Release, Player1 });

                    return;
                default: break;
            }
        }

        if (type == NSEventTypeRightMouseDown) {
            switch (type) {
                case NSEventTypeRightMouseDown:
                    [[[self mainWindow] firstResponder] tryToPerform:@selector(rightMouseDown:) with:event];
                    time       = mach_absolute_time() ;

                    if (!enableRightClick.load())
                        inputQueue.emplace(InputEvent{ time, PlayerButton::Jump, State::Press, Player2 });

                    return;
                default: break;
            }
        }

        if (type == NSEventTypeRightMouseUp) {
            switch (type) {
                case NSEventTypeRightMouseUp:
                    [[[self mainWindow] firstResponder] tryToPerform:@selector(rightMouseUp:) with:event];
                    time       = mach_absolute_time();

                    if (!enableRightClick.load())
                        inputQueue.emplace(InputEvent{ time, PlayerButton::Jump, State::Release, Player2 });

                    return;
                default: break;
            }
        }
    }

    ((decltype(&sendEvent))s_originalSendEventIMP)(self, sel, event);
}

$execute
{
    auto method = class_getInstanceMethod(objc_getClass("NSApplication"), @selector(sendEvent:));
    s_originalSendEventIMP = method_getImplementation(method);
    method_setImplementation(method, (IMP)&sendEvent);
}