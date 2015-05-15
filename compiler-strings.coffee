---
---

window.STRINGS =
  ja:
    bsm:
      locale:
        translator: "hitkey"
        translator_url: "http://hitkey.nekokan.dyndns.info/"
      app:
        pleasedrop: "左の領域にBMSファイルをドロップしてください。"
      about:
        title: "このツールについて"
        intro: "BMS Sound Matcherは、BGMオブジェクトと演奏用ノートを照合することによって、あなたの譜面作成を更に快適にします。"
        more: "後述のチュートリアルをご覧ください。"
      howto:
        title: "使い方"
        1:
          title: "オブジェクトZ1, Z2, Z3, …を用いて、演奏用パターンを書き込んでください。"
          description: "たとえば、演奏用ノートZ1はBGMレーン1行目を参照します。演奏用ノートZ2はBGMレーン2行目を参照します。以下同様です。"
        2:
          title: "そのBMSファイルを本アプリケーションにドロップしてください。"
          description: "あなたがBMSファイルをドロップすると、このアプリケーションはBMSを処理して、番号Z1–ZYによって参照されていたBGMノート群を演奏用ノートに置き換えます。"
        3:
          title: "生成されたBMSファイルをダウンロードしてください。"
          description: "処理が完了したのち、あなたのブラウザーは生成されたBMSファイルをダウンロードするでしょう。"
        4:
          title: "あなたのBMSはいまやキー音が鳴ります！"
          description: "おしまい！　もはや譜面を作るためにノートをドラッグする必要はありません。"
      limitations:
        title: "制限"
        reserved: "このツールはオブジェクト番号Z1–ZYを予約します。このツールを使う譜面は、音声をオブジェクト番号Z1–ZYに割り当てることができません。"
        browser: "このツールはChrome 42以上およびFirefox 37以上で動作します。"
      tech:
        title: "技術情報"
        worker: "workerはRubyで記述され、[[opal_link]]を用いてJavaScriptにコンパイルされています。"
        offline: "Rubyコマンドラインスクリプトとして[[offline_link]]。"
        offline_link: "オフライン版が利用可能です"
