import window from '@ohos.window'
import common from '@ohos.app.ability.common'
import brightness, { BrightnessModeResponse, BrightnessResponse } from '@system.brightness';

@Entry
@Component
struct Index {
  @State brightnessData: number = 50
  @State colorTemp: number = 5000
  @State isLightOn: boolean = false
  @State currentMode: string = 'normal'
  @State isTimerActive: boolean = false
  @State timerMinutes: number = 0
  private context = getContext(this) as common.UIAbilityContext
  private timerId: number = -1

  aboutToAppear() {
    // 获取当前亮度
    try {
       brightness.getValue({
        success: (data: BrightnessResponse) => {
          this.brightnessData = Math.round(data.value * 100)
        },
        fail: (data: string, code: number) => {
          console.error('get brightness fail, code: ' + code + ', data: ' + data);
        }
      });

    } catch (error) {
      console.error('获取亮度失败:', error)
    }
    // 保持屏幕常亮
    this.keepScreenOn()
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId)
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('补光灯')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(50)
      .padding({ left: 20 })
      .backgroundColor($r('sys.color.comp_background_list_card'))

      // 主光源控制
      Column() {
        Toggle({ type: ToggleType.Switch, isOn: this.isLightOn })
          .onChange((isOn: boolean) => {
            this.isLightOn = isOn
            this.updateBrightness()
          })
          .margin(20)
      }
      .width('100%')
      .height(200)
      .backgroundColor(this.isLightOn ? '#FFFFFF' : '#EEEEEE')

      // 亮度控制
      Column() {
        Text('亮度调节')
          .fontSize(16)
          .margin({ top: 20, bottom: 10 })

        Slider({
          value: this.brightnessData,
          min: 0,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('90%')
          .onChange((value: number) => {
            this.brightnessData = value
            this.updateBrightness()
          })
          .showTips(true)

        Text(`${this.brightnessData}%`)
          .fontSize(14)
          .margin({ top: 10 })
      }
      .width('100%')
      .padding(10)

      // 模式选择
      Column() {
        Text('模式选择')
          .fontSize(16)
          .margin({ top: 20, bottom: 10 })

        Flex({ justifyContent: FlexAlign.SpaceAround }) {
          Button('自拍模式')
            .onClick(() => this.setMode('selfie'))
            .backgroundColor(this.currentMode === 'selfie' ? '#007DFF' : '#F0F0F0')
            .fontColor(this.currentMode === 'selfie' ? '#FFFFFF' : '#000000')
            .width('28%')

          Button('阅读模式')
            .onClick(() => this.setMode('reading'))
            .backgroundColor(this.currentMode === 'reading' ? '#007DFF' : '#F0F0F0')
            .fontColor(this.currentMode === 'reading' ? '#FFFFFF' : '#000000')
            .width('28%')

          Button('夜间模式')
            .onClick(() => this.setMode('night'))
            .backgroundColor(this.currentMode === 'night' ? '#007DFF' : '#F0F0F0')
            .fontColor(this.currentMode === 'night' ? '#FFFFFF' : '#000000')
            .width('28%')
        }
        .width('90%')
      }
      .width('100%')
      .padding(10)

      // 定时设置
      Column() {
        Text('定时关闭')
          .fontSize(16)
          .margin({ top: 20, bottom: 10 })

        Row() {
          TextInput({ placeholder: '分钟', text: this.timerMinutes.toString() })
            .type(InputType.Number)
            .width('30%')
            .height(40)
            .margin({ right: 20 })
            .onChange((value: string) => {
              this.timerMinutes = parseInt(value) || 0
            })

          Button(this.isTimerActive ? '取消定时' : '开始定时')
            .onClick(() => this.toggleTimer())
            .backgroundColor(this.isTimerActive ? '#FF4444' : '#007DFF')
            .width('30%')
            .height(40)
        }
        .width('90%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private updateBrightness() {
    try {
      let temp = 0.3;
      if (this.isLightOn) {
        temp = this.brightnessData / 100;
      }
      brightness.setValue({
        value: temp,
        success: () => {
          console.log('handling set brightness success.');
        },
        fail: (data: string, code: number) => {
          console.error('handling set brightness value fail, code:' + code + ', data: ' + data);
        }
      });
    } catch (error) {
      console.error('设置亮度失败:', error)
    }
  }

  private setMode(mode: string) {
    this.currentMode = mode
    switch (mode) {
      case 'selfie':
        this.brightnessData = 100
        this.colorTemp = 5500
        break
      case 'reading':
        this.brightnessData = 70
        this.colorTemp = 4000
        break
      case 'night':
        this.brightnessData = 30
        this.colorTemp = 2700
        break
    }
    this.updateBrightness()
  }

  private toggleTimer() {
    if (this.isTimerActive) {
      // 取消定时
      this.isTimerActive = false
      if (this.timerId !== -1) {
        clearTimeout(this.timerId)
        this.timerId = -1
      }
    } else if (this.timerMinutes > 0) {
      // 开始定时
      this.isTimerActive = true
      this.timerId = setTimeout(() => {
        this.isLightOn = false
        this.isTimerActive = false
        this.updateBrightness()
        this.timerId = -1
      }, this.timerMinutes * 60 * 1000) as number
    }
  }

  private async keepScreenOn() {
    try {
      const windowClass = await window.getLastWindow(this.context)
      await windowClass.setKeepScreenOn(true)
    } catch (error) {
      console.error('设置屏幕常亮失败:', error)
    }
  }
}