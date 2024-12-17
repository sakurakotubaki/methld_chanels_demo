# Weight Scale Implementation Documentation

## Overview
この文書では、FlutterアプリケーションでiOSとAndroidのネイティブコードと連携して体重計シミュレーションを実装する方法について説明します。

## 実装アーキテクチャ
実装は以下の3つの主要コンポーネントで構成されています：

1. Flutterフロントエンド（Stream処理）
2. iOSネイティブコード（Swift）
3. Androidネイティブコード（Kotlin）

## Native Implementation Details

### Swift (iOS)
```swift
class AppDelegate: FlutterAppDelegate {
    private let METHOD_CHANNEL = "com.jboycode/weight_scale/method"
    private let EVENT_CHANNEL = "com.jboycode/weight_scale/event"
    private var weightTimer: Timer?
    private var isScaleOn = false
    private var currentWeight = 60.0
    private var isIncreasing = true
    var eventSink: FlutterEventSink?
}
```

#### 主要コンポーネント
1. **Method Channel**: 体重計のON/OFF制御
    - `toggleScale` メソッドを実装
    - Flutterからの制御コマンドを受信

2. **Event Channel**: 体重データのストリーミング
    - `WeightStreamHandler` クラスで実装
    - 定期的なデータ送信をハンドリング

3. **Timer**: データシミュレーション
    - 1秒間隔でデータを生成
    - 50kg～70kgの範囲で値を変動

### Kotlin (Android)
```kotlin
class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "com.jboycode/weight_scale/method"
    private val EVENT_CHANNEL = "com.jboycode/weight_scale/event"
    private var weightTimer: Timer? = null
    private var isScaleOn = false
    private var currentWeight = 60.0
    private var isIncreasing = true
    private var eventSink: EventChannel.EventSink? = null
}
```

#### 主要コンポーネント
1. **Method Channel**: ON/OFF制御
    - `toggleScale` メソッドの実装
    - Boolean値による状態管理

2. **Event Channel**: データストリーミング
    - EventChannel.StreamHandlerインターフェースの実装
    - onListen、onCancelメソッドの提供

3. **Timer**: シミュレーションロジック
    - kotlinx.coroutinesのtimerを使用
    - 周期的なデータ生成と送信

## Flutter Stream Implementation Examples

### 基本的なStream実装
```dart
Stream<int> countStream() async* {
  for (int i = 1; i <= 10; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}

// 使用例
void streamExample() {
  countStream().listen(
    (data) => print('Count: $data'),
    onError: (error) => print('Error: $error'),
    onDone: () => print('Stream completed'),
  );
}
```

### StreamControllerを使用した実装
```dart
class WeightScaleBloc {
  final _weightController = StreamController<double>.broadcast();
  Stream<double> get weightStream => _weightController.stream;

  void addWeight(double weight) {
    _weightController.sink.add(weight);
  }

  void dispose() {
    _weightController.close();
  }
}
```

### StreamBuilderを使用したUI実装
```dart
StreamBuilder<double>(
  stream: weightBloc.weightStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('${snapshot.data?.toStringAsFixed(1)} kg');
    }
    return const Text('-- kg');
  },
)
```

## Platform Channel通信の流れ
1. Flutterからのメソッド呼び出し
2. ネイティブ側でのイベント処理
3. EventChannelを通じたデータストリーミング
4. FlutterでのStream受信とUI更新

## エラーハンドリング
- PlatformExceptionの処理
- Stream購読のエラーハンドリング
- タイマーの適切な解放

## ベストプラクティス
1. 適切なリソース解放
    - dispose()メソッドでのクリーンアップ
    - タイマーのキャンセル

2. メモリリーク防止
    - weakパターンの使用（Swift/Kotlin）
    - StreamControllerの適切なクローズ

3. エラー処理
    - try-catchブロックの使用
    - エラーログの実装

4. コード品質
    - ログ出力の標準化

## まとめ
この実装により、Flutterアプリケーションでネイティブプラットフォームとのシームレスな連携が実現できます。Method ChannelとEvent Channelを組み合わせることで、双方向のデータフローを実現し、リアルタイムなデータ更新とUI反映が可能になります。