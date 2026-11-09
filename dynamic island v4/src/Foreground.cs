using System;
using System.Runtime.InteropServices;
using System.Text;
public static class Fg {
    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] static extern int GetWindowLong(IntPtr h, int i);
    [DllImport("shell32.dll")] static extern int SHQueryUserNotificationState(out int s);
    [DllImport("user32.dll")] static extern uint GetClipboardSequenceNumber();
    public static uint ClipSeq() { return GetClipboardSequenceNumber(); }
    [DllImport("user32.dll")] static extern short GetAsyncKeyState(int vk);
    public static bool KeyDown(int vk) { return (GetAsyncKeyState(vk) & 0x8000) != 0; }
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
    [DllImport("dwmapi.dll")] static extern int DwmGetWindowAttribute(IntPtr h, int attr, out int v, int size);
    delegate bool EnumProc(IntPtr h, IntPtr l);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
    static string Pack(IntPtr h, string cls, uint pid, RECT r) {
        int caption = GetWindowLong(h, -16) & 0x00C00000;
        return cls + "|" + pid + "|" + r.L + "|" + r.T + "|" + r.R + "|" + r.B + "|" + caption;
    }
    public static string Top() {
        string result = null;
        uint me = (uint)System.Diagnostics.Process.GetCurrentProcess().Id;
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            if (!IsWindowVisible(h) || IsIconic(h)) return true;
            int cloaked; if (DwmGetWindowAttribute(h, 14, out cloaked, 4) == 0 && cloaked != 0) return true;
            uint pid; GetWindowThreadProcessId(h, out pid);
            if (pid == me) return true;
            StringBuilder sb = new StringBuilder(256); GetClassName(h, sb, 256);
            string cls = sb.ToString();
            RECT r; if (!GetWindowRect(h, out r)) return true;
            if (cls == "Progman" || cls == "WorkerW") { result = Pack(h, "Progman", pid, r); return false; }
            if (cls == "Shell_TrayWnd" || cls == "Shell_SecondaryTrayWnd" || cls == "Windows.UI.Core.CoreWindow" ||
                cls == "NotifyIconOverflowWindow" || cls == "XamlExplorerHostIslandWindow" ||
                cls == "TopLevelWindowForOverflowXamlIsland" || cls == "Shell_InputSwitchTopLevelWindow") return true;
            int ex = GetWindowLong(h, -20);
            if ((ex & 0x80) != 0 && (ex & 0x40000) == 0) return true;
            if (r.R - r.L < 50 || r.B - r.T < 30) return true;
            result = Pack(h, cls, pid, r); return false;
        }, IntPtr.Zero);
        return result;
    }
    public static int Qun() { int s; if (SHQueryUserNotificationState(out s) != 0) return 0; return s; }
    public static string Get() {
        IntPtr h = GetForegroundWindow();
        if (h == IntPtr.Zero) return null;
        RECT r; if (!GetWindowRect(h, out r)) return null;
        StringBuilder sb = new StringBuilder(256);
        GetClassName(h, sb, 256);
        uint pid; GetWindowThreadProcessId(h, out pid);
        int caption = GetWindowLong(h, -16) & 0x00C00000;
        return sb.ToString() + "|" + pid + "|" + r.L + "|" + r.T + "|" + r.R + "|" + r.B + "|" + caption;
    }
}
