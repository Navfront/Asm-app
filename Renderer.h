#pragma once
#include "Windows.h"
#include "assembly_code.h"

class Renderer
{
protected:
    HANDLE hStdout, hNewScreenBuffer;
    SMALL_RECT srctWriteRect;
    CHAR_INFO* chiBuffer;
    COORD coordBufSize;
    COORD coordBufCoord = { 0, 0 };
    BOOL fSuccess;
    CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
    int visibleWidth = 0;
    int visibleHeight = 0;

public:
    Renderer() {
        // �������� ����� �������� ������
        this->hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
        if (hStdout == INVALID_HANDLE_VALUE)
        {
            printf("GetStdHandle failed - (%d)\n", GetLastError());
            return;
        }

        // �������� ���������� � ������� ������ (������� ������� ����)
        if (!GetConsoleScreenBufferInfo(this->hStdout, &this->screenBufferInfo))
        {
            printf("GetConsoleScreenBufferInfo failed - (%d)\n", GetLastError());
            return;
        }

        // ������� ����� �����
        this->hNewScreenBuffer = CreateConsoleScreenBuffer(
            GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE,
            NULL,
            CONSOLE_TEXTMODE_BUFFER,
            NULL);

        if (this->hNewScreenBuffer == INVALID_HANDLE_VALUE)
        {
            printf("CreateConsoleScreenBuffer failed - (%d)\n", GetLastError());
            return;
        }

        // ������ ����� ����� ��������
        if (!SetConsoleActiveScreenBuffer(this->hNewScreenBuffer))
        {
            printf("SetConsoleActiveScreenBuffer failed - (%d)\n", GetLastError());
            return;
        }

        // ������ ������� ������� ������� (�� ����� ������!)
        visibleWidth = this->screenBufferInfo.srWindow.Right - this->screenBufferInfo.srWindow.Left + 1;
        visibleHeight = this->screenBufferInfo.srWindow.Bottom - this->screenBufferInfo.srWindow.Top + 1;

        // �������� ����� ��� ������� �������
        this->chiBuffer = new CHAR_INFO[visibleWidth * visibleHeight];
    }



    ~Renderer() {
        // ����������� ������
        delete[] this->chiBuffer;
        CloseHandle(this->hNewScreenBuffer);
    }

    void draw() {

        // ��������� ����� ��������� 'W'
        for (int i = 0; i < visibleWidth * visibleHeight; i++)
        {
            this->chiBuffer[i].Char.UnicodeChar = L'W';
            this->chiBuffer[i].Attributes = FOREGROUND_GREEN | FOREGROUND_INTENSITY;
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

        // ������������� ������������� ��� ������ (������ ������� �����)
        this->srctWriteRect.Top = 0;
        this->srctWriteRect.Left = 0;
        this->srctWriteRect.Bottom = visibleHeight - 1;  // ������������ ������
        this->srctWriteRect.Right = visibleWidth - 1;   // ������������ ������

        // ������ ������ ��� �������� � WriteConsoleOutput
        this->coordBufSize.X = visibleWidth;
        this->coordBufSize.Y = visibleHeight;

        // ������� ���������� ������ �� �����
        fSuccess = WriteConsoleOutput(
            this->hNewScreenBuffer,
            this->chiBuffer,
            this->coordBufSize,
            this->coordBufCoord,
            &this->srctWriteRect);

        if (!fSuccess)
        {
            printf("WriteConsoleOutput failed - (%d)\n", GetLastError());
            return;
        }

        SetConsoleTitle(L"Press ESC to exit");
        while (!(GetAsyncKeyState(VK_ESCAPE) & 0x8000)) {
            Sleep(100);
        }
        this->exit();
    }

    void exit() {
        // ��������������� ������������ �����
        SetConsoleActiveScreenBuffer(this->hStdout);
    }
};

