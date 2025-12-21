[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

<div align="center">

# 🪟 Windows Docker 极致优化版

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**在 Docker 中运行 Windows 11，极致性能优化**

*支持 KVM 加速和无 KVM 环境（AWS、GCP、Azure 云服务器）的最佳实践*

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [配置说明](#-配置说明) • [访问方式](#-访问方式) • [常见问题](#-常见问题)

</div>

---

## ✨ 功能特性

- 🚀 **极致性能优化** - TCG 多线程、CPU 指令集优化、磁盘 I/O 调优
- 🔧 **支持 KVM 和无 KVM 环境** - 适用于裸金属服务器和云虚拟机
- 🔐 **自动配置 SSH** - 首次启动自动安装配置 OpenSSH Server
- 🌐 **多种访问方式** - Web (noVNC)、RDP、SSH、SMB 文件共享
- 📦 **一键部署** - 单条 docker run 命令即可启动
- ⚙️ **完全可配置** - 50+ 环境变量可自定义
- 💾 **灵活存储** - 支持 raw/qcow2 格式，virtio-blk/scsi/nvme 磁盘类型

## 📋 环境要求

### 硬件要求

| 组件 | 最低配置 | 推荐配置 |
|------|----------|----------|
| CPU | 2 核心 | 8+ 核心 |
| 内存 | 4 GB | 16+ GB |
| 存储 | 64 GB | 200+ GB |
| KVM | 可选 | 推荐（快 10 倍） |

### 软件要求

- Docker 20.10+ 或 Podman 4.0+
- Linux 宿主机（Ubuntu 20.04+、Debian 11+、CentOS 8+）
- KVM 加速需要 `/dev/kvm` 设备

### 检查 KVM 支持

```bash
# 检查 KVM 是否可用
ls -la /dev/kvm

# 如果不可用，检查 CPU 虚拟化支持
grep -E "(vmx|svm)" /proc/cpuinfo

# 加载 KVM 模块（如果支持）
sudo modprobe kvm
sudo modprobe kvm_intel  # 或 kvm_amd
```

## 🚀 快速开始

### 基础用法（有 KVM）

```bash
docker run -d \
  --name windows11 \
  -e VERSION="11" \
  -p 8006:8006 \
  -p 3389:3389/tcp \
  -p 3389:3389/udp \
  --device /dev/kvm \
  --device /dev/net/tun \
  --cap-add NET_ADMIN \
  -v ./windows:/storage \
  --restart always \
  dockurr/windows:latest
```

### 无 KVM 环境（云服务器）

```bash
docker run -d \
  --name windows11 \
  -e VERSION="11" \
  -e KVM="N" \
  -p 8006:8006 \
  -p 3389:3389/tcp \
  -p 3389:3389/udp \
  --device /dev/net/tun \
  --cap-add NET_ADMIN \
  --privileged \
  -v ./windows:/storage \
  --restart always \
  dockurr/windows:latest
```

### 访问 Windows

| 方式 | 地址 |
|------|------|
| 浏览器访问 | http://localhost:8006 |
| RDP 客户端 | `localhost:3389` |
| 默认账户 | `Docker` / `admin` |

## ⚡ 极致优化配置

适用于无 KVM 环境（如 AWS EC2、GCP、Azure 虚拟机）的最大性能配置：

```bash
docker run -d \
  --name windows11 \
  --hostname windows11 \
  --privileged \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  --device /dev/vhost-net:/dev/vhost-net \
  --env VERSION="11" \
  --env KVM="N" \
  --env RAM_SIZE="64G" \
  --env CPU_CORES="16" \
  --env DISK_SIZE="200G" \
  --env DISK_IO="threads" \
  --env DISK_CACHE="writeback" \
  --env DISK_TYPE="blk" \
  --env DISK_FMT="raw" \
  --env DISK_DISCARD="on" \
  --env DISK_ROTATION="1" \
  --env ALLOCATE="N" \
  --env MACHINE="q35" \
  --env VGA="virtio" \
  --env USERNAME="Admin" \
  --env PASSWORD="YourSecurePassword" \
  --env SAMBA="Y" \
  --env TPM="N" \
  --env SMM="N" \
  --env HPET="off" \
  --env VMPORT="off" \
  --env ARGUMENTS="-accel tcg,thread=multi,tb-size=2048 -cpu max,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx,+avx2,+aes,+xsave,+xsaveopt,+rdrand,+f16c,+bmi1,+bmi2,+fma,+movbe,+smep,+erms,+adx,+sha-ni,+clflushopt -smp 16,sockets=1,cores=16,threads=1 -overcommit mem-lock=off -rtc base=localtime,clock=host,driftfix=slew -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 -boot menu=off,strict=on" \
  --publish 0.0.0.0:8006:8006/tcp \
  --publish 0.0.0.0:3389:3389/tcp \
  --publish 0.0.0.0:3389:3389/udp \
  --publish 0.0.0.0:2222:22/tcp \
  --volume /data/windows:/storage \
  --volume /data/windows/oem:/oem \
  --tmpfs /tmp:rw,nosuid,nodev,exec,size=8g \
  --memory 72g \
  --memory-swap 72g \
  --cpu-shares 2048 \
  --cpus 20 \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65535:65535 \
  --restart always \
  --stop-timeout 120 \
  dockurr/windows:latest
```

## 🐳 Docker Compose

### 基础配置

```yaml
version: "3.8"
services:
  windows:
    image: dockurr/windows:latest
    container_name: windows11
    hostname: windows11
    privileged: true
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
      - /dev/vhost-net:/dev/vhost-net
    environment:
      VERSION: "11"
      KVM: "N"
      RAM_SIZE: "64G"
      CPU_CORES: "16"
      DISK_SIZE: "200G"
      DISK_IO: "threads"
      DISK_CACHE: "writeback"
      DISK_TYPE: "blk"
      DISK_FMT: "raw"
      USERNAME: "Admin"
      PASSWORD: "Admin123"
      SAMBA: "Y"
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
      - "3389:3389/udp"
      - "2222:22"
    volumes:
      - ./windows:/storage
      - ./oem:/oem
    tmpfs:
      - /tmp:rw,nosuid,nodev,exec,size=8g
    deploy:
      resources:
        limits:
          cpus: "20"
          memory: 72G
    restart: always
    stop_grace_period: 2m
```

### 带 KVM 加速

```yaml
version: "3.8"
services:
  windows:
    image: dockurr/windows:latest
    container_name: windows11
    devices:
      - /dev/kvm:/dev/kvm
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
    environment:
      VERSION: "11"
      RAM_SIZE: "8G"
      CPU_CORES: "4"
      DISK_SIZE: "64G"
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
      - "3389:3389/udp"
    volumes:
      - ./windows:/storage
    restart: always
    stop_grace_period: 2m
```

## ⚙️ 配置说明

### Windows 版本

| 值 | 版本 | 大小 |
|----|------|------|
| `11` | Windows 11 Pro | 7.2 GB |
| `11l` | Windows 11 LTSC | 4.7 GB |
| `11e` | Windows 11 Enterprise | 6.6 GB |
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | Windows 10 LTSC | 4.6 GB |
| `10e` | Windows 10 Enterprise | 5.2 GB |
| `2025` | Windows Server 2025 | 6.7 GB |
| `2022` | Windows Server 2022 | 6.0 GB |
| `2019` | Windows Server 2019 | 5.3 GB |

### 环境变量

#### 基础设置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `VERSION` | `11` | Windows 版本 |
| `KVM` | `Y` | 启用 KVM 加速（`N` 禁用） |
| `RAM_SIZE` | `4G` | 内存大小 |
| `CPU_CORES` | `2` | CPU 核心数 |
| `DISK_SIZE` | `64G` | 虚拟磁盘大小 |
| `USERNAME` | `Docker` | Windows 用户名 |
| `PASSWORD` | `admin` | Windows 密码 |

#### 磁盘设置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DISK_TYPE` | `scsi` | 磁盘类型：`blk`、`scsi`、`nvme`、`sata`、`ide` |
| `DISK_FMT` | `raw` | 磁盘格式：`raw`、`qcow2` |
| `DISK_IO` | `native` | I/O 模式：`native`、`threads`、`io_uring` |
| `DISK_CACHE` | `none` | 缓存模式：`none`、`writeback`、`writethrough` |
| `DISK_DISCARD` | `on` | 启用 TRIM 支持 |
| `ALLOCATE` | `N` | 预分配磁盘空间 |

#### 显示设置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `VGA` | `virtio` | VGA 适配器类型 |
| `DISPLAY` | `web` | 显示模式：`web`、`vnc`、`none` |
| `GPU` | `N` | GPU 直通（仅支持 Intel） |

#### 网络设置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DHCP` | `N` | 使用 DHCP 获取 IP |
| `SAMBA` | `Y` | 启用 Samba 文件共享 |
| `MAC` | 自动 | 自定义 MAC 地址 |

#### 高级设置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MACHINE` | `q35` | 机器类型 |
| `HPET` | `off` | 高精度事件定时器 |
| `TPM` | `N` | TPM 模拟 |
| `SMM` | `N` | 系统管理模式 |
| `ARGUMENTS` | - | 额外 QEMU 参数 |

### TCG 优化参数

无 KVM 环境下的最佳 QEMU 参数：

```bash
ARGUMENTS="-accel tcg,thread=multi,tb-size=2048 \
  -cpu max,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx,+avx2,+aes,+xsave,+xsaveopt,+rdrand,+f16c,+bmi1,+bmi2,+fma,+movbe,+smep,+erms,+adx,+sha-ni,+clflushopt \
  -smp 16,sockets=1,cores=16,threads=1 \
  -overcommit mem-lock=off \
  -rtc base=localtime,clock=host,driftfix=slew \
  -global ICH9-LPC.disable_s3=1 \
  -global ICH9-LPC.disable_s4=1 \
  -boot menu=off,strict=on"
```

| 参数 | 说明 |
|------|------|
| `tcg,thread=multi` | TCG 多线程翻译 |
| `tb-size=2048` | 2GB 翻译块缓存 |
| `-cpu max` | 启用所有可用 CPU 特性 |
| `+avx,+avx2,+aes` | 高级指令集 |
| `driftfix=slew` | 减少时钟漂移 |
| `disable_s3/s4` | 禁用睡眠/休眠 |

## 🔌 访问方式

### 1. 浏览器访问 (noVNC)

```
http://<宿主机IP>:8006
```

适用于：安装过程监控、快速访问

### 2. 远程桌面 (RDP)

```bash
# Windows
mstsc /v:<宿主机IP>:3389

# Linux (FreeRDP)
xfreerdp /v:<宿主机IP>:3389 /u:Admin /p:Admin123

# macOS
# 使用 Microsoft Remote Desktop 应用
```

### 3. SSH 访问（需配置）

挂载 OEM 目录并创建 `oem/install.bat`：

```batch
@echo off
powershell -Command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"
powershell -Command "Start-Service sshd"
powershell -Command "Set-Service -Name sshd -StartupType 'Automatic'"
powershell -Command "New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue"
```

连接命令：

```bash
ssh -p 2222 Admin@<宿主机IP>
```

### 4. SMB 文件共享

安装完成后，桌面会出现 `Shared` 文件夹，映射到宿主机共享目录。

```bash
# Linux 挂载
mount -t cifs //<宿主机IP>/shared /mnt/windows -o username=Admin,password=Admin123

# Windows 访问
\\<宿主机IP>\shared
```

## 🔧 故障排除

### KVM 不可用

```bash
# 检查是否在虚拟机中运行
systemd-detect-virt

# 如果输出 "amazon"、"kvm"、"vmware" 等，说明在虚拟机中
# 此时需要设置 KVM="N"
```

### 无 KVM 时性能慢

这是正常的。TCG 软件模拟比 KVM 慢约 10 倍。本指南的优化可以改善，但硬件虚拟化始终更快。

### 容器不断重启

```bash
# 查看日志
docker logs windows11

# 常见问题：
# - KVM 不可用但未设置 KVM="N"
# - QEMU 参数无效
# - 磁盘空间不足
```

### 无法通过 RDP 连接

1. 等待 Windows 安装完成
2. 检查端口 3389 是否暴露
3. 检查宿主机防火墙规则
4. 先尝试 Web 界面（端口 8006）

## 📊 性能对比

| 配置 | 启动时间 | 响应速度 |
|------|----------|----------|
| 有 KVM | ~2 分钟 | 接近原生 |
| 无 KVM（优化后） | ~15-20 分钟 | 可用 |
| 无 KVM（默认） | ~30+ 分钟 | 较慢 |

## 🤝 贡献指南

欢迎贡献！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [dockur/windows](https://github.com/dockur/windows) - 优秀的基础项目
- [QEMU](https://www.qemu.org/) - 虚拟化引擎
- 所有贡献者和用户

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/windows-docker-optimized&type=Date)](https://star-history.com/#neosun100/windows-docker-optimized)

## 📱 关注公众号

<div align="center">

![公众号](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
