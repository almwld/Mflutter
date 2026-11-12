#!/system/bin/sh
# Read-only Android capability audit for Mflutter / Mudabbir.
# Run from Termux: sh device_audit_android.sh > mudabbir_device_audit.json
# This script does not modify device settings, app data, or model files.

set -u

getp() { getprop "$1" 2>/dev/null | tr '\n' ' '; }
read_num() { awk -v key="$1" '$1 == key {print $2; exit}' /proc/meminfo 2>/dev/null; }
json_escape() {
  printf '%s' "${1:-}" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\r//g; s/\n/ /g'
}
field() {
  key="$1"; value="$2"
  printf '  "%s": "%s"' "$key" "$(json_escape "$value")"
}
cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || awk -F: '/^processor/ {n++} END {print n+0}' /proc/cpuinfo)"
ram_total_kb="$(read_num MemTotal)"
ram_available_kb="$(read_num MemAvailable)"
[ -n "$ram_total_kb" ] || ram_total_kb=0
[ -n "$ram_available_kb" ] || ram_available_kb=0
ram_total_mb=$((ram_total_kb / 1024))
ram_available_mb=$((ram_available_kb / 1024))
cpu_abi="$(getp ro.product.cpu.abi)"
cpu_abilist="$(getp ro.product.cpu.abilist)"
cpu_hardware="$(getp ro.hardware)"
cpu_board="$(getp ro.product.board)"
device_model="$(getp ro.product.model)"
android_release="$(getp ro.build.version.release)"
api_level="$(getp ro.build.version.sdk)"
gpu_info="$(dumpsys SurfaceFlinger 2>/dev/null | grep -i -m 4 -E 'GLES:|GL_VENDOR|GL_RENDERER|Vulkan' | tr '\n' ';' | cut -c1-500)"
gpu_props="$(getp ro.hardware.egl)"
vulkan_features="$(pm list features 2>/dev/null | grep -i vulkan | tr '\n' ';')"
nnapi_features="$(pm list features 2>/dev/null | grep -i -E 'neural|nnapi' | tr '\n' ';')"
opencl_libs=""
for f in /vendor/lib64/libOpenCL.so /system/vendor/lib64/libOpenCL.so /vendor/lib/libOpenCL.so; do
  [ -e "$f" ] && opencl_libs="$opencl_libs$f;"
done
nnapi_libs=""
for f in /vendor/lib64/libneuralnetworks.so /system/lib64/libneuralnetworks.so /vendor/lib/libneuralnetworks.so; do
  [ -e "$f" ] && nnapi_libs="$nnapi_libs$f;"
done
battery_dump="$(dumpsys battery 2>/dev/null)"
battery_level="$(printf '%s\n' "$battery_dump" | awk -F': ' '/level:/ {print $2; exit}')"
battery_temp="$(printf '%s\n' "$battery_dump" | awk -F': ' '/temperature:/ {print $2; exit}')"
battery_status="$(printf '%s\n' "$battery_dump" | awk -F': ' '/status:/ {print $2; exit}')"
storage_line="$(df -k /data 2>/dev/null | tail -n 1)"
storage_available_kb="$(printf '%s\n' "$storage_line" | awk '{print $4}')"
[ -n "$storage_available_kb" ] || storage_available_kb=0
storage_available_mb=$((storage_available_kb / 1024))
mudabbir_packages="$(pm list packages 2>/dev/null | grep -i -E 'mudabbir|asrar' | tr '\n' ';')"
mudabbir_processes="$(ps -A 2>/dev/null | grep -i -E 'mudabbir|asrar' | grep -v grep | tr '\n' ';')"
gguf_downloads="$(find /sdcard/Download /storage/emulated/0/Download -maxdepth 2 -type f -iname '*.gguf' 2>/dev/null | head -n 10 | tr '\n' ';')"
llama_processes="$(ps -A 2>/dev/null | grep -i llama | grep -v grep | tr '\n' ';')"

printf '{\n'
field "audit_schema" "mudabbir.android.device-audit.v1"; printf ',\n'
field "device_model" "$device_model"; printf ',\n'
field "cpu_abi" "$cpu_abi"; printf ',\n'
field "cpu_abilist" "$cpu_abilist"; printf ',\n'
field "cpu_hardware" "$cpu_hardware"; printf ',\n'
field "cpu_board" "$cpu_board"; printf ',\n'
field "cpu_cores_online" "$cores"; printf ',\n'
field "ram_total_mb" "$ram_total_mb"; printf ',\n'
field "ram_available_mb_at_audit" "$ram_available_mb"; printf ',\n'
field "android_release" "$android_release"; printf ',\n'
field "android_api_level" "$api_level"; printf ',\n'
field "gpu_egl_property" "$gpu_props"; printf ',\n'
field "gpu_surfaceflinger_info" "$gpu_info"; printf ',\n'
field "vulkan_features" "$vulkan_features"; printf ',\n'
field "opencl_libraries_found" "$opencl_libs"; printf ',\n'
field "nnapi_features" "$nnapi_features"; printf ',\n'
field "nnapi_libraries_found" "$nnapi_libs"; printf ',\n'
field "battery_level_percent" "$battery_level"; printf ',\n'
field "battery_temperature_tenths_c" "$battery_temp"; printf ',\n'
field "battery_status_code" "$battery_status"; printf ',\n'
field "data_partition_available_mb" "$storage_available_mb"; printf ',\n'
field "mudabbir_package_candidates" "$mudabbir_packages"; printf ',\n'
field "mudabbir_process_candidates" "$mudabbir_processes"; printf ',\n'
field "llama_process_candidates" "$llama_processes"; printf ',\n'
field "gguf_files_in_download_folders" "$gguf_downloads"; printf ',\n'
field "model_storage_from_repository_docs" "App-private storage; Termux cannot inspect its contents reliably"; printf ',\n'
field "app_private_model_memory_usage" "NOT_MEASURED: requires an in-app diagnostic because Android isolates app-private data and process memory"; printf ',\n'
field "mmap_runtime_status" "NOT_MEASURED: requires llama.cpp runtime instrumentation"; printf ',\n'
field "notes" "Read-only audit. GPU and accelerator capability presence does not prove Flutter/llama.cpp inference acceleration support."
printf '\n}\n'
