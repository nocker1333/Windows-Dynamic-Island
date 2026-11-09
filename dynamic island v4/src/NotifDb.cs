using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public class WpnRow { public long Order; public string AppId; public string Type; public string Payload; }
public static class WpnDb {
    const string L = "winsqlite3.dll";
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_open_v2(byte[] f, out IntPtr db, int flags, IntPtr vfs);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_close(IntPtr db);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_prepare_v2(IntPtr db, byte[] sql, int n, out IntPtr st, IntPtr tail);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_step(IntPtr st);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_finalize(IntPtr st);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_bind_int64(IntPtr st, int i, long v);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern long sqlite3_column_int64(IntPtr st, int i);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern IntPtr sqlite3_column_blob(IntPtr st, int i);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_column_bytes(IntPtr st, int i);
    static byte[] Z(string s) { return Encoding.UTF8.GetBytes(s + "\0"); }
    static string Txt(IntPtr st, int i) {
        IntPtr p = sqlite3_column_blob(st, i);
        int n = sqlite3_column_bytes(st, i);
        if (p == IntPtr.Zero || n <= 0) return null;
        byte[] b = new byte[n];
        Marshal.Copy(p, b, 0, n);
        string s = (n > 1 && b[0] == 0xFF && b[1] == 0xFE) ? Encoding.Unicode.GetString(b) : Encoding.UTF8.GetString(b);
        return s.TrimStart('\uFEFF', '\0');
    }
    static IntPtr Open(string path, int flags, out string err) {
        IntPtr db; err = null;
        int rc = sqlite3_open_v2(Z(path), out db, flags, IntPtr.Zero);
        if (rc != 0) { err = "open rc=" + rc; if (db != IntPtr.Zero) sqlite3_close(db); return IntPtr.Zero; }
        return db;
    }
    public static long MaxOrder(string path, int flags, out string err) {
        IntPtr db = Open(path, flags, out err);
        if (db == IntPtr.Zero) return -1;
        try {
            IntPtr st;
            int rc = sqlite3_prepare_v2(db, Z("SELECT IFNULL(MAX(\"Order\"),0) FROM Notification"), -1, out st, IntPtr.Zero);
            if (rc != 0) { err = "prepare rc=" + rc; return -1; }
            long r = -1;
            if (sqlite3_step(st) == 100) r = sqlite3_column_int64(st, 0);
            sqlite3_finalize(st);
            return r;
        } finally { sqlite3_close(db); }
    }
    public static List<WpnRow> ReadAfter(string path, long after, int flags, out string err) {
        List<WpnRow> list = new List<WpnRow>();
        IntPtr db = Open(path, flags, out err);
        if (db == IntPtr.Zero) return list;
        try {
            IntPtr st;
            string q = "SELECT n.\"Order\", h.PrimaryId, n.Type, n.Payload FROM Notification n LEFT JOIN NotificationHandler h ON n.HandlerId = h.RecordId WHERE n.\"Order\" > ?1 ORDER BY n.\"Order\" LIMIT 50";
            int rc = sqlite3_prepare_v2(db, Z(q), -1, out st, IntPtr.Zero);
            if (rc != 0) { err = "prepare rc=" + rc; return list; }
            sqlite3_bind_int64(st, 1, after);
            while (sqlite3_step(st) == 100) {
                WpnRow r = new WpnRow();
                r.Order = sqlite3_column_int64(st, 0);
                r.AppId = Txt(st, 1);
                r.Type = Txt(st, 2);
                r.Payload = Txt(st, 3);
                list.Add(r);
            }
            sqlite3_finalize(st);
        } finally { sqlite3_close(db); }
        return list;
    }
}
