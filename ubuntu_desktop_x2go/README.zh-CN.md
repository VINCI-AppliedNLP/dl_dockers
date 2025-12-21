GNOME + X2Go Docker 镜像（试验性）

目的
- 提供一个起点的 `Dockerfile`，用于在容器中通过 X2Go（基于 NX over SSH）运行 GNOME 桌面。
- 下文说明了 caveats（注意事项）以及如何在启用 systemd/logind 的情况下运行容器。

注意 / 重要提示
- GNOME 期望有 systemd/logind 并默认运行在 Wayland 上，而 X2Go 使用的是 X11。
  - 我们通过在 `/etc/gdm3/custom.conf` 中禁用 Wayland 并使用 `XDG_SESSION_TYPE=x11` 来强制 GNOME 使用 Xorg（X11）。
- 要可靠运行 GNOME，通常必须在容器内以 PID 1 运行 systemd，并提供 cgroup 挂载和额外权限。
  - 这会增加复杂性并降低容器的可移植性与安全性。
- 如果您只是需要一个远程桌面，`xfce4` 或 `mate` 在容器中更可靠，推荐用于生产或常用场景。

构建

```bash
docker build -t gnome-x2go:latest ./ubuntu_desktop_x2go
```

运行（建议用于测试）

下面示例在容器内运行 systemd。下面的选项通常是必需的；它们会放宽隔离，可能不适合所有环境。

```bash
docker run --privileged -d \
  --tmpfs /run --tmpfs /run/lock \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -p 2222:22 \
  -e VNC_USER=myuser -e VNC_PASSWORD='yourpass' \
  --name gnome-x2go gnome-x2go:latest
```

启动后说明
- 容器将以 `systemd` 作为 PID 1 运行。您可以使用 `docker logs` 和 `docker exec -it <container> journalctl -f` 查看日志。
- 确认容器内 `sshd` 和 `x2goserver` 正在运行。如果没有：

```bash
docker exec -it <container> bash
# 进入容器后
systemctl enable --now ssh x2goserver
systemctl status ssh x2goserver
```

使用 X2Go 连接
- 在宿主机上安装 `x2goclient`。
- 新建会话，连接到 `localhost:2222`，使用 SSH 传输，输入您设置的用户（例如 `myuser` / `yourpass`）。
- 会话类型请选择 `Custom` 并将命令设置为 `gnome-session`，或在可选项中选择 `GNOME`。

故障排查
- 如果 `gnome-session` 立即退出：
  - 检查 `journalctl -u gdm` 和 `journalctl -xe`，查找与 logind、dbus 或合成器（Mutter）相关的错误。
  - 有些错误提示缺少设备（如 `/dev/dri`）或权限问题 —— 如果需要硬件加速，请考虑增加 `--device /dev/dri` 及 GPU 相关挂载。
  - 若 systemd/logind 错误持续，建议为 X2Go 使用更轻量的桌面环境（XFCE / MATE）。

替代方案
- 若要一个更稳健的容器桌面，优先考虑 XFCE + X2Go 或 TigerVNC + XFCE（更轻、更简单）。
- 若需完整的 GNOME 体验，请在虚拟机或具有 systemd 与实际设备访问的主机上运行。

安全性
- 使用 `--privileged` 并暴露 SSH 会增加攻击面。请加固密码，使用 SSH 密钥，或将容器置于防火墙后面。

