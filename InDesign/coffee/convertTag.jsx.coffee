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
    paragraphStyles = deleteNonExistStyle(paragraphStyles, "paragraph")
    characterStyles = deleteNonExistStyle(characterStyles, "character")

    for myStory in app.activeDocument.stories
      convertTag myStory
  return

convertTag = (story) ->
  # 何も段落スタイルが適用されていない場合は基本段落で上書き
  basicStyle = app.activeDocument.paragraphStyles.item("基本");
  for s in story.paragraphs
    if s.appliedParagraphStyle.index == 0
      s.applyParagraphStyle(basicStyle)

  # 段落スタイル適用
  for tagName, pStyleName of paragraphStyles
    pStyle = app.activeDocument.paragraphStyles.item(pStyleName);
    # タグが見つかるまでループ
    while story.contents.search(///<#{tagName}>(.*)?<\/#{tagName}>///) != -1
      text = story.contents
      st = text.search(///<#{tagName}>///)
      ed = text.search(///<\/#{tagName}>///)

      obj = story.characters.itemByRange(st, ed)
      for myObj in obj.paragraphs
        myObj.applyParagraphStyle(pStyle)
      eraseTag(story, tagName.length, st, ed)

  # 文字スタイル適用
  while story.contents.search(///<#{tagName}>(.*)?<\/#{tagName}>///) != -1
    text = story.contents
    st = text.search(///<#{tagName}>///)
    ed = text.search(///<\/#{tagName}>///)

    obj = story.characters.itemByRange(st, ed)
    obj.applyCharacterStyle(cStyle)

  for tagName, cStyleName of characterStyles
    cStyle = app.activeDocument.characterStyles.item(cStyleName);
    while story.contents.search(///<#{tagName}>(.*)?<\/#{tagName}>///) != -1
      text = story.contents
      st = text.search(///<#{tagName}>///)
      ed = text.search(///<\/#{tagName}>///)

      obj = story.characters.itemByRange(st, ed)
      obj.applyCharacterStyle(cStyle)
      eraseTag(story, tagName.length, st, ed)
  return

# 変換の終わったタグの削除
eraseTag = (story, tagLength, st, ed) ->
  # 文字位置が変化するので後ろから消していく
  story.characters.itemByRange(ed, ed + tagLength + 2).remove()
  story.characters.itemByRange(st, st + tagLength + 1).remove()
  return

# 存在しない文字・段落スタイルを削除
deleteNonExistStyle = (styles, kind) ->
  for tagName, styleName of styles
    if kind == "paragraph"
      style = app.activeDocument.paragraphStyles.item(styleName)
    else
      style = app.activeDocument.characterStyles.item(styleName)

    try
      style.name
    catch err
      alert("#{if kind=="paragraph" then "段落" else "文字"}スタイル'#{styleName}'が存在しません。")
      delete styles[tagName]
  return styles

errorMsg = (str) ->
  alert str
  exit()
  return

main()

