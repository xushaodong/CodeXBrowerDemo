import web_webview from '@ohos.web.webview';

class HistoryItem {
  title: string = '';
  url: string = '';
  visitTime: string = '';
}

class BrowserTabItem {
  id: number = 1;
  title: string = '首页';
  url: string = 'https://www.baidu.com';
  isIncognito: boolean = false;
}

@Entry
@Component
struct Index {
  private webController: web_webview.WebviewController = new web_webview.WebviewController();

  @State inputUrl: string = 'https://www.baidu.com';
  @State pageTitle: string = '首页';
  @State historyList: HistoryItem[] = [];
  @State isDarkMode: boolean = false;
  @State showTabPanel: boolean = false;
  @State showDownloadPanel: boolean = false;
  @State tabs: BrowserTabItem[] = [new BrowserTabItem()];
  @State activeTabId: number = 1;
  @State nextTabId: number = 2;

  aboutToAppear(): void {
    this.recordHistory('首页', 'https://www.baidu.com');
  }

  private formatNow(): string {
    const date: Date = new Date();
    const pad = (val: number): string => val < 10 ? `0${val}` : `${val}`;
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }

  private normalizeUrl(rawUrl: string): string {
    const value: string = rawUrl.trim();
    if (value.length === 0) {
      return this.getActiveTab().url;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return `https://${value}`;
  }

  private getActiveTab(): BrowserTabItem {
    const target: BrowserTabItem | undefined = this.tabs.find((item: BrowserTabItem) => item.id === this.activeTabId);
    if (target) {
      return target;
    }
    return this.tabs[0];
  }

  private updateActiveTab(next: BrowserTabItem): void {
    this.tabs = this.tabs.map((item: BrowserTabItem) => item.id === this.activeTabId ? next : item);
  }

  private openUrl(rawUrl: string): void {
    const active: BrowserTabItem = this.getActiveTab();
    const targetUrl: string = this.normalizeUrl(rawUrl);
    const nextTab: BrowserTabItem = {
      id: active.id,
      title: this.pageTitle,
      url: targetUrl,
      isIncognito: active.isIncognito
    };
    this.inputUrl = targetUrl;
    this.updateActiveTab(nextTab);
    try {
      this.webController.loadUrl(targetUrl);
    } catch (error) {
      console.error('LoadUrl Failed', JSON.stringify(error));
    }
    if (!active.isIncognito) {
      this.recordHistory(this.pageTitle, targetUrl);
    }
  }

  private switchTab(tabId: number): void {
    this.activeTabId = tabId;
    const active: BrowserTabItem = this.getActiveTab();
    this.inputUrl = active.url;
    this.pageTitle = active.title;
    this.showTabPanel = false;
    try {
      this.webController.loadUrl(active.url);
    } catch (error) {
      console.error('SwitchTab loadUrl Failed', JSON.stringify(error));
    }
  }

  private addNewTab(isIncognito: boolean): void {
    const id: number = this.nextTabId;
    const nextTab: BrowserTabItem = {
      id: id,
      title: isIncognito ? '无痕标签页' : '新标签页',
      url: 'https://www.baidu.com',
      isIncognito: isIncognito
    };
    this.nextTabId = id + 1;
    this.tabs = [nextTab, ...this.tabs];
    this.activeTabId = id;
    this.inputUrl = nextTab.url;
    this.pageTitle = nextTab.title;
    this.showTabPanel = false;
    try {
      this.webController.loadUrl(nextTab.url);
    } catch (error) {
      console.error('AddNewTab loadUrl Failed', JSON.stringify(error));
    }
  }

  private removeTab(tabId: number): void {
    if (this.tabs.length <= 1) {
      return;
    }
    this.tabs = this.tabs.filter((item: BrowserTabItem) => item.id !== tabId);
    if (this.activeTabId === tabId) {
      this.activeTabId = this.tabs[0].id;
      this.switchTab(this.activeTabId);
    }
  }

  private moveTab(tabId: number, offset: number): void {
    const index: number = this.tabs.findIndex((item: BrowserTabItem) => item.id === tabId);
    const targetIndex: number = index + offset;
    if (index < 0 || targetIndex < 0 || targetIndex >= this.tabs.length) {
      return;
    }
    const nextTabs: BrowserTabItem[] = [...this.tabs];
    const cache: BrowserTabItem = nextTabs[index];
    nextTabs[index] = nextTabs[targetIndex];
    nextTabs[targetIndex] = cache;
    this.tabs = nextTabs;
  }

  private toggleIncognitoForCurrentTab(): void {
    const active: BrowserTabItem = this.getActiveTab();
    const nextTab: BrowserTabItem = {
      id: active.id,
      title: active.title,
      url: active.url,
      isIncognito: !active.isIncognito
    };
    this.updateActiveTab(nextTab);
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
      Row({ space: 8 }) {
        Text('🔎')
          .fontSize(16)
          .fontColor(this.isDarkMode ? '#A8A8A8' : '#7A8492');

        TextInput({ text: this.inputUrl, placeholder: '搜索或输入网址' })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontColor(this.isDarkMode ? '#EFEFEF' : '#1A1A1A')
          .backgroundColor('#00000000')
          .onChange((value: string) => {
            this.inputUrl = value;
          })
          .onSubmit(() => {
            this.openUrl(this.inputUrl);
          });
      }
      .layoutWeight(1)
      .height(46)
      .padding({ left: 12, right: 8 })
      .borderRadius(23)
      .backgroundColor(this.isDarkMode ? '#2A2D34' : '#FFFFFF');

      Button('前往')
        .height(46)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#3E7BFA')
        .fontColor('#FFFFFF')
        .onClick(() => {
          this.openUrl(this.inputUrl);
        });
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 8 });
  }

  @Builder buildTabStrip() {
    Row({ space: 8 }) {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.tabs, (tab: BrowserTabItem) => {
            Row({ space: 6 }) {
              Text(tab.isIncognito ? '🕶' : '🌐')
                .fontSize(12);
              Text(tab.title)
                .fontSize(13)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor(tab.id === this.activeTabId ? '#FFFFFF' : (this.isDarkMode ? '#C0C6D1' : '#4F5966'));
            }
            .height(34)
            .padding({ left: 10, right: 10 })
            .borderRadius(18)
            .backgroundColor(tab.id === this.activeTabId ? '#3E7BFA' : (this.isDarkMode ? '#2B2F37' : '#FFFFFF'))
            .onClick(() => {
              this.switchTab(tab.id);
            });
          }, (tab: BrowserTabItem) => `${tab.id}`);
        }
      }
      .layoutWeight(1);

      Button('+')
        .width(34)
        .height(34)
        .fontSize(20)
        .borderRadius(17)
        .backgroundColor(this.isDarkMode ? '#2B2F37' : '#FFFFFF')
        .onClick(() => {
          this.addNewTab(false);
        });
    }
    .width('100%')
    .padding({ left: 12, right: 12, bottom: 8 });
  }

  @Builder
  buildIncognitoHint() {
    if (this.getActiveTab().isIncognito) {
      Row({ space: 8 }) {
        Text('🕶')
          .fontSize(15);
        Text('无痕会话中：不会记录历史记录与搜索输入')
          .fontSize(12)
          .fontColor(this.isDarkMode ? '#D6D6D6' : '#2F4A7A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ left: 12, right: 12, bottom: 8 })
      .borderRadius(12)
      .backgroundColor(this.isDarkMode ? '#312E3E' : '#EAF1FF');
    }
  }

  @Builder buildActionItem(icon: string, title: string, action: () => void) {
    Column({ space: 6 }) {
      Button(icon)
        .width(44)
        .height(44)
        .fontSize(18)
        .borderRadius(22)
        .backgroundColor(this.isDarkMode ? '#353943' : '#EFF3FB')
        .onClick(() => {
          action();
        });

      Text(title)
        .fontSize(11)
        .fontColor(this.isDarkMode ? '#B9C1CE' : '#5B6470');
    }
    .width(58);
  }

  @Builder buildQuickActions() {
    Row() {
      this.buildActionItem('←', '后退', () => this.webController.backward());
      this.buildActionItem('→', '前进', () => this.webController.forward());
      this.buildActionItem('↻', '刷新', () => this.webController.refresh());
      this.buildActionItem('⌂', '主页', () => this.openUrl('https://www.baidu.com'));
      this.buildActionItem(this.getActiveTab().isIncognito ? '🕶' : '◐', this.getActiveTab().isIncognito ? '无痕中' : '无痕', () => this.toggleIncognitoForCurrentTab());
      this.buildActionItem('⇩', '下载', () => {
        this.showDownloadPanel = !this.showDownloadPanel;
      });
      this.buildActionItem('▦', `${this.tabs.length}页`, () => {
        this.showTabPanel = !this.showTabPanel;
      });
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 8, right: 8, top: 10, bottom: 12 })
    .margin({ left: 12, right: 12, bottom: 10 })
    .borderRadius(18)
    .backgroundColor(this.isDarkMode ? '#242833' : '#FFFFFF');
  }

  @Builder buildDownloadPanel() {
    if (this.showDownloadPanel) {
      Row({ space: 8 }) {
        Text('⬇️')
          .fontSize(16);
        Text('下载入口已预留：可接入下载管理器、断点续传与文件列表。')
          .fontSize(12)
          .fontColor(this.isDarkMode ? '#C9CED8' : '#49566B')
          .layoutWeight(1)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Button('关闭')
          .height(28)
          .fontSize(12)
          .onClick(() => {
            this.showDownloadPanel = false;
          });
      }
      .width('100%')
      .padding(12)
      .margin({ left: 12, right: 12, bottom: 8 })
      .borderRadius(14)
      .backgroundColor(this.isDarkMode ? '#20242D' : '#F3F7FF');
    }
  }

  @Builder buildTabManagerPanel() {
    if (this.showTabPanel) {
      Column({ space: 10 }) {
        Row() {
          Text('标签管理')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? '#F0F0F0' : '#1F2630');
          Blank();
          Button('新建无痕')
            .height(30)
            .fontSize(12)
            .backgroundColor(this.isDarkMode ? '#3A3F4A' : '#EAF1FF')
            .fontColor(this.isDarkMode ? '#E6E6E6' : '#2E5EEA')
            .onClick(() => {
              this.addNewTab(true);
            });
        }
        .width('100%');

        List({ space: 8 }) {
          ForEach(this.tabs, (tab: BrowserTabItem) => {
            ListItem() {
              Row({ space: 8 }) {
                Column({ space: 4 }) {
                  Text(`${tab.isIncognito ? '无痕' : '普通'} · ${tab.title}`)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isDarkMode ? '#F2F2F2' : '#1F2630')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Text(tab.url)
                    .fontSize(12)
                    .fontColor(this.isDarkMode ? '#9E9E9E' : '#64707D')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .onClick(() => {
                  this.switchTab(tab.id);
                });

                Column({ space: 4 }) {
                  Button('↑')
                    .width(26)
                    .height(22)
                    .fontSize(11)
                    .backgroundColor(this.isDarkMode ? '#404654' : '#E9EEF8')
                    .onClick(() => {
                      this.moveTab(tab.id, -1);
                    });
                  Button('↓')
                    .width(26)
                    .height(22)
                    .fontSize(11)
                    .backgroundColor(this.isDarkMode ? '#404654' : '#E9EEF8')
                    .onClick(() => {
                      this.moveTab(tab.id, 1);
                    });
                }

                Button('✕')
                  .width(28)
                  .height(28)
                  .fontSize(12)
                  .backgroundColor(this.isDarkMode ? '#3A3F4A' : '#EDF1F7')
                  .onClick(() => {
                    this.removeTab(tab.id);
                  });
              }
              .padding(10)
              .borderRadius(12)
              .backgroundColor(tab.id === this.activeTabId ? (this.isDarkMode ? '#314369' : '#DCE7FF') : (this.isDarkMode ? '#272C35' : '#FFFFFF'));
            }
          }, (tab: BrowserTabItem) => `${tab.id}`);
        }
        .height(220);
      }
      .width('100%')
      .padding(12)
      .margin({ left: 12, right: 12, bottom: 10 })
      .borderRadius(16)
      .backgroundColor(this.isDarkMode ? '#1F242E' : '#F8FAFF');
    }
  }

  @Builder buildBrowserTab() {
    Column() {
      this.buildTopBar();
      this.buildTabStrip();
      this.buildIncognitoHint();

      Web({ src: this.getActiveTab().url, controller: this.webController })
        .layoutWeight(1)
        .domStorageAccess(true)
        .onTitleReceive((event) => {
          if (event) {
            this.pageTitle = event.title;
            const active: BrowserTabItem = this.getActiveTab();
            const nextTab: BrowserTabItem = {
              id: active.id,
              title: event.title,
              url: active.url,
              isIncognito: active.isIncognito
            };
            this.updateActiveTab(nextTab);
            if (!active.isIncognito) {
              this.recordHistory(event.title, active.url);
            }
          }
        });

      this.buildTabManagerPanel();
      this.buildDownloadPanel();
      this.buildQuickActions();
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
            .backgroundColor(this.isDarkMode ? '#2B2F37' : '#FFFFFF')
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
      .backgroundColor(this.isDarkMode ? '#2B2F37' : '#FFFFFF');

      Row({ space: 8 }) {
        Text('当前会话')
          .fontSize(16)
          .fontColor(this.isDarkMode ? '#E5E5E5' : '#1A1A1A');
        Text(this.getActiveTab().isIncognito ? '无痕模式' : '普通模式')
          .fontSize(13)
          .fontColor(this.getActiveTab().isIncognito ? '#6D8CFF' : '#7D8795');
      }
      .width('100%')
      .padding(12)
      .borderRadius(12)
      .backgroundColor(this.isDarkMode ? '#2B2F37' : '#FFFFFF');
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
      .backgroundColor(this.isDarkMode ? '#171A21' : '#F2F5FA');
    }
    .height('100%')
    .width('100%')
    .backgroundColor(this.isDarkMode ? '#171A21' : '#F2F5FA');
  }
}
