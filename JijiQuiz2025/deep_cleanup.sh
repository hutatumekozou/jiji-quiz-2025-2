#!/bin/bash

# ===== 攻めのディスククリーンアップ - +20GB目標 =====

set -e

# ===== 設定 =====
PROJ_ROOT="/Users/kukkiiboy/Desktop/Claude code/8月4日O3XcodeTrans/jiji-quiz-2025-2/JijiQuiz2025"
REPORT="$HOME/Desktop/_DeepCleanupReport_$(date +%Y%m%d_%H%M%S).txt"

# 残す数（多く残したいなら増やす）
KEEP_ARCHIVES_PER_APP=1          # Xcode Archives は各App最新1件だけ残す
KEEP_IPA_DIRS=1                  # プロジェクト内の ipa 出力は最新1件だけ残す
KEEP_IOS_BACKUPS=1               # iPhone バックアップは最新1つだけ残す

# iOS DeviceSupport は"メジャー最新"を残す（例：18.*）他は削除
TARGET_IOS_MAJOR="18"

# 追加クリーンのON/OFF
CLEAN_BREW=true                  # Homebrew の古いバイナリ/キャッシュ削除
CLEAN_NPM=true                   # npm/yarn のキャッシュ削除
CLEAN_PIP=true                   # pip キャッシュ削除
CLEAN_DOCKER=false               # Docker を使っているなら true（イメージ全消し注意）
CLEAN_SIMULATOR_HARD=true        # 使ってないシミュレータ/ランタイムを徹底削除
CLEAN_DEVICE_LOGS=true           # iOSデバイス/クラッシュログ削除

# Time Machine ローカルスナップショットを"薄める"（sudoが必要）
THIN_TM_SNAPSHOTS=true
THIN_TM_BYTES="20000000000"      # 20GB 分を目安にスリム化

DRY_RUN=false                    # trueなら削除せず計測のみ

# ===== 初期化 =====
echo "=== 攻めのディスククリーンアップ - +20GB 目標 ===" | tee "$REPORT"
echo "Started at: $(date)" | tee -a "$REPORT"
echo "Project root: $PROJ_ROOT" | tee -a "$REPORT"
echo "DRY_RUN: $DRY_RUN" | tee -a "$REPORT"
echo "Target: +20GB free space" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ===== 関数定義 =====

# 容量チェック関数
check_disk_usage() {
    local label="$1"
    echo "=== Disk Usage ($label) ===" | tee -a "$REPORT"
    df -h / | tee -a "$REPORT"
    local available=$(df / | tail -1 | awk '{print $4}')
    echo "Available blocks: $available" | tee -a "$REPORT"
    echo "" | tee -a "$REPORT"
    echo "$available"
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

# サイズ計算関数（GB単位での表示用）
get_size_gb() {
    local path="$1"
    local size_mb=$(get_size_mb "$path")
    echo "scale=2; $size_mb / 1024" | bc -l 2>/dev/null || echo "0"
}

# 削除実行関数
safe_remove() {
    local path="$1"
    local description="$2"
    local size_mb=$(get_size_mb "$path")
    local size_gb=$(echo "scale=2; $size_mb / 1024" | bc -l 2>/dev/null || echo "0")
    
    if [[ ! -e "$path" ]]; then
        echo "  SKIP: $description (not found)" | tee -a "$REPORT"
        return 0
    fi
    
    echo "  Target: $description" | tee -a "$REPORT"
    echo "    Path: $path" | tee -a "$REPORT"
    echo "    Size: ${size_mb} MB (${size_gb} GB)" | tee -a "$REPORT"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "    [DRY RUN] Would delete" | tee -a "$REPORT"
        TOTAL_FREED_MB=$((TOTAL_FREED_MB + size_mb))
    else
        if rm -rf "$path" 2>/dev/null; then
            echo "    ✅ Deleted successfully" | tee -a "$REPORT"
            TOTAL_FREED_MB=$((TOTAL_FREED_MB + size_mb))
        else
            echo "    ❌ Failed to delete (permission/access issue)" | tee -a "$REPORT"
            echo "      - $path" >> "$REPORT.errors"
        fi
    fi
    echo "" | tee -a "$REPORT"
}

# コマンド実行関数
safe_command() {
    local cmd="$1"
    local description="$2"
    
    echo "  Executing: $description" | tee -a "$REPORT"
    echo "    Command: $cmd" | tee -a "$REPORT"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "    [DRY RUN] Would execute" | tee -a "$REPORT"
    else
        if eval "$cmd" 2>/dev/null; then
            echo "    ✅ Command executed successfully" | tee -a "$REPORT"
        else
            echo "    ❌ Command failed" | tee -a "$REPORT"
            echo "      - $cmd" >> "$REPORT.errors"
        fi
    fi
    echo "" | tee -a "$REPORT"
}

# iPhone バックアップ整理
cleanup_ios_backups() {
    local backup_dir="$HOME/Library/Application Support/MobileSync/Backup"
    echo "=== Cleaning iOS Backups (keep latest $KEEP_IOS_BACKUPS) ===" | tee -a "$REPORT"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "  iOS Backup directory not found: $backup_dir" | tee -a "$REPORT"
        return
    fi
    
    # バックアップディレクトリを新しい順に並べる
    local backups=($(find "$backup_dir" -mindepth 1 -maxdepth 1 -type d -exec stat -f "%m %N" {} \; | sort -nr | awk '{print $2}'))
    local count=0
    
    echo "  Found ${#backups[@]} backup directories" | tee -a "$REPORT"
    
    for backup in "${backups[@]}"; do
        count=$((count + 1))
        local backup_name=$(basename "$backup")
        local backup_size=$(get_size_mb "$backup")
        local backup_date=$(stat -f "%Sm" "$backup" 2>/dev/null || echo "Unknown")
        
        if [[ $count -gt $KEEP_IOS_BACKUPS ]]; then
            echo "  Backup #$count: $backup_name (${backup_date}) - ${backup_size} MB - DELETING" | tee -a "$REPORT"
            safe_remove "$backup" "iOS Backup #$count: $backup_name"
        else
            echo "  KEEP Backup #$count: $backup_name (${backup_date}) - ${backup_size} MB" | tee -a "$REPORT"
        fi
    done
}

# シミュレータ徹底掃除
cleanup_simulator_hard() {
    echo "=== Hard Simulator Cleanup ===" | tee -a "$REPORT"
    
    # 無効なシミュレータを削除
    safe_command "xcrun simctl delete unavailable" "Delete unavailable simulators"
    
    # シミュレータのキャッシュとログを削除
    local simulator_dir="$HOME/Library/Developer/CoreSimulator"
    if [[ -d "$simulator_dir" ]]; then
        # 各デバイスのキャッシュ/一時ファイル/ログを削除
        for device_dir in "$simulator_dir/Devices"/*; do
            if [[ -d "$device_dir" ]]; then
                local device_name=$(basename "$device_dir")
                echo "  Cleaning device: $device_name" | tee -a "$REPORT"
                
                for cleanup_path in "data/Library/Caches" "data/tmp" "data/Library/Logs"; do
                    local full_path="$device_dir/$cleanup_path"
                    if [[ -d "$full_path" ]]; then
                        safe_remove "$full_path" "Simulator device cache: $device_name/$cleanup_path"
                    fi
                done
            fi
        done
        
        # CoreSimulator全体のキャッシュ
        for cache_dir in "$simulator_dir/Caches" "$simulator_dir/Logs"; do
            if [[ -d "$cache_dir" ]]; then
                safe_remove "$cache_dir" "CoreSimulator cache: $(basename "$cache_dir")"
            fi
        done
    fi
}

# Time Machine スナップショット整理
thin_tm_snapshots() {
    echo "=== Time Machine Snapshot Thinning ===" | tee -a "$REPORT"
    
    if [[ "$THIN_TM_SNAPSHOTS" != "true" ]]; then
        echo "  SKIP: Time Machine thinning disabled" | tee -a "$REPORT"
        return
    fi
    
    echo "  Listing current snapshots..." | tee -a "$REPORT"
    snapshots=$(tmutil listlocalsnapshots / 2>/dev/null | grep -E "com.apple.TimeMachine" || true)
    
    if [[ -z "$snapshots" ]]; then
        echo "  No Time Machine snapshots found" | tee -a "$REPORT"
        return
    fi
    
    echo "  Found snapshots:" | tee -a "$REPORT"
    echo "$snapshots" | tee -a "$REPORT"
    
    snapshot_count=$(echo "$snapshots" | wc -l | tr -d ' ')
    echo "  Total snapshots: $snapshot_count" | tee -a "$REPORT"
    
    if [[ $snapshot_count -gt 3 ]]; then
        thin_count=$((snapshot_count - 2))  # 最新2個を残す
        echo "  Attempting to thin $thin_count snapshots..." | tee -a "$REPORT"
        
        if [[ "$DRY_RUN" == "false" ]]; then
            # 古いスナップショットから順に削除を試行
            echo "$snapshots" | head -n $thin_count | while read snapshot; do
                if [[ -n "$snapshot" ]]; then
                    echo "    Trying to delete: $snapshot" | tee -a "$REPORT"
                    sudo tmutil deletelocalsnapshots "$snapshot" 2>/dev/null || echo "      Failed to delete snapshot" | tee -a "$REPORT"
                fi
            done
        else
            echo "    [DRY RUN] Would attempt to delete $thin_count snapshots" | tee -a "$REPORT"
        fi
    else
        echo "  Only $snapshot_count snapshots found, skipping thinning" | tee -a "$REPORT"
    fi
    echo "" | tee -a "$REPORT"
}

# ===== メイン処理開始 =====
TOTAL_FREED_MB=0

# 容量スナップショット（before）
BEFORE_AVAILABLE=$(check_disk_usage "BEFORE")

echo "=== [A] Xcode派生物 (再度) ===" | tee -a "$REPORT"
safe_remove "$HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData (全削除)"

# iOS Device Logs
if [[ "$CLEAN_DEVICE_LOGS" == "true" ]]; then
    safe_remove "$HOME/Library/Developer/Xcode/iOS Device Logs" "iOS Device Logs"
fi

# Archives整理（前回のスクリプトにも含まれているが再実行）
archives_dir="$HOME/Library/Developer/Xcode/Archives"
if [[ -d "$archives_dir" ]]; then
    echo "=== Xcode Archives Cleanup ===" | tee -a "$REPORT"
    for date_dir in "$archives_dir"/*; do
        if [[ -d "$date_dir" ]]; then
            echo "  Processing date directory: $(basename "$date_dir")" | tee -a "$REPORT"
            archive_files=($(find "$date_dir" -name "*.xcarchive" -exec stat -f "%m %N" {} \; | sort -nr | awk '{print $2}'))
            count=0
            
            for archive in "${archive_files[@]}"; do
                count=$((count + 1))
                if [[ $count -gt $KEEP_ARCHIVES_PER_APP ]]; then
                    safe_remove "$archive" "Old Xcode Archive #$count"
                else
                    echo "    KEEP: $(basename "$archive") (latest #$count)" | tee -a "$REPORT"
                fi
            done
        fi
    done
fi

echo "=== [B] Swift Package / CocoaPods / Carthage ===" | tee -a "$REPORT"
safe_remove "$HOME/Library/Caches/org.swift.swiftpm" "Swift Package Manager Cache"
safe_remove "$HOME/.swiftpm" "Swift Package Manager Local"
safe_remove "$HOME/Library/Caches/CocoaPods" "CocoaPods Cache"
safe_remove "$HOME/Library/Caches/org.carthage.CarthageKit" "Carthage Cache"
safe_remove "$HOME/Library/Caches/carthage" "Carthage Cache (alt)"

echo "=== [C] Simulator Hard Cleanup ===" | tee -a "$REPORT"
if [[ "$CLEAN_SIMULATOR_HARD" == "true" ]]; then
    cleanup_simulator_hard
else
    echo "  SKIP: Hard simulator cleanup disabled" | tee -a "$REPORT"
fi

echo "=== [D] iPhone Backups ===" | tee -a "$REPORT"
cleanup_ios_backups

echo "=== [E] Package Managers ===" | tee -a "$REPORT"

if [[ "$CLEAN_BREW" == "true" ]] && command -v brew >/dev/null 2>&1; then
    safe_command "brew cleanup -s" "Homebrew cleanup (remove old versions)"
    safe_command "brew autoremove" "Homebrew autoremove (unused dependencies)"
    safe_remove "$HOME/Library/Caches/Homebrew" "Homebrew cache directory"
fi

if [[ "$CLEAN_NPM" == "true" ]]; then
    if command -v npm >/dev/null 2>&1; then
        safe_command "npm cache clean --force" "NPM cache clean"
    fi
    safe_remove "$HOME/.npm" "NPM local cache"
    safe_remove "$HOME/Library/Caches/Yarn" "Yarn cache"
    safe_remove "$HOME/Library/Caches/npm" "NPM cache directory"
fi

if [[ "$CLEAN_PIP" == "true" ]]; then
    safe_remove "$HOME/Library/Caches/pip" "PIP cache"
    safe_remove "$HOME/.cache/pip" "PIP cache (alt location)"
fi

if [[ "$CLEAN_DOCKER" == "true" ]] && command -v docker >/dev/null 2>&1; then
    echo "  WARNING: Docker cleanup will remove ALL images and volumes!" | tee -a "$REPORT"
    safe_command "docker system prune -af --volumes" "Docker system prune (ALL data)"
fi

echo "=== [F] Project Heavy Build Outputs ===" | tee -a "$REPORT"
if [[ -d "$PROJ_ROOT" ]]; then
    # ipa, archive, build 関連ディレクトリの整理
    heavy_dirs=($(find "$PROJ_ROOT" -type d \( -name "*ipa*" -o -name "*archive*" -o -name "*build*" -o -name "DerivedData" \) -mindepth 1 2>/dev/null | sort))
    
    for heavy_dir in "${heavy_dirs[@]}"; do
        dir_size=$(get_size_mb "$heavy_dir")
        if [[ $dir_size -gt 50 ]]; then  # 50MB以上のみ対象
            echo "  Found heavy directory: $heavy_dir (${dir_size} MB)" | tee -a "$REPORT"
            
            # .ipa, .app, .dSYM など重いファイルを新しい順に並べ、古いものを削除
            heavy_files=($(find "$heavy_dir" -type f \( -name "*.ipa" -o -name "*.app" -o -name "*.dSYM" \) -exec stat -f "%m %N" {} \; 2>/dev/null | sort -nr | awk '{print $2}'))
            count=0
            
            for file in "${heavy_files[@]}"; do
                count=$((count + 1))
                if [[ $count -gt $KEEP_IPA_DIRS ]]; then
                    safe_remove "$file" "Old build output #$count: $(basename "$file")"
                else
                    echo "    KEEP: $(basename "$file") (latest #$count)" | tee -a "$REPORT"
                fi
            done
        fi
    done
fi

echo "=== [G] Time Machine Snapshots ===" | tee -a "$REPORT"
thin_tm_snapshots

# 追加の重いキャッシュディレクトリ
echo "=== Additional Cache Cleanup ===" | tee -a "$REPORT"
safe_remove "$HOME/Library/Caches/com.apple.Safari" "Safari Cache"
safe_remove "$HOME/Library/Caches/Google" "Google Chrome Cache"
safe_remove "$HOME/Library/Caches/Mozilla" "Firefox Cache"
safe_remove "$HOME/Library/Application Support/CrashReporter" "Crash Reporter Logs"
safe_remove "$HOME/Library/Logs" "User Log Files"

# 容量スナップショット（after）
AFTER_AVAILABLE=$(check_disk_usage "AFTER")

# 結果サマリー
echo "=== Deep Cleanup Summary ===" | tee -a "$REPORT"
freed_gb=$(echo "scale=2; $TOTAL_FREED_MB / 1024" | bc -l 2>/dev/null || echo "0")
actual_freed=$((AFTER_AVAILABLE - BEFORE_AVAILABLE))
actual_freed_gb=$(echo "scale=2; $actual_freed / 1024 / 1024" | bc -l 2>/dev/null || echo "0")

echo "Calculated freed space: $freed_gb GB ($TOTAL_FREED_MB MB)" | tee -a "$REPORT"
echo "Actual disk space change: $actual_freed_gb GB" | tee -a "$REPORT"
echo "Target was: +20 GB" | tee -a "$REPORT"

if (( $(echo "$freed_gb >= 20" | bc -l) )); then
    echo "🎉 SUCCESS: Target achieved!" | tee -a "$REPORT"
else
    echo "📊 Partial success. Consider additional cleanup:" | tee -a "$REPORT"
    echo "  - Check ~/Downloads for large files" | tee -a "$REPORT"
    echo "  - Clean up ~/Desktop and ~/Documents" | tee -a "$REPORT"
    echo "  - Review ~/Pictures and ~/Movies" | tee -a "$REPORT"
fi

echo "Completed at: $(date)" | tee -a "$REPORT"

if [[ -f "$REPORT.errors" ]]; then
    echo "" | tee -a "$REPORT"
    echo "=== Deletion/Command Errors ===" | tee -a "$REPORT"
    cat "$REPORT.errors" | tee -a "$REPORT"
    rm -f "$REPORT.errors"
fi

echo "" | tee -a "$REPORT"
echo "Report saved to: $REPORT" | tee -a "$REPORT"
echo ""
echo "🚀 Deep cleanup completed!"
echo "📊 Freed: $freed_gb GB"
echo "📋 Report: $REPORT"

# レポートを開く
if command -v open >/dev/null 2>&1; then
    open "$REPORT"
fi