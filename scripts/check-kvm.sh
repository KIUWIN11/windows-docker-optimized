#!/bin/bash
# Check KVM availability and provide recommendations

echo "=========================================="
echo "KVM Availability Check"
echo "=========================================="
echo ""

# Check if running in a VM
VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "unknown")
echo "Virtualization Type: $VIRT_TYPE"

# Check for KVM device
if [ -e /dev/kvm ]; then
    echo "KVM Device: ✅ Available (/dev/kvm exists)"
    KVM_AVAILABLE=true
else
    echo "KVM Device: ❌ Not available (/dev/kvm missing)"
    KVM_AVAILABLE=false
fi

# Check CPU virtualization flags
VMX=$(grep -c vmx /proc/cpuinfo 2>/dev/null || echo "0")
SVM=$(grep -c svm /proc/cpuinfo 2>/dev/null || echo "0")

if [ "$VMX" -gt 0 ]; then
    echo "CPU Virtualization: ✅ Intel VT-x supported"
elif [ "$SVM" -gt 0 ]; then
    echo "CPU Virtualization: ✅ AMD-V supported"
else
    echo "CPU Virtualization: ❌ Not detected (vmx/svm flags missing)"
fi

# Check KVM modules
echo ""
echo "KVM Modules:"
lsmod | grep kvm || echo "  No KVM modules loaded"

echo ""
echo "=========================================="
echo "Recommendation"
echo "=========================================="

if [ "$KVM_AVAILABLE" = true ]; then
    echo "✅ Use KVM acceleration for best performance"
    echo "   Set: KVM=\"Y\" (default)"
else
    echo "⚠️  KVM not available - use software emulation"
    echo "   Set: KVM=\"N\""
    echo ""
    echo "   Common reasons:"
    echo "   - Running inside a VM without nested virtualization"
    echo "   - Cloud provider doesn't expose KVM (AWS, GCP, Azure VMs)"
    echo "   - KVM modules not loaded"
    echo ""
    echo "   To enable KVM (if supported):"
    echo "   sudo modprobe kvm"
    echo "   sudo modprobe kvm_intel  # or kvm_amd"
fi

echo ""
