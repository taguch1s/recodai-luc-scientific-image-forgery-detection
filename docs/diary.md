https://www.kaggle.com/competitions/recodai-luc-scientific-image-forgery-detection

### 2025/01/04

読み始めた

```
Overview
Scientific images are central to published research, but not all of them are honest. Help protect science from fraudulent image manipulation by building models that can detect and segment copy-move forgeries in biomedical images.

Description
Every chart, figure, and microscope slide in a scientific paper tells a story. But today, that story may be fake. Copy-move forgery—where regions of an image are duplicated to fabricate results—is one of the most common and damaging types of scientific misconduct. These forgeries can mislead researchers, waste time and funding, and undermine trust in entire fields of study.

Most detection still relies on expert reviewers manually scanning papers, or on digital forensics tools that weren’t built with scientific figures in mind. Both approaches fall short in biomedical research. Manual review is slow and impossible to scale, and most automated detectors struggle to cope with the complexity of scientific figures. What’s missing is a tool built specifically for this domain.

In this competition, you’ll develop models that detect and segment copy-move forgeries in biomedical images. The benchmark is based on several hundred confirmed forgeries pulled from more than 2,000 retracted papers, making it one of the most realistic and detailed datasets in scientific image forensics. You’ll be evaluated on how well your model finds and separates copied regions at the pixel level.

If successful, your work won’t just flag suspicious figures. It could help reshape the way journals, reviewers, and institutions verify published science by detecting misconduct before it spreads.

Let’s keep science honest, one pixel at a time.

Evaluation
This competition uses a variant of the F1 score as the metric. See this notebook for implementation details and for the official run length encoding and decoding functions.

Submission File
You must create a row in the submission file for each image. For images that do not contain a copy-move forgery predict the string "authentic". For all others submit run length encoded masks as serialized using the rle_encode function in the metric. The file should contain a header and have the following format:

case_id,annotation
1,authentic
2,"[123 4]"
```

- f1 scoreをmetricとして扱っている
- segmentを算出するためのスクリプトがあるらしい？
  - https://www.kaggle.com/code/metric/recodai-f1/
  - 眺めたがよくわからん
- demo EDA 読んで理解を深める
  - https://www.kaggle.com/code/antonoof/eda-r-cnn-model
  - train_maskって何?
    ```
    Dataset Description
    Your challenge is to identify duplicated regions within biomedical research imaging.

    Competition Phases and Data Updates
    The competition will proceed in two phases:

    A model training phase with a public leaderboard test set of roughly 1,100 images. Because these images are from publicly available research papers leaderboard scores during this phase are not meaningful.
    A forecasting phase will add a private leaderboard test set to be collected after submissions close. Expect the additional images to roughly double the size of the test set.
    Files
    [train/test]_images/ The images to be analyzed.
    train_masks/ Annotations for the train set. Some images have multiple duplicated regions and so multiple masks.
    supplemental_images Additional train set images provided after the launch of the competition. supplemental_masks Additional train set masks provided after the launch of the competition. sample_submission.csv A sample submission in the correct format.

    case_id
    annotation - One of authentic or a run length encoded mask.
    ```
    > 目的: train_masksは学習用の正解データ（ピクセル単位のセグメンテーションラベル）で、画像内の「コピー＆ムーブ（重複）された領域」を示します。
  - torchvision.models.mobilenet_v3_small ?
    - 軽量CNN: モバイル/エッジ向けに設計された効率特化の畳み込みネットワーク。
  - AnchorGenerator, ops.MultiScaleRoIAlign のあたり
    - https://tanalib.com/faster-rcnn-anchor/
    - feature抽出のためにanchor boxを作成できる
    - 抽出後の特徴量領域をから関心領域*(RoI)を取り出す -> MultiScaleRoIAlign みたいな感じぽい
