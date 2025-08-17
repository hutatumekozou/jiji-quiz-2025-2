#!/bin/bash

# ===== 最終クリーンアップ - +20GB目標 (sudo含む) =====

set -e

# ===== 設定 =====
PROJ_ROOT="/Users/kukkiiboy/Desktop/Claude code/8月4日O3XcodeTrans/jiji-quiz-2025-2/JijiQuiz2025"
REPORT="$HOME/Desktop/_FinalCleanupReport_$(date +%Y%m%d_%H%M%S).txt"
TARGET_IOS_MAJOR="18"        # iOS 18以外のランタイムを削除
ARCHIVES_DAYS_OLD=30         # 30日より古いアーカイブを削除
KEEP_IOS_BACKUPS=1           # iPhoneバックアップは最新1つだけ

# ===== 初期化 =====
echo "=== 最終クリーンアップ - +20GB目標 (sudo含む) ===" | tee "$REPORT"
echo "Started at: $(date)" | tee -a "$REPORT"
echo "Project root: $PROJ_ROOT" | tee -a "$REPORT"
echo "Target: +20GB free space" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ===== 関数定義 =====

# 容量チェック関数
check_disk_usage() {
    local label="$1"
    echo "=== Disk Usage ($label) ===" | tee -a "$REPORT"
    df -h / | tee -a "$REPORT"
    local available_kb=$(df / | tail -1 | awk '{print $4}')
    local available_gb=$(echo "scale=2; $available_kb / 1024 / 1024" | bc -l 2>/dev/null || echo "0")
    echo "Available: ${available_gb} GB" | tee -a "$REPORT"
    echo "" | tee -a "$REPORT"
    echo "$available_kb"
}

# サイズ計算関数（MB単位）
get_size_mb() {
    local path="$1"
    if [[ -e "$path" ]]; then
        du -sm "$path" 2>/dev/null | awk '{print $1}' || echo "0"
    else
        echo "0"
    fi
}

# 確認付き削除関数
confirm_and_delete() {
    local path="$1"
    local description="$2"
    local use_sudo="$3"
    
    if [[ ! -e "$path" ]]; then
        echo "  SKIP: $description (not found)" | tee -a "$REPORT"
        return 0
    fi
    
    local size_mb=$(get_size_mb "$path")
    local size_gb=$(echo "scale=2; $size_mb / 1024" | bc -l 2>/dev/null || echo "0")
    
    echo "  Target: $description" | tee -a "$REPORT"
    echo "    Path: $path" | tee -a "$REPORT"
    echo "    Size: ${size_mb} MB (${size_gb} GB)" | tee -a "$REPORT"
    
    if [[ "$use_sudo" == "true" ]]; then
        echo "    ⚠️  This operation requires sudo privileges" | tee -a "$REPORT"
    fi
    
    echo "    Press Enter to continue, or Ctrl+C to cancel..."
    read
    
    local delete_cmd="rm -rf \"$path\""
    if [[ "$use_sudo" == "true" ]]; then
        delete_cmd="sudo rm -rf \"$path\""
    fi
    
    if eval "$delete_cmd" 2>/dev/null; then
        echo "    ✅ Deleted successfully" | tee -a "$REPORT"
        TOTAL_FREED_MB=$((TOTAL_FREED_MB + size_mb))
    else
        echo "    ❌ Failed to delete" | tee -a "$REPORT"
        echo "      - $path" >> "$REPORT.errors"
    fi
    echo "" | tee -a "$REPORT"
}

# iPhone バックアップ整理（最新1つのみ残す）
cleanup_ios_backups_final() {
    local backup_dir="$HOME/Library/Application Support/MobileSync/Backup"
    echo "=== iPhone Backups Cleanup (keep latest 1 only) ===" | tee -a "$REPORT"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "  iOS Backup directory not found: $backup_dir" | tee -a "$REPORT"
        return
    fi
    
    # バックアップディレクトリを新しい順に並べる
    local backups=($(find "$backup_dir" -mindepth 1 -maxdepth 1 -type d -exec stat -f "%m %N" {} \; 2>/dev/null | sort -nr | awk '{print $2}' || true))
    local total_count=${#backups[@]}
    local total_size=0
    
    echo "  Found $total_count backup directories" | tee -a "$REPORT"
    
    if [[ $total_count -le $KEEP_IOS_BACKUPS ]]; then
        echo "  Only $total_count backups found, nothing to delete" | tee -a "$REPORT"
        return
    fi
    
    local delete_count=$((total_count - KEEP_IOS_BACKUPS))
    echo "  Will delete $delete_count old backups, keeping $KEEP_IOS_BACKUPS" | tee -a "$REPORT"
    
    # 削除対象のサイズを計算
    for ((i=KEEP_IOS_BACKUPS; i<total_count; i++)); do
        local backup="${backups[i]}"
        local backup_size=$(get_size_mb "$backup")
        local backup_date=$(stat -f "%Sm" "$backup" 2>/dev/null || echo "Unknown")
        local backup_name=$(basename "$backup")
        echo "    Delete candidate: $backup_name ($backup_date) - ${backup_size} MB" | tee -a "$REPORT"
        total_size=$((total_size + backup_size))
    done
    
    local total_size_gb=$(echo "scale=2; $total_size / 1024" | bc -l 2>/dev/null || echo "0")
    echo "  Total size to delete: ${total_size} MB (${total_size_gb} GB)" | tee -a "$REPORT"
    echo "  Press Enter to continue with iPhone backup deletion, or Ctrl+C to cancel..."
    read
    
    # 実際の削除
    for ((i=KEEP_IOS_BACKUPS; i<total_count; i++)); do
        local backup="${backups[i]}"
        local backup_name=$(basename "$backup")
        if rm -rf "$backup" 2>/dev/null; then
            echo "    ✅ Deleted backup: $backup_name" | tee -a "$REPORT"
        else
            echo "    ❌ Failed to delete backup: $backup_name" | tee -a "$REPORT"
        fi
    done
    
    TOTAL_FREED_MB=$((TOTAL_FREED_MB + total_size))
    echo "" | tee -a "$REPORT"
}

# iOS Simulatorランタイム削除（iOS 18以外）
cleanup_simulator_runtimes() {
    local runtimes_dir="/Library/Developer/CoreSimulator/Profiles/Runtimes"
    echo "=== iOS Simulator Runtimes Cleanup (keep iOS $TARGET_IOS_MAJOR only) ===" | tee -a "$REPORT"
    
    if [[ ! -d "$runtimes_dir" ]]; then
        echo "  Simulator Runtimes directory not found: $runtimes_dir" | tee -a "$REPORT"
        return
    fi
    
    local total_size=0
    local delete_count=0
    
    echo "  Scanning simulator runtimes..." | tee -a "$REPORT"
    
    for runtime in "$runtimes_dir"/*; do
        if [[ -d "$runtime" ]]; then
            local runtime_name=$(basename "$runtime")
            echo "    Found runtime: $runtime_name" | tee -a "$REPORT"
            
            # iOS 18以外のものを削除対象とする
            if [[ ! "$runtime_name" =~ iOS.*$TARGET_IOS_MAJOR ]]; then
                local runtime_size=$(get_size_mb "$runtime")
                echo "      DELETE candidate: $runtime_name - ${runtime_size} MB" | tee -a "$REPORT"
                total_size=$((total_size + runtime_size))
                delete_count=$((delete_count + 1))
            else
                echo "      KEEP: $runtime_name (iOS $TARGET_IOS_MAJOR)" | tee -a "$REPORT"
            fi
        fi
    done
    
    if [[ $delete_count -eq 0 ]]; then
        echo "  No old runtimes to delete" | tee -a "$REPORT"
        return
    fi
    
    local total_size_gb=$(echo "scale=2; $total_size / 1024" | bc -l 2>/dev/null || echo "0")
    echo "  Will delete $delete_count runtimes, total size: ${total_size} MB (${total_size_gb} GB)" | tee -a "$REPORT"
    echo "  ⚠️  This operation requires sudo privileges" | tee -a "$REPORT"
    echo "  Press Enter to continue with runtime deletion, or Ctrl+C to cancel..."
    read
    
    # 実際の削除
    for runtime in "$runtimes_dir"/*; do
        if [[ -d "$runtime" ]]; then
            local runtime_name=$(basename "$runtime")
            if [[ ! "$runtime_name" =~ iOS.*$TARGET_IOS_MAJOR ]]; then
                if sudo rm -rf "$runtime" 2>/dev/null; then
                    echo "    ✅ Deleted runtime: $runtime_name" | tee -a "$REPORT"
                else
                    echo "    ❌ Failed to delete runtime: $runtime_name" | tee -a "$REPORT"
                fi
            fi
        fi
    done
    
    TOTAL_FREED_MB=$((TOTAL_FREED_MB + total_size))
    echo "" | tee -a "$REPORT"
}

# 古いXcode Archives削除（30日以上）
cleanup_old_archives() {
    local archives_dir="$HOME/Library/Developer/Xcode/Archives"
    echo "=== Old Xcode Archives Cleanup (older than $ARCHIVES_DAYS_OLD days) ===" | tee -a "$REPORT"
    
    if [[ ! -d "$archives_dir" ]]; then
        echo "  Archives directory not found: $archives_dir" | tee -a "$REPORT"
        return
    fi
    
    # 30日より古いアーカイブを検索
    local old_archives=($(find "$archives_dir" -name "*.xcarchive" -mtime +$ARCHIVES_DAYS_OLD -type d 2>/dev/null || true))
    local total_count=${#old_archives[@]}
    local total_size=0
    
    echo "  Found $total_count archives older than $ARCHIVES_DAYS_OLD days" | tee -a "$REPORT"
    
    if [[ $total_count -eq 0 ]]; then
        echo "  No old archives to delete" | tee -a "$REPORT"
        return
    fi
    
    # サイズ計算
    for archive in "${old_archives[@]}"; do
        local archive_size=$(get_size_mb "$archive")
        local archive_date=$(stat -f "%Sm" "$archive" 2>/dev/null || echo "Unknown")
        local archive_name=$(basename "$archive")
        echo "    Delete candidate: $archive_name ($archive_date) - ${archive_size} MB" | tee -a "$REPORT"
        total_size=$((total_size + archive_size))
    done
    
    local total_size_gb=$(echo "scale=2; $total_size / 1024" | bc -l 2>/dev/null || echo "0")
    echo "  Total size to delete: ${total_size} MB (${total_size_gb} GB)" | tee -a "$REPORT"
    echo "  Press Enter to continue with old archives deletion, or Ctrl+C to cancel..."
    read
    
    # 実際の削除
    for archive in "${old_archives[@]}"; do
        local archive_name=$(basename "$archive")
        if rm -rf "$archive" 2>/dev/null; then
            echo "    ✅ Deleted archive: $archive_name" | tee -a "$REPORT"
        else
            echo "    ❌ Failed to delete archive: $archive_name" | tee -a "$REPORT"
        fi
    done
    
    TOTAL_FREED_MB=$((TOTAL_FREED_MB + total_size))
    echo "" | tee -a "$REPORT"
}

# ユーザーキャッシュ大量削除
cleanup_large_caches() {
    echo "=== Large User Caches Cleanup ===" | tee -a "$REPORT"
    echo "  Analyzing cache directories..." | tee -a "$REPORT"
    
    # 主要なキャッシュディレクトリを特定
    local cache_dirs=(
        "$HOME/Library/Caches/com.apple.Safari"
        "$HOME/Library/Caches/Google/Chrome"
        "$HOME/Library/Caches/Google"
        "$HOME/Library/Caches/Homebrew" 
        "$HOME/Library/Caches/Mozilla"
        "$HOME/Library/Caches/com.apple.dt.Xcode"
        "$HOME/Library/Logs"
        "$HOME/Library/Application Support/CrashReporter"
    )
    
    local total_cache_size=0
    local delete_targets=()
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]]; then
            local cache_size=$(get_size_mb "$cache_dir")
            if [[ $cache_size -gt 10 ]]; then  # 10MB以上のみ対象
                echo "    Found cache: $(basename "$cache_dir") - ${cache_size} MB" | tee -a "$REPORT"
                total_cache_size=$((total_cache_size + cache_size))
                delete_targets+=("$cache_dir")
            fi
        fi
    done
    
    if [[ ${#delete_targets[@]} -eq 0 ]]; then
        echo "  No large cache directories found" | tee -a "$REPORT"
        return
    fi
    
    local total_cache_gb=$(echo "scale=2; $total_cache_size / 1024" | bc -l 2>/dev/null || echo "0")
    echo "  Total cache size to delete: ${total_cache_size} MB (${total_cache_gb} GB)" | tee -a "$REPORT"
    echo "  Press Enter to continue with cache deletion, or Ctrl+C to cancel..."
    read
    
    # 実際の削除
    for cache_dir in "${delete_targets[@]}"; do
        local cache_name=$(basename "$cache_dir")
        if rm -rf "$cache_dir" 2>/dev/null; then
            echo "    ✅ Deleted cache: $cache_name" | tee -a "$REPORT"
        else
            echo "    ❌ Failed to delete cache: $cache_name (permission issue)" | tee -a "$REPORT"
        fi
    done
    
    TOTAL_FREED_MB=$((TOTAL_FREED_MB + total_cache_size))
    echo "" | tee -a "$REPORT"
}

# ===== メイン処理開始 =====
TOTAL_FREED_MB=0

# 容量スナップショット（before）
BEFORE_AVAILABLE=$(check_disk_usage "BEFORE")

echo "=== 1) Time Machine Local Snapshots Thinning ===" | tee -a "$REPORT"
echo "  Command: sudo tmutil thinlocalsnapshots / 20000000000 4" | tee -a "$REPORT"
echo "  This will thin approximately 20GB of local snapshots" | tee -a "$REPORT"
echo "  ⚠️  This operation requires sudo privileges" | tee -a "$REPORT"
echo "  Press Enter to continue, or Ctrl+C to cancel..."
read

if sudo tmutil thinlocalsnapshots / 20000000000 4 2>/dev/null; then
    echo "    ✅ Time Machine snapshots thinned successfully" | tee -a "$REPORT"
    # TM thinning は正確なサイズが分からないので、概算で20GB分を加算
    TOTAL_FREED_MB=$((TOTAL_FREED_MB + 20480))  # 20GB = 20480MB
else
    echo "    ❌ Time Machine thinning failed or no snapshots to thin" | tee -a "$REPORT"
fi
echo "" | tee -a "$REPORT"

echo "=== 2) iPhone Backups Cleanup ===" | tee -a "$REPORT"
cleanup_ios_backups_final

echo "=== 3) iOS Simulator Runtimes Cleanup ===" | tee -a "$REPORT"
cleanup_simulator_runtimes

echo "=== 4) Old Xcode Archives Cleanup ===" | tee -a "$REPORT"
cleanup_old_archives

echo "=== 5) Large User Caches Cleanup ===" | tee -a "$REPORT"
cleanup_large_caches

echo "=== 6) Unavailable Simulators Cleanup ===" | tee -a "$REPORT"
echo "  Command: xcrun simctl delete unavailable" | tee -a "$REPORT"
if xcrun simctl delete unavailable 2>/dev/null; then
    echo "    ✅ Unavailable simulators deleted" | tee -a "$REPORT"
else
    echo "    ❌ Failed to delete unavailable simulators" | tee -a "$REPORT"
fi
echo "" | tee -a "$REPORT"

# 容量スナップショット（after）
AFTER_AVAILABLE=$(check_disk_usage "AFTER")

# 結果サマリー
echo "=== Final Cleanup Summary ===" | tee -a "$REPORT"
local freed_gb=$(echo "scale=2; $TOTAL_FREED_MB / 1024" | bc -l 2>/dev/null || echo "0")
local actual_freed_kb=$((AFTER_AVAILABLE - BEFORE_AVAILABLE))
local actual_freed_gb=$(echo "scale=2; $actual_freed_kb / 1024 / 1024" | bc -l 2>/dev/null || echo "0")

echo "Calculated freed space: $freed_gb GB ($TOTAL_FREED_MB MB)" | tee -a "$REPORT"
echo "Actual disk space change: $actual_freed_gb GB" | tee -a "$REPORT"
echo "Target was: +20 GB" | tee -a "$REPORT"

if (( $(echo "$actual_freed_gb >= 20" | bc -l) )); then
    echo "🎉 SUCCESS: Target achieved!" | tee -a "$REPORT"
elif (( $(echo "$actual_freed_gb >= 15" | bc -l) )); then
    echo "✅ Good result: Almost reached target" | tee -a "$REPORT"
else
    echo "📊 Partial success: Additional manual cleanup recommended" | tee -a "$REPORT"
fi

echo "Completed at: $(date)" | tee -a "$REPORT"

if [[ -f "$REPORT.errors" ]]; then
    echo "" | tee -a "$REPORT"
    echo "=== Deletion Errors ===" | tee -a "$REPORT"
    cat "$REPORT.errors" | tee -a "$REPORT"
    rm -f "$REPORT.errors"
fi

echo "" | tee -a "$REPORT"
echo "Report saved to: $REPORT" | tee -a "$REPORT"
echo ""
echo "🎯 Final cleanup completed!"
echo "📊 Freed: $freed_gb GB (calculated), $actual_freed_gb GB (actual)"
echo "📋 Report: $REPORT"

# レポートを開く
if command -v open >/dev/null 2>&1; then
    open "$REPORT"
fi