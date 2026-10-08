import { http } from '@kit.NetworkKit';

interface Message {
  role: string;
  content: string;
}

interface ChatReply {
  reply: string;
}

@Entry
@Component
struct Index {
  @State messages: Message[] = [
    { role: 'assistant', content: '哼，杂鱼，来了？说吧。' }
  ];
  @State inputText: string = '';
  @State loading: boolean = false;

  async sendMessage() {
    if (!this.inputText.trim() || this.loading) return;

    const userMsg = this.inputText.trim();
    this.messages.push({ role: 'user', content: userMsg });
    this.inputText = '';
    this.loading = true;

    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'http://10.252.158.150:8000/chat',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ message: userMsg, history: [] }),
        }
      );
      const result: ChatReply = JSON.parse(response.result as string);
      this.messages.push({ role: 'assistant', content: result.reply });
    } catch (err) {
      const error = err as Error;
      this.messages.push({ role: 'assistant', content: `哼，出错了：${error.message}` });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.messages, (msg: Message) => {
          ListItem() {
            Text(msg.content)
              .fontSize(16)
              .fontColor(msg.role === 'user' ? '#333' : '#e94560')
              .padding(10)
              .backgroundColor(msg.role === 'user' ? '#f0f0f0' : '#fff5f7')
              .borderRadius(8)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .padding(10)

      Row({ space: 8 }) {
        TextInput({ text: this.inputText, placeholder: '说点什么...' })
          .layoutWeight(1)
          .onChange((value: string) => { this.inputText = value; })
        Button(this.loading ? '...' : '发送')
          .onClick(() => { this.sendMessage(); })
          .enabled(!this.loading)
      }
      .width('100%')
      .padding(10)
    }
    .width('100%')
    .height('100%')
  }
}