# WeChatNoAds74 v3.0

微信 8.0.74 小程序广告加速插件

## 功能
- **拦截小程序激励视频广告**：Hook `WAJSEventHandler_openChannelsRewardedVideoAd` JS API入口
- **加速广告倒计时**：Hook `adCountdownTimerCallBack` 跳过倒计时
- **伪造奖励回调**：拦截广告后仍触发 `onAdRewarded` 回调，小程序认为用户已获得奖励
- **屏蔽品牌广告**：拦截 `MagicAdBrandService` 和 `MagicAdPublicService`
- **屏蔽开屏广告**：拦截 `closeMenuSplashADViewController`
- **屏蔽视频号广告**：拦截 `WCFinderRewardAdViewController` 和 `WCFinderFeedStickerAdViewController`
- **广告域名屏蔽**：通过 hosts 文件屏蔽 20+ 广告域名

## 逆向分析成果
- 从 502.5MB WeChat 二进制中提取 2,076,949 个字符串
- 识别 641 个 ObjC 类，39 个广告相关类
- 定位 171 个 MagicAd 框架字符串
- 发现 `WAJSEventHandler_openChannelsRewardedVideoAd` 是小程序激励视频广告的入口点
- 确认 MagicAd 为微信自研广告框架（非 GDT SDK）

## 目标设备
- iPhone 14 Pro
- iOS 16.5
- Dopamine 越狱
- Sileo 商店

## 编译方法

### 方法1：在 Mac/Linux 上使用 Theos
```bash
# 1. 安装 Theos
export THEOS=~/theos
git clone --recursive https://github.com/theos/theos.git $THEOS

# 2. 克隆本项目
cd ~/Projects
git clone <this-repo> WeChatNoAds74

# 3. 编译
cd WeChatNoAds74
make clean
make package

# 4. 找到 .deb 文件
ls -la ./packages/*.deb
```

### 方法2：使用 Docker（推荐，无需 Mac）
```bash
# 1. 拉取 Theos Docker 镜像
docker pull theos/theos:latest

# 2. 克隆本项目
git clone <this-repo> WeChatNoAds74

# 3. 在 Docker 中编译
docker run -it -v $(pwd)/WeChatNoAds74:/project theos/theos:latest bash
cd /project
make clean
make package

# 4. 退出 Docker 后找到 .deb
ls -la ./packages/*.deb
```

### 方法3：在 iOS 设备上直接编译
```bash
# 1. 安装 iSH 或 Termux（如果支持）
# 2. 安装 Theos
export THEOS=~/theos
curl -sL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos | bash

# 3. 编译
cd /path/to/WeChatNoAds74
make package
```

## 安装方法
1. 将 `.deb` 文件传到 iPhone
2. 用 Sileo 打开 `.deb` 文件
3. 点击 "安装" 或 "升级"
4. 重启微信

## 项目结构
```
WeChatNoAds74/
├── control              # Debian 包信息
├── Makefile             # Theos 编译配置
├── Tweak.x              # 核心 Tweak 代码
├── WeChatNoAds74.plist  # Substrate 过滤规则
├── DEBIAN/
│   ├── control          # 包控制信息
│   ├── postinst         # 安装后脚本（写 hosts）
│   └── prerm            # 卸载前脚本（清理 hosts）
└── README.md            # 本文件
```

## 技术细节

### 广告拦截层次
1. **JS API 层**：拦截 `openChannelsRewardedVideoAd` 小程序 JS 调用
2. **控制器层**：拦截 `WCFinderRewardAdViewController` 和 `RewardAdViewController`
3. **服务层**：拦截 `MagicAdMiniProgramService` 和 `MagicAdCommonService`
4. **网络层**：拦截 `MagicAdCGIMgr` 的广告上报请求
5. **系统层**：通过 hosts 文件屏蔽广告域名

### 奖励机制
- 小程序通过 `openChannelsRewardedVideoAd` JS API 请求激励视频广告
- 插件拦截此调用，不加载实际广告
- 插件伪造 `onAdRewarded` 回调，让小程序认为用户已完成观看
- 小程序收到奖励回调后发放奖励

## 版本历史
- v3.0 (2026-06-12): 基于深度逆向分析重写，精确 Hook MagicAd 框架
- v2.0: GDT SDK 拦截（不适用于 8.0.74+）
- v1.0: 初始版本

## 注意事项
- 本插件仅用于学习和研究目的
- 使用本插件可能违反微信服务条款
- 请自行承担使用风险
- 建议在测试设备上先验证

## 致谢
- Theos 越狱开发框架
- Logos 预处理器
- class-dump 工具
- Frida 动态分析工具
