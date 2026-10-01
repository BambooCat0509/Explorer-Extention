# Windows 11 File Explorer AutoHotkey Extensions (AHK 擴充腳本)

[English](#english) | [繁體中文](#繁體中文)

> 💡 **Quick Start for General Users / 一般使用者快速開始**
> 
> * **English:** If you just want to run the application directly, please download the pre-compiled `.exe` file from the [Releases Page](../../releases).
> * **繁體中文：** 若您只想直接執行程式，請至 [Releases 發行頁面](../../releases) 下載已編譯好的 `.exe` 執行檔。

---

## English

An AutoHotkey script designed to enhance navigation and file management in the native Windows 11 File Explorer.

> **Note:**
>
> * Explicitly supports **Windows 11 Native System** only.
>
> * If running directly from source code, please execute with **AutoHotkey v2** and ensure `UIA.ahk` is located in the same directory.
>
> * This script automatically runs with **Administrator privileges**.

### Prerequisites & Downloads (AHK Official Links)
To run this script, make sure AutoHotkey is installed. You can download it from:
1. [AutoHotkey Official Website](https://www.autohotkey.com/)
2. [Microsoft Store](https://apps.microsoft.com/detail/9plqfdg8hh9d?hl=zh-TW&gl=TW)
3. [AutoHotkey GitHub Repository (Alpha versions)](https://github.com/AutoHotkey/AutoHotkey/tree/alpha)

---

### Features & Shortcuts

#### Keyboard & Mouse Shortcuts

| Shortcut | Description |
| :--- | :--- |
| <kbd>F2</kbd> | Rename the file/folder currently under the mouse cursor. If no icon is hovered, renames the first selected item. |
| <kbd>Middle Click</kbd> | Rename the clicked file or folder. |
| <kbd>Shift</kbd> + <kbd>Middle Click</kbd> | Open the selected folder in a new tab. |
| <kbd>Ctrl</kbd> + <kbd>Middle Click</kbd> | Open the selected folder in a new tab and switch to it immediately. |
| <kbd>Alt</kbd> + <kbd>Middle Click</kbd> | Open the **Properties** dialog for the clicked item. |

#### Navigation Gestures (Empty Area Clicks)

| Action | Description |
| :--- | :--- |
| **Double Left/Right Click** on empty space | Navigate up to the parent directory. |
| **Triple Left/Right Click** on empty space | Go back to the previous page/folder in history. |

---

## 繁體中文

專為 Windows 11 原生檔案總管設計的 AutoHotkey 增強腳本。

> **注意事項：**
>
> * 本拓展僅確保支援 **Windows 11 原生檔案管理系統**。
>
> * 若直接執行原始碼，請使用 **AutoHotkey v2** 版本執行，並將 UIA.ahk 置於相同目錄下。
>
> * 本拓展將**自動以系統管理員身分執行**。

### 前置需求與下載 (AHK 官方載點)
執行本腳本前，請確保已安裝 AutoHotkey，可至以下管道下載：
1. [AutoHotkey 官方網站](https://www.autohotkey.com/)
2. [Microsoft Store 商店頁面](https://apps.microsoft.com/detail/9plqfdg8hh9d?hl=zh-TW&gl=TW)
3. [AutoHotkey GitHub 專案頁面 (Alpha 版本)](https://github.com/AutoHotkey/AutoHotkey/tree/alpha)

---

### 功能與快捷鍵說明

#### 快捷鍵功能列表

| 快捷鍵 | 功能說明 |
| :--- | :--- |
| <kbd>F2</kbd> | 使位於游標懸停處下方的檔案或資料夾進入重新命名模式；若無懸停圖示，則改為已選取的第一個單位。 |
| <kbd>滑鼠中鍵</kbd> | 使被點擊的檔案或資料夾進入重新命名模式。 |
| <kbd>Shift</kbd> + <kbd>滑鼠中鍵</kbd> | 於新索引標籤開啟指定資料夾。 |
| <kbd>Ctrl</kbd> + <kbd>滑鼠中鍵</kbd> | 於新索引標籤開啟指定資料夾，並切換至該索引標籤。 |
| <kbd>Alt</kbd> + <kbd>滑鼠中鍵</kbd> | 開啟點擊項目的詳細內容 (屬性)。 |

#### 空白處手勢功能

| 操作方式 | 功能說明 |
| :--- | :--- |
| **雙擊空白處** (左鍵 / 右鍵) | 返回父目錄 (上一層資料夾)。 |
| **三擊空白處** (左鍵 / 右鍵) | 返回上一頁 (歷史紀錄的上一頁)。 |