# ReCoDAI-LUC Scientific Image Forgery Detection — Agents Guide

## Overview
- Goal: 判定対象画像が「authentic」か、コピー＆移動による改ざん領域（1枚以上のマスク）を検出して提出します。
- Score: 公式メトリクスは oF1（Optimal F1）。複数マスク間の最適対応をハンガリアン法で求め、余剰予測にペナルティを付与します。
- Submission: カラムは `case_id, annotation`。
  - authentic: 文字列 `authentic`。
  - forged: RLE を JSON 配列で表し、インスタンスごとに `;` で連結した1つの文字列にします（例: "[start1, len1, start2, len2];[startA, lenA]"）。
- RLE rules: 列優先（転置後フラット）、1ベースの開始、正の長さ、開始の昇順、同一配列内で走長が重ならない（非重複）。

## Workspace Map
- [analysis/reports/scientific-forensics-dinov2-cnn-ipynb.ipynb](analysis/reports/scientific-forensics-dinov2-cnn-ipynb.ipynb)
  - 主要ノートブック。DINOv2 エンコーダ + デコーダ（Tiny/Mask2Former風）の推論・可視化・提出生成。
  - Kaggle/Colab 環境切替、`pipeline_final()` による最終判定、`submission.csv` 保存。
- [analysis/reports/recodai-f1.ipynb](analysis/reports/recodai-f1.ipynb)
  - 公式メトリクス互換ユーティリティ（RLE encode/decode、oF1 計算）と検証例。
- [contexts/overview.md](contexts/overview.md), [contexts/data.md](contexts/data.md)
  - 問題背景やデータ仕様のメモ。
- [docs/diary.md](docs/diary.md), [analysis/research_summary_template.md](analysis/research_summary_template.md)
  - リサーチの記録・要約テンプレート。
- [prompts/](prompts/)
  - Kaggle 調査やワークフロー用プロンプト。
- ルート構成物: [requirements.txt](requirements.txt), [Dockerfile](Dockerfile), [compose.yaml](compose.yaml), [run.sh](run.sh)
  - 依存・コンテナ設定（Notebookベース開発が中心のため必要に応じて使用）。

## Key Pipelines & Utilities
- Inference: `pipeline_final(pil)`（scientific-forensics ノート）
  - TTA オプション → 統一版 `adaptive_mask()`（alpha=0.45） → 面積/内部平均に基づく forged/authentic 判定。
  - forged の場合はマスクを返し、提出の RLE 生成へ。
- Submission:
  - `rle_encode_submission(masks)` で空/None を自動スキップ、非空のみ `;` 連結。0件なら `authentic`。
  - `sanitize_annotation_str(s)` で空要素・体裁不正（奇数長、昇順違反、重なり）を除去し、皆無なら `authentic` に統一。
- Validation:
  - `evaluate_mean_oF1(val_forg, val_auth)`（scientific-forensics ノート末尾）。
  - authentic は厳密一致、forged は GT/予測ともにインスタンス分割後 oF1 を計算。

## Official Metric (oF1) Essentials
- Instance-aware: 複数マスクを前提に、予測↔GT の最適一対一対応で F1 を平均化。
- Excess penalty: 予測過多にペナルティ（`len(gt)/max(len(pred), len(gt))`）。
- Practical tips:
  - 単一 2値マスク出力でも提出前に連結成分で分割してインスタンス化する方が整合的。
  - バリデーションの主指標は oF1 に揃え、学習過程の高速モニタ用にピクセル F1 を併用可。

## Submission Spec
- CSV ヘッダ: `case_id,annotation`。
- authentic: `authentic`（空配列や空要素 `[]` は提出しない）。
- forged: 例 — "[190, 592, 1394, 98];[1653, 98]"（各配列は非重複の走長ペア、開始は昇順）。
- Sanity checks:
  - 空要素・奇数長・長さ<=0・昇順違反・同一配列内の重なりを除外。
  - CSV 保存直前に `final['annotation'] = final['annotation'].apply(sanitize_annotation_str)` を推奨。

## Environment Notes
- Kaggle vs Colab 自動判定（ノート内 `IS_KAGGLE`, `IS_COLAB`）。
- DINOv2 ロード: Kaggle はローカルパス、Colab は HF ID（facebook/dinov2-base）。`local_files_only` 切替あり。
- Drive/W&B: Colab の Drive 永続化、W&B ログインは任意。

## Agent Playbook
- First 5 actions:
  1. 競技仕様の再確認（RLE/annotation・oF1・authentic 取り扱い）。
  2. ノートブックを開き、環境検出とパスの妥当性を確認（Kaggle/Colab）。
  3. `pipeline_final()` の閾値と `adaptive_mask()` の alpha を統一（既定 0.45）。
  4. 小さなバリデーションセットで `evaluate_mean_oF1()` を実行し、提出整合性を確認。
  5. テスト画像で `submission.csv` を生成し、サニタイズ＆簡易復号検査を実施。

## Quick Checks
- インスタンス分割: 2D マスクは `cv2.connectedComponents` で分割、3D はチャネルごと。
- RLE 復号テスト（複数配列）: `annotation.split(';')` で各 JSON を個別に `rle_decode(json, (H, W))`。
- 代表的な不正例: `[]`、奇数長配列、`starts` の降順混入、同一配列内の走長重なり（復号でエラー）。

## Links & References
- 公式 RLE 実装の参考: [analysis/reports/recodai-f1.ipynb](analysis/reports/recodai-f1.ipynb)
- 主要ワークフロー: [analysis/reports/scientific-forensics-dinov2-cnn-ipynb.ipynb](analysis/reports/scientific-forensics-dinov2-cnn-ipynb.ipynb)

---
本ガイドはエージェントがディレクトリ構造と競技要件を素早く把握し、検証・提出までを安全に進めるための要点をまとめています。必要に応じて、提出セルへサニタイズ処理の適用を組み込み、公式メトリクス（oF1）での検証を基準にモデル選択を行ってください。
