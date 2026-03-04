import web_webview from '@ohos.web.webview';

interface HistoryItem {
  title: string;
  url: string;
  visitTime: string;
}

@Entry
@Component
struct Index {
  private webController: web_webview.WebviewController = new web_webview.WebviewController();

  @State currentUrl: string = 'https://www.baidu.com';
  @State inputUrl: string = 'https://www.baidu.com';
  @State pageTitle: string = '首页';
  @State historyList: HistoryItem[] = [];
  @State isDarkMode: boolean = false;

  aboutToAppear(): void {
    this.recordHistory('首页', this.currentUrl);
  }

  private formatNow(): string {
    const date: Date = new Date();
    const pad = (val: number): string => val < 10 ? `0${val}` : `${val}`;
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }

  private normalizeUrl(rawUrl: string): string {
    const value: string = rawUrl.trim();
    if (value.length === 0) {
      return this.currentUrl;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return `https://${value}`;
  }

  private openUrl(rawUrl: string): void {
    const target: string = this.normalizeUrl(rawUrl);
    this.currentUrl = target;
    this.inputUrl = target;
    try {
      this.webController.loadUrl(target);
    } catch (error) {
      console.error('LoadUrl Failed', JSON.stringify(error));
    }
    this.recordHistory(this.pageTitle, target);
  }

  private recordHistory(title: string, url: string): void {
    const currentTitle: string = (title && title.trim().length > 0) ? title : '未知页面';
    const filtered: HistoryItem[] = this.historyList.filter((item: HistoryItem) => item.url !== url);
    this.historyList = [{
      title: currentTitle,
      url: url,
      visitTime: this.formatNow()
    }, ...filtered];
  }

  @Builder buildTopBar() {
    Row({ space: 8 }) {
      TextInput({ text: this.inputUrl, placeholder: '输入网址或关键词' })
        .height(42)
        .layoutWeight(1)
        .fontSize(14)
        .onChange((value: string) => {
          this.inputUrl = value;
        })
        .onSubmit(() => {
          this.openUrl(this.inputUrl);
        });

      Button('访问')
        .height(42)
        .onClick(() => {
          this.openUrl(this.inputUrl);
        });
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 6 });
  }

  @Builder buildQuickActions() {
    Row({ space: 8 }) {
      Button('后退').type(ButtonType.Capsule).onClick(() => this.webController.backward());
      Button('前进').type(ButtonType.Capsule).onClick(() => this.webController.forward());
      Button('刷新').type(ButtonType.Capsule).onClick(() => this.webController.refresh());
      Button('主页').type(ButtonType.Capsule).onClick(() => this.openUrl('https://www.baidu.com'));
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 12, right: 12, bottom: 8 });
  }

  @Builder buildBrowserTab() {
    Column() {
      this.buildTopBar();
      this.buildQuickActions();

      Web({ src: this.currentUrl, controller: this.webController })
        .layoutWeight(1)
        .domStorageAccess(true)
        .onTitleReceive((event) => {
          if (event) {
            this.pageTitle = event.title;
            this.recordHistory(event.title, this.currentUrl);
          }
        });
    }
    .width('100%')
    .height('100%');
  }

  @Builder buildHistoryTab() {
    Column() {
      Row() {
        Text(`历史记录 (${this.historyList.length})`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDarkMode ? '#E5E5E5' : '#1A1A1A');

        Blank();

        Button('清空')
          .type(ButtonType.Capsule)
          .onClick(() => {
            this.historyList = [];
          });
      }
      .width('100%')
      .padding(12);

      List({ space: 8 }) {
        ForEach(this.historyList, (item: HistoryItem) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDarkMode ? '#E5E5E5' : '#1A1A1A')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(item.url)
                .fontSize(13)
                .fontColor(this.isDarkMode ? '#999999' : '#666666')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(item.visitTime)
                .fontSize(12)
                .fontColor(this.isDarkMode ? '#666666' : '#999999');
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor(this.isDarkMode ? '#2B2B2B' : '#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              this.openUrl(item.url);
            });
          }
        }, (item: HistoryItem) => item.url + item.visitTime);
      }
      .layoutWeight(1)
      .padding({ left: 12, right: 12, bottom: 12 });
    }
    .width('100%')
    .height('100%');
  }

  @Builder buildSettingsTab() {
    Column({ space: 16 }) {
      Text('设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkMode ? '#E5E5E5' : '#1A1A1A')
        .width('100%');

      Row() {
        Text('暗黑主题').fontSize(16).fontColor(this.isDarkMode ? '#E5E5E5' : '#1A1A1A');
        Blank();
        Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
          .onChange((isOn: boolean) => {
            this.isDarkMode = isOn;
          });
      }
      .width('100%')
      .padding(12)
      .borderRadius(12)
      .backgroundColor(this.isDarkMode ? '#2B2B2B' : '#FFFFFF');
    }
    .padding(12)
    .width('100%')
    .height('100%');
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          this.buildBrowserTab();
        }.tabBar('浏览');

        TabContent() {
          this.buildHistoryTab();
        }.tabBar('历史');

        TabContent() {
          this.buildSettingsTab();
        }.tabBar('设置');
      }
      .barMode(BarMode.Fixed)
      .layoutWeight(1)
      .vertical(false)
      .backgroundColor(this.isDarkMode ? '#1A1A1A' : '#F2F3F5');
    }
    .height('100%')
    .width('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A1A' : '#F2F3F5');
  }
}
