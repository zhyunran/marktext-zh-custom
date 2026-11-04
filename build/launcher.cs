// MarkText 启动器：平时直接启动 marktext.exe；首次运行打开「教程\新手教学.md」一次。
// 编译（安装版）：csc /target:winexe /optimize+ /win32icon:md.ico launcher.cs
// 编译（便携版）：csc /target:winexe /optimize+ /define:PORTABLE /out:启动 MarkText 便携版.exe launcher.cs
using System;
using System.IO;
using System.Diagnostics;
using System.Windows.Forms;

static class Program
{
    [STAThread]
    static void Main(string[] args)
    {
        string dir = Path.GetDirectoryName(Application.ExecutablePath);
        string exe = Path.Combine(dir, "marktext.exe");
        if (!File.Exists(exe))
        {
            MessageBox.Show("找不到 " + exe + "\r\n安装可能不完整，请重新运行安装程序。",
                "MarkText 启动失败", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }
        try
        {
            string target = args.Length > 0 ? args[0] : FirstRunTutorial(dir);
            string extra = "";
#if PORTABLE
            // 便携版：配置与缓存放在程序目录下的 data\，整个文件夹可以直接拷走
            string dataDir = Path.Combine(dir, "data");
            Directory.CreateDirectory(dataDir);
            extra = "--user-data-dir=\"" + dataDir + "\" ";
#endif
            var psi = new ProcessStartInfo(exe) { WorkingDirectory = dir, UseShellExecute = false };
            psi.Arguments = extra + (target != null ? "\"" + target + "\"" : "");
            Process.Start(psi);
        }
        catch (Exception e)
        {
            MessageBox.Show(e.Message, "启动失败", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    // 首次运行：落标记并返回教程路径；已弹过或教程缺失则返回 null
    static string FirstRunTutorial(string dir)
    {
#if PORTABLE
        string flagDir = Path.Combine(dir, "data");
#else
        string flagDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "MarkTextLauncher");
#endif
        string flag = Path.Combine(flagDir, "tutorial-shown.flag");
        if (File.Exists(flag)) return null;
        Directory.CreateDirectory(flagDir);
        File.WriteAllText(flag, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
        string tutorial = Path.Combine(dir, "教程", "MarkText 新手教学", "新手教学.md");
        return File.Exists(tutorial) ? tutorial : null;
    }
}
