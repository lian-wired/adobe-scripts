# convertTag.jsx
#
# Adobe Script for InDesign
# Author: Lian

paragraphStyles = {
  title: "タイトル",
  author: "著者",
  h1: "大見出し",
  h2: "中見出し",
  h3: "小見出し",
  qt: "引用",
  qt_right: "引用右揃え"
}

characterStyles = {
  b: "太文字",
  dot: "圏点",
  tate: "縦中横",
  en: "英字",
  90: "90度回転",
}

main = ->
  if app.documents.length == 0
    errorMsg 'ドキュメントが開かれていません。'
  else
    resetFindChangeGrep()
    paragraphStyles = deleteNonExistStyle(paragraphStyles, "paragraph")
    characterStyles = deleteNonExistStyle(characterStyles, "character")

    for story in app.activeDocument.stories
      # 何も段落スタイルが適用されていない場合は基本段落で上書き
      basicStyle = app.activeDocument.paragraphStyles.item("基本")
      for s in story.paragraphs
        if s.appliedParagraphStyle.index == 0 || s.appliedParagraphStyle.index == 1
          s.applyParagraphStyle(basicStyle)

      # 段落スタイル適用
      for tag, pStyleName of paragraphStyles
        style = app.activeDocument.paragraphStyles.item(pStyleName)
        convertTag(story, tag, style, "paragraph")

      # 文字スタイル適用
      for tag, cStyleName of characterStyles
        style = app.activeDocument.characterStyles.item(cStyleName)
        convertTag(story, tag, style, "character")

    resetFindChangeGrep()
  return

# タグを変換
convertTag = (story, tag, style, kind) ->
  resetFindChangeGrep()
  # 正規表現で検索
  app.findGrepPreferences.findWhat = "<#{tag}>(.*?)<\/#{tag}>"
  foundItems = story.findGrep()

  if foundItems.length != 0
    foundTags = []
    for foundItem in foundItems
      foundTags.push(foundItem.contents)
    for str in foundTags
      app.findTextPreferences.findWhat = str
      if kind == "paragraph"
        app.changeTextPreferences.appliedParagraphStyle = style
      else
        app.changeTextPreferences.appliedCharacterStyle = style
      # タグ部分を削除
      changeTo = str.match(///<#{tag}>(.*?)<\/#{tag}>///)[1]
      app.changeTextPreferences.changeTo = changeTo
      story.changeText()
  return

# 存在しない文字・段落スタイルを削除
deleteNonExistStyle = (styles, kind) ->
  for tag, styleName of styles
    if kind == "paragraph"
      style = app.activeDocument.paragraphStyles.item(styleName)
    else
      style = app.activeDocument.characterStyles.item(styleName)

    try
      style.name
    catch err
      alert("#{if kind=="paragraph" then "段落" else "文字"}スタイル'#{styleName}'が存在しません。")
      delete styles[tag]
  return styles

# 検索・置換文字列を初期化
resetFindChangeGrep = ->
  app.findGrepPreferences = NothingEnum.nothing
  app.changeGrepPreferences = NothingEnum.nothing
  app.changeTextPreferences = NothingEnum.nothing

# エラー表示
errorMsg = (str) ->
  alert str
  exit()
  return

main()

