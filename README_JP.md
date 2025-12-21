[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

<div align="center">

# 🪟 Windows Docker 最適化版

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Docker で Windows 11 を実行、究極のパフォーマンス最適化**

*KVM アクセラレーションと非 KVM 環境（AWS、GCP、Azure クラウドサーバー）のベストプラクティス*

[機能](#-機能) • [クイックスタート](#-クイックスタート) • [設定](#-設定) • [アクセス方法](#-アクセス方法) • [FAQ](#-faq)

</div>

---

## ✨ 機能

- 🚀 **究極のパフォーマンス最適化** - TCG マルチスレッド、CPU 命令セット最適化、ディスク I/O チューニング
- 🔧 **KVM と非 KVM 環境をサポート** - ベアメタルサーバーとクラウド VM に対応
- 🔐 **SSH 自動設定** - 初回起動時に OpenSSH Server を自動インストール・設定
- 🌐 **複数のアクセス方法** - Web (noVNC)、RDP、SSH、SMB ファイル共有
- 📦 **ワンコマンドデプロイ** - 単一の docker run コマンドで起動
- ⚙️ **完全にカスタマイズ可能** - 50 以上の環境変数で設定可能
- 💾 **柔軟なストレージ** - raw/qcow2 形式、virtio-blk/scsi/nvme ディスクタイプをサポート

## 📋 要件

### ハードウェア要件

| コンポーネント | 最小 | 推奨 |
|----------------|------|------|
| CPU | 2 コア | 8+ コア |
| RAM | 4 GB | 16+ GB |
| ストレージ | 64 GB | 200+ GB |
| KVM | オプション | 推奨（10倍高速） |

### ソフトウェア要件

- Docker 20.10+ または Podman 4.0+
- Linux ホスト（Ubuntu 20.04+、Debian 11+、CentOS 8+）
- KVM アクセラレーションには `/dev/kvm` デバイスが必要

### KVM サポートの確認

```bash
# KVM が利用可能か確認
ls -la /dev/kvm

# 利用できない場合、CPU 仮想化サポートを確認
grep -E "(vmx|svm)" /proc/cpuinfo

# KVM モジュールをロード（サポートされている場合）
sudo modprobe kvm
sudo modprobe kvm_intel  # または kvm_amd
```

## 🚀 クイックスタート

### 基本的な使用方法（KVM あり）

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

### KVM なし（クラウド VM）

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

### Windows へのアクセス

| 方法 | URL/コマンド |
|------|--------------|
| Web ブラウザ | http://localhost:8006 |
| RDP クライアント | `localhost:3389` |
| デフォルトユーザー | `Docker` / `admin` |

## ⚡ 究極の最適化設定

KVM なし環境（AWS EC2、GCP、Azure VM など）での最大パフォーマンス設定：

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

## ⚙️ 設定

### Windows バージョン

| 値 | バージョン | サイズ |
|----|------------|--------|
| `11` | Windows 11 Pro | 7.2 GB |
| `11l` | Windows 11 LTSC | 4.7 GB |
| `11e` | Windows 11 Enterprise | 6.6 GB |
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | Windows 10 LTSC | 4.6 GB |
| `2025` | Windows Server 2025 | 6.7 GB |
| `2022` | Windows Server 2022 | 6.0 GB |

### 環境変数

#### 基本設定

| 変数 | デフォルト | 説明 |
|------|------------|------|
| `VERSION` | `11` | Windows バージョン |
| `KVM` | `Y` | KVM アクセラレーション（`N` で無効化） |
| `RAM_SIZE` | `4G` | メモリサイズ |
| `CPU_CORES` | `2` | CPU コア数 |
| `DISK_SIZE` | `64G` | 仮想ディスクサイズ |
| `USERNAME` | `Docker` | Windows ユーザー名 |
| `PASSWORD` | `admin` | Windows パスワード |

#### ディスク設定

| 変数 | デフォルト | 説明 |
|------|------------|------|
| `DISK_TYPE` | `scsi` | ディスクタイプ：`blk`、`scsi`、`nvme`、`sata`、`ide` |
| `DISK_FMT` | `raw` | ディスク形式：`raw`、`qcow2` |
| `DISK_IO` | `native` | I/O モード：`native`、`threads`、`io_uring` |
| `DISK_CACHE` | `none` | キャッシュモード：`none`、`writeback`、`writethrough` |

### TCG 最適化パラメータ

| パラメータ | 説明 |
|------------|------|
| `tcg,thread=multi` | TCG マルチスレッド変換 |
| `tb-size=2048` | 2GB 変換ブロックキャッシュ |
| `-cpu max` | 利用可能なすべての CPU 機能を有効化 |
| `+avx,+avx2,+aes` | 高度な命令セット |
| `driftfix=slew` | クロックドリフトを軽減 |
| `disable_s3/s4` | スリープ/休止状態を無効化 |

## 🔌 アクセス方法

### 1. Web ブラウザ (noVNC)

```
http://<ホストIP>:8006
```

### 2. リモートデスクトップ (RDP)

```bash
# Windows
mstsc /v:<ホストIP>:3389

# Linux (FreeRDP)
xfreerdp /v:<ホストIP>:3389 /u:Admin /p:Admin123
```

### 3. SSH アクセス

```bash
ssh -p 2222 Admin@<ホストIP>
```

### 4. SMB ファイル共有

```bash
# Windows からアクセス
\\<ホストIP>\shared
```

## 📊 パフォーマンス比較

| 設定 | 起動時間 | 応答性 |
|------|----------|--------|
| KVM あり | 約2分 | ネイティブに近い |
| KVM なし（最適化後） | 約15-20分 | 使用可能 |
| KVM なし（デフォルト） | 約30分以上 | 遅い |

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/windows-docker-optimized&type=Date)](https://star-history.com/#neosun100/windows-docker-optimized)

## 📱 公式アカウントをフォロー

<div align="center">

![公式アカウント](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
