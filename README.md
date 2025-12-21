[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

<div align="center">

# 🪟 Windows Docker Optimized

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Run Windows 11 in Docker with ultimate performance optimization**

*Best practices for running Windows in containers, with or without KVM acceleration*

[Features](#-features) • [Quick Start](#-quick-start) • [Configuration](#-configuration) • [Access Methods](#-access-methods) • [FAQ](#-faq)

</div>

---

## ✨ Features

- 🚀 **Ultimate Performance Optimization** - TCG multi-threading, CPU instruction sets, disk I/O tuning
- 🔧 **KVM & Non-KVM Support** - Works on bare metal and cloud VMs (AWS, GCP, Azure)
- 🔐 **Auto SSH Setup** - OpenSSH Server automatically configured on first boot
- 🌐 **Multiple Access Methods** - Web (noVNC), RDP, SSH, SMB file sharing
- 📦 **One-Command Deployment** - Single docker run command to get started
- ⚙️ **Fully Configurable** - 50+ environment variables for customization
- 💾 **Flexible Storage** - Support for raw/qcow2, virtio-blk/scsi/nvme

## 📋 Requirements

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 8+ cores |
| RAM | 4 GB | 16+ GB |
| Storage | 64 GB | 200+ GB |
| KVM | Optional | Recommended (10x faster) |

### Software Requirements

- Docker 20.10+ or Podman 4.0+
- Linux host (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- For KVM: `/dev/kvm` device available

### Check KVM Support

```bash
# Check if KVM is available
ls -la /dev/kvm

# If not available, check CPU virtualization
grep -E "(vmx|svm)" /proc/cpuinfo

# Load KVM module (if supported)
sudo modprobe kvm
sudo modprobe kvm_intel  # or kvm_amd
```

## 🚀 Quick Start

### Basic Usage (With KVM)

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

### Without KVM (Cloud VMs)

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

### Access Windows

| Method | URL/Command |
|--------|-------------|
| Web Browser | http://localhost:8006 |
| RDP Client | `localhost:3389` |
| Default User | `Docker` / `admin` |

## ⚡ Ultimate Optimized Configuration

For maximum performance without KVM (e.g., on AWS EC2, GCP, Azure VMs):

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

### Basic Configuration

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

### With KVM Acceleration

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

## ⚙️ Configuration

### Windows Versions

| Value | Version | Size |
|-------|---------|------|
| `11` | Windows 11 Pro | 7.2 GB |
| `11l` | Windows 11 LTSC | 4.7 GB |
| `11e` | Windows 11 Enterprise | 6.6 GB |
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | Windows 10 LTSC | 4.6 GB |
| `10e` | Windows 10 Enterprise | 5.2 GB |
| `2025` | Windows Server 2025 | 6.7 GB |
| `2022` | Windows Server 2022 | 6.0 GB |
| `2019` | Windows Server 2019 | 5.3 GB |

### Environment Variables

#### Basic Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | `11` | Windows version to install |
| `KVM` | `Y` | Enable KVM acceleration (`N` to disable) |
| `RAM_SIZE` | `4G` | Memory allocation |
| `CPU_CORES` | `2` | Number of CPU cores |
| `DISK_SIZE` | `64G` | Virtual disk size |
| `USERNAME` | `Docker` | Windows username |
| `PASSWORD` | `admin` | Windows password |

#### Disk Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `DISK_TYPE` | `scsi` | Disk type: `blk`, `scsi`, `nvme`, `sata`, `ide` |
| `DISK_FMT` | `raw` | Disk format: `raw`, `qcow2` |
| `DISK_IO` | `native` | I/O mode: `native`, `threads`, `io_uring` |
| `DISK_CACHE` | `none` | Cache mode: `none`, `writeback`, `writethrough` |
| `DISK_DISCARD` | `on` | Enable TRIM support |
| `ALLOCATE` | `N` | Preallocate disk space |

#### Display Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `VGA` | `virtio` | VGA adapter type |
| `DISPLAY` | `web` | Display mode: `web`, `vnc`, `none` |
| `GPU` | `N` | GPU passthrough (Intel only) |

#### Network Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `DHCP` | `N` | Use DHCP for VM network |
| `SAMBA` | `Y` | Enable Samba file sharing |
| `MAC` | auto | Custom MAC address |

#### Advanced Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `MACHINE` | `q35` | Machine type |
| `HPET` | `off` | High Precision Event Timer |
| `TPM` | `N` | TPM emulation |
| `SMM` | `N` | System Management Mode |
| `ARGUMENTS` | - | Additional QEMU arguments |

### TCG Optimization Arguments

For non-KVM environments, use these QEMU arguments for best performance:

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

| Parameter | Description |
|-----------|-------------|
| `tcg,thread=multi` | Multi-threaded TCG translation |
| `tb-size=2048` | 2GB translation block cache |
| `-cpu max` | Enable all available CPU features |
| `+avx,+avx2,+aes` | Advanced instruction sets |
| `driftfix=slew` | Reduce clock drift |
| `disable_s3/s4` | Disable sleep/hibernate |

## 🔌 Access Methods

### 1. Web Browser (noVNC)

```
http://<host-ip>:8006
```

Best for: Installation monitoring, quick access

### 2. Remote Desktop (RDP)

```bash
# Windows
mstsc /v:<host-ip>:3389

# Linux (FreeRDP)
xfreerdp /v:<host-ip>:3389 /u:Admin /p:Admin123

# macOS
# Use Microsoft Remote Desktop app
```

### 3. SSH (After Setup)

SSH is automatically configured if you mount the OEM directory with the install script.

Create `oem/install.bat`:

```batch
@echo off
powershell -Command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"
powershell -Command "Start-Service sshd"
powershell -Command "Set-Service -Name sshd -StartupType 'Automatic'"
powershell -Command "New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue"
```

Then connect:

```bash
ssh -p 2222 Admin@<host-ip>
```

### 4. SMB File Sharing

After installation, a `Shared` folder appears on the desktop, mapped to the host's shared directory.

```bash
# Mount from Linux
mount -t cifs //<host-ip>/shared /mnt/windows -o username=Admin,password=Admin123

# Access from Windows
\\<host-ip>\shared
```

## 🏗️ Project Structure

```
windows-docker-optimized/
├── README.md                 # English documentation
├── README_CN.md              # Chinese documentation
├── README_TW.md              # Traditional Chinese documentation
├── README_JP.md              # Japanese documentation
├── docker-compose.yml        # Basic compose file
├── docker-compose.optimized.yml  # Optimized compose file
├── docker-compose.kvm.yml    # KVM-enabled compose file
├── oem/
│   └── install.bat           # Auto SSH setup script
├── scripts/
│   ├── check-kvm.sh          # KVM availability checker
│   └── optimize-host.sh      # Host optimization script
└── LICENSE
```

## 🔧 Troubleshooting

### KVM Not Available

```bash
# Check if running in a VM
systemd-detect-virt

# If output is "amazon", "kvm", "vmware", etc., you're in a VM
# Use KVM="N" in this case
```

### Slow Performance Without KVM

This is expected. TCG software emulation is ~10x slower than KVM. Optimizations in this guide help, but hardware virtualization is always faster.

### Container Keeps Restarting

```bash
# Check logs
docker logs windows11

# Common issues:
# - KVM not available but KVM="N" not set
# - Invalid QEMU arguments
# - Insufficient disk space
```

### Cannot Connect via RDP

1. Wait for Windows installation to complete
2. Check if port 3389 is exposed
3. Verify firewall rules on host
4. Try web interface first (port 8006)

## 📊 Performance Comparison

| Configuration | Boot Time | Responsiveness |
|---------------|-----------|----------------|
| With KVM | ~2 min | Native-like |
| Without KVM (optimized) | ~15-20 min | Usable |
| Without KVM (default) | ~30+ min | Slow |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [dockur/windows](https://github.com/dockur/windows) - The amazing base project
- [QEMU](https://www.qemu.org/) - The virtualization engine
- All contributors and users

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/windows-docker-optimized&type=Date)](https://star-history.com/#neosun100/windows-docker-optimized)

## 📱 关注公众号

<div align="center">

![公众号](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
