# Mac 用の環境構築自動化設定ファイル
```
curl -O -u tomkenta:{PAT} https://raw.githubusercontent.com/tomkenta/mac-setting/master/setting.sh
chmod 755 ./setting.sh
sh ./setting.sh 
```

`sh .setting` will take 30mins - 1 hours. Do somthing else

ex.
1. System Preferrence > Keyboard > modifier key > swap caps and control
2. System Preferrence > Accecitbilty > Keyboard > Trackpad option > ennable dragging > without drac lock  

others,. do others related to your job

comments -
As for ansible, 
once you see "chenged" for one , you can use it already.

so you can start do setting on each apps.

## directory structure
```
└->$ tree -L 1
.
├── Applications (local applications)
├── Box (need to install box-drive, this is where backup local files)
├── Desktop (We don't use , don't wanna mess here)
├── Documents 
├── Downloads
├── Library
├── Movies
├── Music
├── Pictures
├── Postman
├── Public
├── VirtualBox\ VMs
├── code
├── vbox
└── work

(DONT PUT files in home directory except dotfiles))
```
## System Preferene
Basically it can be configured in automation script , but some of them still shoud be set in GUI

- Touch ID
register your fingerpirnt

tick
[] unlock your mac
[] password auto fill


## Alfred
begin setup -> activate powerpack ( serach activation code there ) -> open alfred preference -> advanced -> Syncing -> set preference folder -> setting file "alfred/Alfred.alfredpreferences"

turn off spotlight hotkey （spotligt -> turn off the shortcut)
change hotkey to cmd + space

see for backup and retrive settiing https://www.alfredapp.com/help/advanced/sync/



## rectancgle (spectacle)
open -> import the RectangleConfig.json

## google japanese ime
system preferrence >  keyboard > input source > + > google hiragana > OK 
you can now change by ctrl + space

## karabiner-element
open is just ( .config/karabiner will work soon)

--- outdated
function key > use F1, F2 as function key
simple 

simple modification
caps / ctrl swap

complex > add rule > import more from network > serach japanese > import  For Japanese （日本語環境向けの設定） (rev 5)
add
- コマンドキーを単体で押したときに、英数・かなキーを送信する。（左コマンドキーは英数、右コマンドキーはかな） (rev 3)
- escキーを押したときに、英数キーも送信する（vim用）
- Ctrl+[を押したときに、escキーと英数キーを送信する
---


once open ( swap ctrl / caps will be removed)
      
## google chrome 
open -> google account login -> import bookmarks -> import extensions

- import bookmarks 

imort exported html from cloud strage ( job , personal)
or 
connected with google account ( personal) 

### imort exported html from cloud strage ( job , personal)
see https://support.google.com/chrome/answer/96816?hl=ja

### connected with google account ( personal) 
just login with your google account and turn on sync

- import extension

now only I know this way so far, 
- connected with google account ( personal) 

so just only to download them by hand.
- Web Serach Navigator ★★★ ( jk navigation is really strong in google seach)
  https://chrome.google.com/webstore/detail/web-search-navigator/cohamjploocgoejdfanacfgkhjkhdkek
- Bookmark Sidebar ★★★ ( serach bookmarks ) 
  https://chrome.google.com/webstore/detail/bookmark-sidebar/jdbnofccmhefkmjbkkdkfiicjkgofkdh?hl=en
└ setting > keyborad short cut > cmd + shift + D
└ setting > open side bar > click on icon, position left.
└ ( later you can export setting)
- Full Page Screen Capture ★
　https://chrome.google.com/webstore/detail/gofullpage-full-page-scre/fdpohaocaechififmbbbbbknoalclacl?hl=en
- Katalon Recorder ★★★ (test tool w/ setting file)
 https://chrome.google.com/webstore/detail/katalon-recorder-selenium/ljdobmomdgdljniojadhoplhkpialdid
└ open file from cloud strage.

- Proxy SwitchyOmega ★★★  (proxy manger w/ setting file)
https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif?hl=en
- Instant Data scraper ★ (it is easliy scrape file)
 https://chrome.google.com/webstore/detail/instant-data-scraper/ofaokhiedipichpaobibbnahnkdoiiah?hl=en
- Vimunium ★ ( browsing in vim way)
https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en
└ exclude j,k in google search so j, k and /can be used by Web Serach Navigator
- grammaly
 https://chrome.google.com/webstore/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen?hl=en
- website blocker
 https://chrome.google.com/webstore/detail/block-site-website-blocke/eiimnmioipafcokbfikbljfdeojpcgbh
- daily.dev
https://chrome.google.com/webstore/detail/dailydev-news-for-busy-de/jlmpjdjjbgclbocgajdjefcidcncaied?hl=en

## scroll
https://ryanhanson.dev/scroll  > open > system prefrence > sctuiry > accecibilty >  tick it 

tap scroll on nav bar > scroll with one finger > hold 
> lunch on login

## Clound Strage Link
(BOX/DropBox) 
box share ( can cask)


