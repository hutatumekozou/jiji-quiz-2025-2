#!/bin/bash

# ===== Xcode/シミュレータ/SPMキャッシュの安全クリーンアップ =====
# 空き容量確保スクリプト

set -e

# ===== 設定 =====
PROJ_ROOT="/Users/kukkiiboy/Desktop/Claude code/8月4日O3XcodeTrans/jiji-quiz-2025-2/JijiQuiz2025"
REPORT="$HOME/Desktop/_DevCleanupReport_$(date +%Y%m%d_%H%M%S).txt"
KEEP_ARCHIVES_PER_APP=1      # 各アプリの最新 .xcarchive は1件残す
KEEP_IPA_DIRS=1              # プロジェクト内 ipa_output などは最新1件だけ残す
TARGET_IOS_MAJOR="18"        # iOS DeviceSupport は iOS 18.* を温存（他は削除）
DRY_RUN=false                # true にすると削除せず候補だけ列挙

# ===== 初期化 =====
echo "=== Xcode/Simulator/SPM Cache Cleanup Script ===" | tee "$REPORT"
echo "Started at: $(date)" | tee -a "$REPORT"
echo "Project root: $PROJ_ROOT" | tee -a "$REPORT"
echo "DRY_RUN: $DRY_RUN" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ===== 関数定義 =====

# 容量チェック関数
check_disk_usage() {
    local label="$1"
    echo "=== Disk Usage ($label) ===" | tee -a "$REPORT"
    df -h / | tee -a "$REPORT"
    echo "" | tee -a "$REPORT"
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

# 削除実行関数
safe_remove() {
    local path="$1"
    local description="$2"
    local size_mb=$(get_size_mb "$path")
    
    if [[ ! -e "$path" ]]; then
        echo "  SKIP: $description (not found)" | tee -a "$REPORT"
        return 0
    fi
    
    echo "  Target: $description" | tee -a "$REPORT"
    echo "    Path: $path" | tee -a "$REPORT"
    echo "    Size: ${size_mb} MB" | tee -a "$REPORT"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "    [DRY RUN] Would delete" | tee -a "$REPORT"
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

# アーカイブ整理関数
cleanup_archives() {
    local archives_dir="$HOME/Library/Developer/Xcode/Archives"
    echo "=== Cleaning Archives (keep latest $KEEP_ARCHIVES_PER_APP per app) ===" | tee -a "$REPORT"
    
    if [[ ! -d "$archives_dir" ]]; then
        echo "  Archives directory not found: $archives_dir" | tee -a "$REPORT"
        return
    fi
    
    # 日付ごとのディレクトリを探す
    for date_dir in "$archives_dir"/*; do
        if [[ -d "$date_dir" ]]; then
            echo "  Checking date directory: $(basename "$date_dir")" | tee -a "$REPORT"
            
            # アプリ名ごとにグループ化して古いものを削除
            local app_names=($(find "$date_dir" -name "*.xcarchive" -exec basename {} .xcarchive \; | sed 's/ [0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9].[0-9][0-9].[0-9][0-9]$//' | sort -u))
            
            for app_name in "${app_names[@]}"; do
                if [[ -n "$app_name" ]]; then
                    echo "    App: $app_name" | tee -a "$REPORT"
                    
                    # このアプリの全アーカイブを新しい順に並べる
                    local archives=($(find "$date_dir" -name "${app_name}*.xcarchive" -print0 | xargs -0 ls -1t))
                    local count=0
                    
                    for archive in "${archives[@]}"; do
                        count=$((count + 1))
                        if [[ $count -gt $KEEP_ARCHIVES_PER_APP ]]; then
                            safe_remove "$archive" "Old archive for $app_name (#$count)"
                        else
                            echo "      KEEP: $(basename "$archive") (latest #$count)" | tee -a "$REPORT"
                        fi
                    done
                fi
            done
        fi
    done
}

# プロジェクト内IPA掃除
cleanup_project_ipa() {
    echo "=== Cleaning Project IPA/Archive outputs ===" | tee -a "$REPORT"
    
    if [[ ! -d "$PROJ_ROOT" ]]; then
        echo "  Project root not found: $PROJ_ROOT" | tee -a "$REPORT"
        return
    fi
    
    # ipa, ipa_output, archive を含むディレクトリを検索
    local ipa_dirs=($(find "$PROJ_ROOT" -type d \( -name "*ipa*" -o -name "*archive*" \) 2>/dev/null | sort))
    
    for ipa_dir in "${ipa_dirs[@]}"; do
        if [[ -d "$ipa_dir" ]]; then
            local dir_size=$(get_size_mb "$ipa_dir")
            if [[ $dir_size -gt 10 ]]; then  # 10MB以上のみ対象
                echo "  Found IPA/Archive dir: $ipa_dir (${dir_size} MB)" | tee -a "$REPORT"
                
                # ディレクトリ内のファイルを新しい順に並べ、古いものを削除
                local files=($(find "$ipa_dir" -type f -name "*.ipa" -o -name "*.xcarchive" | xargs ls -1t 2>/dev/null || true))
                local count=0
                
                for file in "${files[@]}"; do
                    count=$((count + 1))
                    if [[ $count -gt $KEEP_IPA_DIRS ]]; then
                        safe_remove "$file" "Old IPA/archive file (#$count)"
                    else
                        echo "    KEEP: $(basename "$file") (latest #$count)" | tee -a "$REPORT"
                    fi
                done
            fi
        fi
    done
}

# iOS DeviceSupport クリーンアップ
cleanup_device_support() {
    local device_support_dir="$HOME/Library/Developer/Xcode/iOS DeviceSupport"
    echo "=== Cleaning iOS DeviceSupport (keep iOS $TARGET_IOS_MAJOR.*) ===" | tee -a "$REPORT"
    
    if [[ ! -d "$device_support_dir" ]]; then
        echo "  iOS DeviceSupport directory not found" | tee -a "$REPORT"
        return
    fi
    
    for ios_version_dir in "$device_support_dir"/*; do
        if [[ -d "$ios_version_dir" ]]; then
            local version_name=$(basename "$ios_version_dir")
            if [[ ! "$version_name" =~ ^$TARGET_IOS_MAJOR\. ]]; then
                safe_remove "$ios_version_dir" "Old iOS DeviceSupport: $version_name"
            else
                echo "  KEEP: $version_name (target iOS version)" | tee -a "$REPORT"
            fi
        fi
    done
}

# ===== メイン処理開始 =====
TOTAL_FREED_MB=0

# 1) 容量スナップショット（before）
check_disk_usage "BEFORE"

# 2) 削除候補の抽出＆削除実行

echo "=== Xcode DerivedData ===" | tee -a "$REPORT"
safe_remove "$HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData (全削除)"

echo "=== SPM Caches ===" | tee -a "$REPORT"
safe_remove "$HOME/Library/Caches/org.swift.swiftpm" "Swift Package Manager Cache"

echo "=== Xcode Caches ===" | tee -a "$REPORT"
for cache_dir in "$HOME"/Library/Caches/com.apple.dt.Xcode*; do
    if [[ -d "$cache_dir" ]]; then
        safe_remove "$cache_dir" "Xcode Cache: $(basename "$cache_dir")"
    fi
done

echo "=== CoreSimulator Caches ===" | tee -a "$REPORT"
safe_remove "$HOME/Library/Developer/CoreSimulator/Caches" "CoreSimulator Caches"

echo "=== Simulator Cleanup ===" | tee -a "$REPORT"
echo "  Running: xcrun simctl delete unavailable" | tee -a "$REPORT"
if [[ "$DRY_RUN" == "false" ]]; then
    xcrun simctl delete unavailable 2>/dev/null || echo "    Warning: simctl delete failed" | tee -a "$REPORT"
    echo "    ✅ Unavailable simulators deleted" | tee -a "$REPORT"
else
    echo "    [DRY RUN] Would run simctl delete unavailable" | tee -a "$REPORT"
fi
echo "" | tee -a "$REPORT"

# アーカイブとプロジェクトIPA の整理
cleanup_archives
cleanup_project_ipa
cleanup_device_support

# 3) 容量スナップショット（after）
check_disk_usage "AFTER"

# 4) 結果サマリー
echo "=== Cleanup Summary ===" | tee -a "$REPORT"
echo "Total freed space: $((TOTAL_FREED_MB / 1024)) GB ($TOTAL_FREED_MB MB)" | tee -a "$REPORT"
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
echo "🎉 Cleanup completed!"
echo "📊 Freed: $((TOTAL_FREED_MB / 1024)) GB"
echo "📋 Report: $REPORT"