#include <windows.h>
#include <stdio.h>

struct POSITION_OPTS {
    unsigned short X;
    unsigned short Y;
    unsigned short ScreenWidth;
    unsigned short Length;
};

extern "C" void drawVerticalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS pos_opts);
extern "C" void drawHorizontalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS pos_opts);
extern "C" void drawColors(CHAR_INFO* chiBuffer, unsigned short screenWidth);

int main(void)
{
    HANDLE hStdout, hNewScreenBuffer;
    SMALL_RECT srctWriteRect;
    CHAR_INFO* chiBuffer;
    COORD coordBufSize;
    COORD coordBufCoord = { 0, 0 };
    BOOL fSuccess;
    CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;

    // Получаем хэндл текущего буфера
    hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStdout == INVALID_HANDLE_VALUE)
    {
        printf("GetStdHandle failed - (%d)\n", GetLastError());
        return 1;
    }

    // Получаем информацию о текущем буфере (включая размеры окна)
    if (!GetConsoleScreenBufferInfo(hStdout, &screenBufferInfo))
    {
        printf("GetConsoleScreenBufferInfo failed - (%d)\n", GetLastError());
        return 1;
    }

    // Создаем новый буфер
    hNewScreenBuffer = CreateConsoleScreenBuffer(
        GENERIC_READ | GENERIC_WRITE,
        FILE_SHARE_READ | FILE_SHARE_WRITE,
        NULL,
        CONSOLE_TEXTMODE_BUFFER,
        NULL);

    if (hNewScreenBuffer == INVALID_HANDLE_VALUE)
    {
        printf("CreateConsoleScreenBuffer failed - (%d)\n", GetLastError());
        return 1;
    }

    // Делаем новый буфер активным
    if (!SetConsoleActiveScreenBuffer(hNewScreenBuffer))
    {
        printf("SetConsoleActiveScreenBuffer failed - (%d)\n", GetLastError());
        return 1;
    }

    // Размер видимой области консоли (не всего буфера!)
    int visibleWidth = screenBufferInfo.srWindow.Right - screenBufferInfo.srWindow.Left + 1;
    int visibleHeight = screenBufferInfo.srWindow.Bottom - screenBufferInfo.srWindow.Top + 1;

    // Выделяем буфер под видимую область
    chiBuffer = new CHAR_INFO[visibleWidth * visibleHeight];

    // Заполняем буфер символами 'W'
    for (int i = 0; i < visibleWidth * visibleHeight; i++)
    {
        chiBuffer[i].Char.UnicodeChar = L'W';
        chiBuffer[i].Attributes = FOREGROUND_GREEN | FOREGROUND_INTENSITY;
    }

    CHAR_INFO s{};
    s.Attributes = FOREGROUND_RED | FOREGROUND_INTENSITY;
    s.Char.UnicodeChar = L'X';

    POSITION_OPTS p{};
    p.X = 20;
    p.Y = 10;
    //p.ScreenWidth = screenBufferInfo.dwSize.X;
    p.ScreenWidth = visibleWidth;
    p.Length = 10;

    drawHorizontalLine(chiBuffer, s, p);
    drawVerticalLine(chiBuffer, s, p);
    drawColors(chiBuffer, visibleWidth);

    // Устанавливаем прямоугольник для вывода (только видимая часть)
    srctWriteRect.Top = 0;
    srctWriteRect.Left = 0;
    srctWriteRect.Bottom = visibleHeight - 1;  // Ограничиваем высоту
    srctWriteRect.Right = visibleWidth - 1;   // Ограничиваем ширину

    // Размер буфера для передачи в WriteConsoleOutput
    coordBufSize.X = visibleWidth;
    coordBufSize.Y = visibleHeight;

    // Выводим содержимое буфера на экран
    fSuccess = WriteConsoleOutput(
        hNewScreenBuffer,
        chiBuffer,
        coordBufSize,
        coordBufCoord,
        &srctWriteRect);

    if (!fSuccess)
    {
        printf("WriteConsoleOutput failed - (%d)\n", GetLastError());
        return 1;
    }

    Sleep(50000);

    // Восстанавливаем оригинальный буфер
    SetConsoleActiveScreenBuffer(hStdout);

    // Освобождаем память
    delete[] chiBuffer;
    CloseHandle(hNewScreenBuffer);

    return 0;
}