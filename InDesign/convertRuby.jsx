// Ruby.jsx
// An InDesign JavaScript
// Author: Lian
//
// 使い方
//
// グループルビ
// 下記のようにルビをふる文字列を'[[***]]'で括り、それに付与するルビを'<<>>'でその直後に配置
// [[今日]]<<きょう>>
//
// モノルビ
// 1文字ずつルビをふりたい場合は下記のように'|'でルビ文字を区切ると、それにあわせてルビを1文字ずつふります
// [[今日]]<<こん|にち>>
//
// ダメな例
// 下記ように'|'の数とルビをふる文字の数が一致しない場合は動く動きません
// [[一太郎]]<<いち|たろう>>
//

(function(thisObj){
  var startOyaChar = "[";
  var endOyaChar = "]";
  var startRubyChar = "<";
  var endRubyChar = ">";

  function main(){
    // app.scriptPreferences.userInteractionLevel = UserInteractionLevels.interactWithAll;
    if(app.documents.length === 0){
      errorMsg("ドキュメントが開かれていません。");
    } else {
      app.findGrepPreferences = NothingEnum.nothing;
	    app.changeGrepPreferences = NothingEnum.nothing;

      var i;
      var myDoc = app.activeDocument;
      var myStory;
      var srcText;

      for(i = 0; i < myDoc.stories.length; i++) {
        myStory = myDoc.stories[i];
        convertRuby(myStory);
      }
    }
  };

  function convertRuby(story){
    var text;
    var i; // ルビ親文字の開始位置
    var j; // ルビ親文字の終了位置
    var k; // ルビの開始位置
    var l; // ルビの終了位置
    var m;
    var oyaObj;
    var rubyString;
    var errorStr;

    // [[hoge]]<<fuga>>が見つからなくなるまでループ
    while(story.contents.search(/\[\[(.*)?\]\]<<(.*)?>>/) !== -1){
      text = story.contents;
      // ルビ親文字の開始位置
      i = text.search(/\[\[(.*)?\]\]<<(.*)?>>/);
      for(j = i+2; j < text.length; j++){
        // ルビ親文字の終了位置
        if(text[j] !== endOyaChar || text[j+1] !== endOyaChar) continue;
        for(k = j+2; k < text.length; k++){
          // ルビの開始位置
          if(text[k] !== startRubyChar || text[k+1] !== startRubyChar) continue;
          for(l = k+2; l < text.length; l++){
            if(text[l] !== endRubyChar || text[l+1] !== endRubyChar) continue;
            rubyString = text.substring(k+2, l);
            // ルビ文字列中に | が存在するかチェック
            if(rubyString.match(/\|/)) {
              // モノルビ
              rubyStrings = rubyString.split("|");
              // 親文字とルビ文字の数が一致しているかチェック
              if(oyaString.length === rubyStrings.length) {
                for(m = 0; m < rubyStrings.length; m++) {
                  oyaObj = story.characters.itemByRange(i+2+m, i+2+m);
                  oyaObj.rubyString = rubyStrings[m];
                  oyaObj.rubyFlag = true;
                  oyaObj.rubyType = RubyTypes.perCharacterRuby;
                }
              } else {
                errorString = "モノルビの親文字とルビ文字の数が一致しません。\n";
                errorString += "親文字: " + text.substring(i+2, j) + "\n";
                errorString += "ルビ:   " + rubyStrings;
                errorMsg(errorString);
              }
            } else {
              // グループルビ
              oyaObj = story.characters.itemByRange(i+2, j-1);
              oyaObj.rubyString = rubyString;
              oyaObj.rubyFlag = true;
              oyaObj.rubyType = RubyTypes.groupRuby;
            }
            break;
          }
          break;
        }
        break;
      }
      // 文字位置が変化するので後ろから消していく
      story.characters.itemByRange(k, l+1).remove();
      story.characters.itemByRange(j, j+1).remove();
      story.characters.itemByRange(i, i+1).remove();
    }
  }

  function errorMsg(str){
    alert(str);
    exit();
  }

  main();
})(this);

