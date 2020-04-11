# Mac 用の環境構築自動化設定ファイル
```
curl -O https://raw.githubusercontent.com/tomkenta/mac-setting/master/setting.sh (cannot see if it is not public)
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

## Alfred
begin setup -> 

## rectancgle (spectacle)
open

## google japanese ime
system preferrence >  keyboard > input source > + > google hiragana > OK 
you can now change by ctrl + space

## karabiner-element
open 
function key > use F1, F2 as function key
simple 

simple modification
caps / ctrl swap

complex > add rule > import more from network > serach japanese > import  For Japanese （日本語環境向けの設定） (rev 5)
add
- コマンドキーを単体で押したときに、英数・かなキーを送信する。（左コマンドキーは英数、右コマンドキーはかな） (rev 3)
- escキーを押したときに、英数キーも送信する（vim用）
- Ctrl+[を押したときに、escキーと英数キーを送信する


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
- Bookmark Sidebar ★★★ ( serach bookmarks ) 
└ setting > keyborad short cut > cmd + shift + D
└ setting > open side bar > click on icon, position left.
└ ( later you can export setting)
- Full Page Screen Capture ★
- Katalon Recorder ★★★ (test tool w/ setting file)
└ open file from cloud strage.
- Proxy SwitchySharp ★★★  (proxy manger w/ setting file)
- momentum ★★ (refreshing first page)
- Web Scraper ★ (it is easliy scrape file)
- Vimunium ★ ( browsing in vim way)
└ exculue j,k in google search so j, k and /can be used by Web Serach Navigator

## scroll
https://ryanhanson.dev/scroll  > open > system prefrence > sctuiry > accecibilty >  tick it 

tap scroll on nav bar > scroll with one finger > hold 
> lunch on login

## Clound Strage Link
(BOX/DropBox) 
box share ( can cask)
