[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

<div align="center">

# 🪟 Windows Docker 極致優化版

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**在 Docker 中運行 Windows 11，極致性能優化**

*支援 KVM 加速和無 KVM 環境（AWS、GCP、Azure 雲端伺服器）的最佳實踐*

[功能特性](#-功能特性) • [快速開始](#-快速開始) • [配置說明](#-配置說明) • [存取方式](#-存取方式) • [常見問題](#-常見問題)

</div>

---

## ✨ 功能特性

- 🚀 **極致性能優化** - TCG 多執行緒、CPU 指令集優化、磁碟 I/O 調優
- 🔧 **支援 KVM 和無 KVM 環境** - 適用於裸金屬伺服器和雲端虛擬機
- 🔐 **自動配置 SSH** - 首次啟動自動安裝配置 OpenSSH Server
- 🌐 **多種存取方式** - Web (noVNC)、RDP、SSH、SMB 檔案共享
- 📦 **一鍵部署** - 單條 docker run 命令即可啟動
- ⚙️ **完全可配置** - 50+ 環境變數可自訂
- 💾 **靈活儲存** - 支援 raw/qcow2 格式，virtio-blk/scsi/nvme 磁碟類型

## 📋 環境要求

### 硬體要求

| 組件 | 最低配置 | 建議配置 |
|------|----------|----------|
| CPU | 2 核心 | 8+ 核心 |
| 記憶體 | 4 GB | 16+ GB |
| 儲存 | 64 GB | 200+ GB |
| KVM | 可選 | 建議（快 10 倍） |

### 軟體要求

- Docker 20.10+ 或 Podman 4.0+
- Linux 主機（Ubuntu 20.04+、Debian 11+、CentOS 8+）
- KVM 加速需要 `/dev/kvm` 裝置

### 檢查 KVM 支援

```bash
# 檢查 KVM 是否可用
ls -la /dev/kvm

# 如果不可用，檢查 CPU 虛擬化支援
grep -E "(vmx|svm)" /proc/cpuinfo

# 載入 KVM 模組（如果支援）
sudo modprobe kvm
sudo modprobe kvm_intel  # 或 kvm_amd
```

## 🚀 快速開始

### 基礎用法（有 KVM）

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

### 無 KVM 環境（雲端伺服器）

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

### 存取 Windows

| 方式 | 地址 |
|------|------|
| 瀏覽器存取 | http://localhost:8006 |
| RDP 用戶端 | `localhost:3389` |
| 預設帳戶 | `Docker` / `admin` |

## ⚡ 極致優化配置

適用於無 KVM 環境（如 AWS EC2、GCP、Azure 虛擬機）的最大性能配置：

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

## ⚙️ 配置說明

### Windows 版本

| 值 | 版本 | 大小 |
|----|------|------|
| `11` | Windows 11 Pro | 7.2 GB |
| `11l` | Windows 11 LTSC | 4.7 GB |
| `11e` | Windows 11 Enterprise | 6.6 GB |
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | Windows 10 LTSC | 4.6 GB |
| `2025` | Windows Server 2025 | 6.7 GB |
| `2022` | Windows Server 2022 | 6.0 GB |

### 環境變數

#### 基礎設定

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `VERSION` | `11` | Windows 版本 |
| `KVM` | `Y` | 啟用 KVM 加速（`N` 停用） |
| `RAM_SIZE` | `4G` | 記憶體大小 |
| `CPU_CORES` | `2` | CPU 核心數 |
| `DISK_SIZE` | `64G` | 虛擬磁碟大小 |
| `USERNAME` | `Docker` | Windows 使用者名稱 |
| `PASSWORD` | `admin` | Windows 密碼 |

#### 磁碟設定

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `DISK_TYPE` | `scsi` | 磁碟類型：`blk`、`scsi`、`nvme`、`sata`、`ide` |
| `DISK_FMT` | `raw` | 磁碟格式：`raw`、`qcow2` |
| `DISK_IO` | `native` | I/O 模式：`native`、`threads`、`io_uring` |
| `DISK_CACHE` | `none` | 快取模式：`none`、`writeback`、`writethrough` |

### TCG 優化參數

無 KVM 環境下的最佳 QEMU 參數：

| 參數 | 說明 |
|------|------|
| `tcg,thread=multi` | TCG 多執行緒翻譯 |
| `tb-size=2048` | 2GB 翻譯區塊快取 |
| `-cpu max` | 啟用所有可用 CPU 特性 |
| `+avx,+avx2,+aes` | 進階指令集 |
| `driftfix=slew` | 減少時鐘漂移 |
| `disable_s3/s4` | 停用睡眠/休眠 |

## 🔌 存取方式

### 1. 瀏覽器存取 (noVNC)

```
http://<主機IP>:8006
```

### 2. 遠端桌面 (RDP)

```bash
# Windows
mstsc /v:<主機IP>:3389

# Linux (FreeRDP)
xfreerdp /v:<主機IP>:3389 /u:Admin /p:Admin123
```

### 3. SSH 存取

```bash
ssh -p 2222 Admin@<主機IP>
```

### 4. SMB 檔案共享

```bash
# Windows 存取
\\<主機IP>\shared
```

## 📊 性能對比

| 配置 | 啟動時間 | 回應速度 |
|------|----------|----------|
| 有 KVM | ~2 分鐘 | 接近原生 |
| 無 KVM（優化後） | ~15-20 分鐘 | 可用 |
| 無 KVM（預設） | ~30+ 分鐘 | 較慢 |

## 📄 授權條款

本專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案。

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/windows-docker-optimized&type=Date)](https://star-history.com/#neosun100/windows-docker-optimized)

## 📱 關注公眾號

<div align="center">

![公眾號](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
