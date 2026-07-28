export interface RecognizedPhrase {
  phraseKey: string;
  text: string;
  type: string;
  meaning: string;
  startOffset: number;
  endOffset: number;
  confidence: number;
}

const PHRASE_PATTERNS: { pattern: string; type: string; meaning: string }[] = [
  // ===== Phrasal Verbs (动词短语) =====
  { pattern: "look up", type: "phrasal verb", meaning: "查阅；向上看；好转" },
  { pattern: "look for", type: "phrasal verb", meaning: "寻找" },
  { pattern: "look after", type: "phrasal verb", meaning: "照顾；照料" },
  { pattern: "look into", type: "phrasal verb", meaning: "调查；研究" },
  { pattern: "look forward to", type: "phrasal verb", meaning: "期待；盼望" },
  { pattern: "look down on", type: "phrasal verb", meaning: "看不起；轻视" },
  { pattern: "look up to", type: "phrasal verb", meaning: "尊敬；敬仰" },
  { pattern: "look out", type: "phrasal verb", meaning: "小心；注意" },
  { pattern: "look through", type: "phrasal verb", meaning: "浏览；翻看" },
  { pattern: "look back on", type: "phrasal verb", meaning: "回顾；回忆" },
  { pattern: "give up", type: "phrasal verb", meaning: "放弃；戒掉" },
  { pattern: "give in", type: "phrasal verb", meaning: "屈服；让步" },
  { pattern: "give out", type: "phrasal verb", meaning: "分发；耗尽" },
  { pattern: "give away", type: "phrasal verb", meaning: "赠送；泄露" },
  { pattern: "give back", type: "phrasal verb", meaning: "归还；返还" },
  { pattern: "give off", type: "phrasal verb", meaning: "散发出（气味、光、热）" },
  { pattern: "take off", type: "phrasal verb", meaning: "起飞；脱下；开始成功" },
  { pattern: "take on", type: "phrasal verb", meaning: "承担；雇用；呈现" },
  { pattern: "take over", type: "phrasal verb", meaning: "接管；接替" },
  { pattern: "take up", type: "phrasal verb", meaning: "开始从事；占用（时间/空间）" },
  { pattern: "take out", type: "phrasal verb", meaning: "取出；拿出；外卖" },
  { pattern: "take in", type: "phrasal verb", meaning: "理解；吸收；收留" },
  { pattern: "take care of", type: "phrasal verb", meaning: "照顾；处理" },
  { pattern: "take advantage of", type: "phrasal verb", meaning: "利用；占便宜" },
  { pattern: "take part in", type: "phrasal verb", meaning: "参加；参与" },
  { pattern: "take place", type: "phrasal verb", meaning: "发生；举行" },
  { pattern: "take after", type: "phrasal verb", meaning: "与…相像（指性格或外貌）" },
  { pattern: "take down", type: "phrasal verb", meaning: "记下；拆除" },
  { pattern: "take away", type: "phrasal verb", meaning: "带走；外卖；剥夺" },
  { pattern: "put off", type: "phrasal verb", meaning: "推迟；拖延" },
  { pattern: "put up with", type: "phrasal verb", meaning: "忍受；容忍" },
  { pattern: "put on", type: "phrasal verb", meaning: "穿上；上演；增加" },
  { pattern: "put out", type: "phrasal verb", meaning: "熄灭；扑灭；出版" },
  { pattern: "put down", type: "phrasal verb", meaning: "放下；写下；镇压" },
  { pattern: "put forward", type: "phrasal verb", meaning: "提出（建议、观点）" },
  { pattern: "put away", type: "phrasal verb", meaning: "收拾；收好；储存" },
  { pattern: "put aside", type: "phrasal verb", meaning: "放在一边；抛开；储蓄" },
  { pattern: "put through", type: "phrasal verb", meaning: "接通电话；使经历" },
  { pattern: "get up", type: "phrasal verb", meaning: "起床；站起来" },
  { pattern: "get along with", type: "phrasal verb", meaning: "与…相处融洽" },
  { pattern: "get over", type: "phrasal verb", meaning: "克服；从…恢复过来" },
  { pattern: "get through", type: "phrasal verb", meaning: "完成；通过；度过" },
  { pattern: "get by", type: "phrasal verb", meaning: "勉强过活；凑合" },
  { pattern: "get rid of", type: "phrasal verb", meaning: "摆脱；去除" },
  { pattern: "get back", type: "phrasal verb", meaning: "回来；取回；回复" },
  { pattern: "get off", type: "phrasal verb", meaning: "下车；离开；下班" },
  { pattern: "get on", type: "phrasal verb", meaning: "上车；相处；进展" },
  { pattern: "get along", type: "phrasal verb", meaning: "相处融洽；进展" },
  { pattern: "get down to", type: "phrasal verb", meaning: "开始认真做…" },
  { pattern: "make up", type: "phrasal verb", meaning: "编造；化妆；和解；组成" },
  { pattern: "make out", type: "phrasal verb", meaning: "辨认出；理解；假装" },
  { pattern: "make sense", type: "phrasal verb", meaning: "有意义；讲得通" },
  { pattern: "make sure", type: "phrasal verb", meaning: "确保；确定" },
  { pattern: "make use of", type: "phrasal verb", meaning: "利用；使用" },
  { pattern: "make up for", type: "phrasal verb", meaning: "弥补；补偿" },
  { pattern: "make for", type: "phrasal verb", meaning: "朝…走去；有助于" },
  { pattern: "turn on", type: "phrasal verb", meaning: "打开（电器）；取决于" },
  { pattern: "turn off", type: "phrasal verb", meaning: "关闭（电器）；使失去兴趣" },
  { pattern: "turn up", type: "phrasal verb", meaning: "出现；调高音量" },
  { pattern: "turn down", type: "phrasal verb", meaning: "拒绝；调低音量" },
  { pattern: "turn out", type: "phrasal verb", meaning: "结果是；证明是；生产" },
  { pattern: "turn into", type: "phrasal verb", meaning: "变成；转变为" },
  { pattern: "turn around", type: "phrasal verb", meaning: "转身；扭转；好转" },
  { pattern: "turn over", type: "phrasal verb", meaning: "翻转；移交；仔细考虑" },
  { pattern: "come up with", type: "phrasal verb", meaning: "想出；提出" },
  { pattern: "come across", type: "phrasal verb", meaning: "偶然遇到；给人…印象" },
  { pattern: "come back", type: "phrasal verb", meaning: "回来；恢复；重新流行" },
  { pattern: "come out", type: "phrasal verb", meaning: "出来；出版；结果是" },
  { pattern: "come in", type: "phrasal verb", meaning: "进来；到达；参与" },
  { pattern: "come on", type: "phrasal verb", meaning: "快点；加油；进展" },
  { pattern: "come off", type: "phrasal verb", meaning: "脱落；成功；发生" },
  { pattern: "come along", type: "phrasal verb", meaning: "一起来；进展；出现" },
  { pattern: "go on", type: "phrasal verb", meaning: "继续；发生；进行" },
  { pattern: "go through", type: "phrasal verb", meaning: "经历；仔细检查；通过" },
  { pattern: "go over", type: "phrasal verb", meaning: "仔细检查；复习；走过去" },
  { pattern: "go out", type: "phrasal verb", meaning: "出去；外出；熄灭" },
  { pattern: "go up", type: "phrasal verb", meaning: "上升；上涨；被建造" },
  { pattern: "go down", type: "phrasal verb", meaning: "下降；沉没；被记录" },
  { pattern: "go ahead", type: "phrasal verb", meaning: "前进；继续；说吧" },
  { pattern: "go along with", type: "phrasal verb", meaning: "赞同；附和；一起去" },
  { pattern: "go off", type: "phrasal verb", meaning: "响起（闹铃）；爆炸；变质" },
  { pattern: "go back", type: "phrasal verb", meaning: "回去；追溯" },
  { pattern: "set up", type: "phrasal verb", meaning: "建立；设立；安排" },
  { pattern: "set off", type: "phrasal verb", meaning: "出发；引发；衬托" },
  { pattern: "set out", type: "phrasal verb", meaning: "出发；开始；阐明" },
  { pattern: "set aside", type: "phrasal verb", meaning: "留出；抛开；撤销" },
  { pattern: "set down", type: "phrasal verb", meaning: "记下；写下；放下" },
  { pattern: "run into", type: "phrasal verb", meaning: "偶然遇到；撞上；陷入" },
  { pattern: "run out of", type: "phrasal verb", meaning: "用完；耗尽" },
  { pattern: "run over", type: "phrasal verb", meaning: "碾压；溢出；快速浏览" },
  { pattern: "run through", type: "phrasal verb", meaning: "快速过一遍；贯穿；挥霍" },
  { pattern: "run out", type: "phrasal verb", meaning: "用完；过期；耗尽" },
  { pattern: "bring up", type: "phrasal verb", meaning: "抚养；提出；恶心" },
  { pattern: "bring about", type: "phrasal verb", meaning: "引起；导致；带来" },
  { pattern: "bring back", type: "phrasal verb", meaning: "带回；恢复；使回忆" },
  { pattern: "bring in", type: "phrasal verb", meaning: "引入；引进；赚取" },
  { pattern: "bring down", type: "phrasal verb", meaning: "降低；打倒；使倒下" },
  { pattern: "call off", type: "phrasal verb", meaning: "取消" },
  { pattern: "call for", type: "phrasal verb", meaning: "需要；要求；呼吁" },
  { pattern: "call on", type: "phrasal verb", meaning: "拜访；号召；请…回答" },
  { pattern: "call up", type: "phrasal verb", meaning: "打电话；征召；唤起" },
  { pattern: "call back", type: "phrasal verb", meaning: "回电话；召回" },
  { pattern: "carry out", type: "phrasal verb", meaning: "执行；实施；完成" },
  { pattern: "carry on", type: "phrasal verb", meaning: "继续；坚持；携带登机" },
  { pattern: "cut down", type: "phrasal verb", meaning: "削减；砍倒；减少" },
  { pattern: "cut off", type: "phrasal verb", meaning: "切断；中断；隔离" },
  { pattern: "cut out", type: "phrasal verb", meaning: "剪掉；删除；停止运转" },
  { pattern: "deal with", type: "phrasal verb", meaning: "处理；应对；涉及" },
  { pattern: "end up", type: "phrasal verb", meaning: "最终成为；以…告终" },
  { pattern: "figure out", type: "phrasal verb", meaning: "弄清楚；算出；理解" },
  { pattern: "fill in", type: "phrasal verb", meaning: "填写；填补；暂时替代" },
  { pattern: "fill out", type: "phrasal verb", meaning: "填写（表格）；变丰满" },
  { pattern: "find out", type: "phrasal verb", meaning: "发现；查明；找出" },
  { pattern: "hand in", type: "phrasal verb", meaning: "上交；提交" },
  { pattern: "hand out", type: "phrasal verb", meaning: "分发；给予" },
  { pattern: "hand over", type: "phrasal verb", meaning: "移交；交出" },
  { pattern: "hold on", type: "phrasal verb", meaning: "等一下；坚持住；抓牢" },
  { pattern: "hold up", type: "phrasal verb", meaning: "举起；耽搁；支撑" },
  { pattern: "hold back", type: "phrasal verb", meaning: "抑制；阻碍；隐瞒" },
  { pattern: "hold out", type: "phrasal verb", meaning: "坚持；伸出；维持" },
  { pattern: "keep on", type: "phrasal verb", meaning: "继续；坚持" },
  { pattern: "keep up with", type: "phrasal verb", meaning: "跟上；保持联系" },
  { pattern: "keep in mind", type: "phrasal verb", meaning: "记住；牢记" },
  { pattern: "keep up", type: "phrasal verb", meaning: "保持；继续；跟上" },
  { pattern: "leave out", type: "phrasal verb", meaning: "遗漏；忽略；排除" },
  { pattern: "leave behind", type: "phrasal verb", meaning: "遗留；留下；超过" },
  { pattern: "let down", type: "phrasal verb", meaning: "使失望；放下；降低" },
  { pattern: "live up to", type: "phrasal verb", meaning: "不辜负；达到期望" },
  { pattern: "pay off", type: "phrasal verb", meaning: "还清；取得成功；带来好结果" },
  { pattern: "pay attention to", type: "phrasal verb", meaning: "注意；关注" },
  { pattern: "pick up", type: "phrasal verb", meaning: "捡起；学会；接人；好转" },
  { pattern: "pick out", type: "phrasal verb", meaning: "挑选；认出；分辨出" },
  { pattern: "point out", type: "phrasal verb", meaning: "指出；指明" },
  { pattern: "pull off", type: "phrasal verb", meaning: "成功完成；扯下；停车" },
  { pattern: "pull through", type: "phrasal verb", meaning: "渡过难关；康复" },
  { pattern: "rely on", type: "phrasal verb", meaning: "依赖；依靠；信赖" },
  { pattern: "result in", type: "phrasal verb", meaning: "导致；造成" },
  { pattern: "show off", type: "phrasal verb", meaning: "炫耀；卖弄" },
  { pattern: "show up", type: "phrasal verb", meaning: "出现；露面；使难堪" },
  { pattern: "stand by", type: "phrasal verb", meaning: "支持；袖手旁观；准备行动" },
  { pattern: "stand for", type: "phrasal verb", meaning: "代表；表示；主张" },
  { pattern: "stand out", type: "phrasal verb", meaning: "突出；显眼；出色" },
  { pattern: "stay away", type: "phrasal verb", meaning: "远离；不接近" },
  { pattern: "stay up", type: "phrasal verb", meaning: "熬夜；保持不倒下" },
  { pattern: "stick to", type: "phrasal verb", meaning: "坚持；遵守；黏在" },
  { pattern: "sum up", type: "phrasal verb", meaning: "总结；概括" },
  { pattern: "think about", type: "phrasal verb", meaning: "思考；考虑" },
  { pattern: "think of", type: "phrasal verb", meaning: "想到；想起；认为" },
  { pattern: "think over", type: "phrasal verb", meaning: "仔细考虑" },
  { pattern: "throw away", type: "phrasal verb", meaning: "扔掉；浪费" },
  { pattern: "try out", type: "phrasal verb", meaning: "试用；尝试；试验" },
  { pattern: "wake up", type: "phrasal verb", meaning: "醒来；叫醒；唤醒" },
  { pattern: "work out", type: "phrasal verb", meaning: "锻炼；解决；弄懂；结果是" },
  { pattern: "work on", type: "phrasal verb", meaning: "从事于；致力于" },
  { pattern: "write down", type: "phrasal verb", meaning: "写下；记下" },
  { pattern: "break down", type: "phrasal verb", meaning: "崩溃；分解；出故障" },
  { pattern: "break up", type: "phrasal verb", meaning: "分手；解散；散开" },
  { pattern: "break out", type: "phrasal verb", meaning: "爆发；逃脱；突然出现" },
  { pattern: "break into", type: "phrasal verb", meaning: "闯入；突然开始" },
  { pattern: "fall apart", type: "phrasal verb", meaning: "崩溃；破裂；瓦解" },
  { pattern: "fall behind", type: "phrasal verb", meaning: "落后；跟不上" },
  { pattern: "fall through", type: "phrasal verb", meaning: "失败；落空" },
  { pattern: "drop off", type: "phrasal verb", meaning: "下降；让…下车；打瞌睡" },
  { pattern: "drop out", type: "phrasal verb", meaning: "退出；辍学；脱落" },
  { pattern: "hang out", type: "phrasal verb", meaning: "闲逛；常去某处" },
  { pattern: "hang up", type: "phrasal verb", meaning: "挂断电话；悬挂" },
  { pattern: "pass away", type: "phrasal verb", meaning: "去世；逝世" },
  { pattern: "pass out", type: "phrasal verb", meaning: "昏倒；分发" },
  { pattern: "pass on", type: "phrasal verb", meaning: "传递；传给；去世" },
  { pattern: "die out", type: "phrasal verb", meaning: "灭绝；消亡；逐渐消失" },
  { pattern: "die down", type: "phrasal verb", meaning: "逐渐减弱；平息" },

  // ===== Prepositional Phrases (介词短语) =====
  { pattern: "in addition to", type: "prepositional", meaning: "除…之外" },
  { pattern: "in front of", type: "prepositional", meaning: "在…前面" },
  { pattern: "in spite of", type: "prepositional", meaning: "尽管；不顾" },
  { pattern: "in terms of", type: "prepositional", meaning: "就…而言；在…方面" },
  { pattern: "in favor of", type: "prepositional", meaning: "支持；赞成；有利于" },
  { pattern: "in case of", type: "prepositional", meaning: "万一；如果发生" },
  { pattern: "in charge of", type: "prepositional", meaning: "负责；掌管" },
  { pattern: "in search of", type: "prepositional", meaning: "寻找；寻求" },
  { pattern: "in need of", type: "prepositional", meaning: "需要" },
  { pattern: "in place of", type: "prepositional", meaning: "代替" },
  { pattern: "in relation to", type: "prepositional", meaning: "关于；与…有关" },
  { pattern: "in response to", type: "prepositional", meaning: "作为对…的回应" },
  { pattern: "in contrast to", type: "prepositional", meaning: "与…形成对比" },
  { pattern: "in accordance with", type: "prepositional", meaning: "根据；按照" },
  { pattern: "in comparison with", type: "prepositional", meaning: "与…相比" },
  { pattern: "in connection with", type: "prepositional", meaning: "与…有关" },
  { pattern: "in line with", type: "prepositional", meaning: "与…一致；符合" },
  { pattern: "in touch with", type: "prepositional", meaning: "与…保持联系" },
  { pattern: "in regard to", type: "prepositional", meaning: "关于；至于" },
  { pattern: "in view of", type: "prepositional", meaning: "鉴于；考虑到" },
  { pattern: "in exchange for", type: "prepositional", meaning: "作为…的交换" },
  { pattern: "in the course of", type: "prepositional", meaning: "在…过程中" },
  { pattern: "on behalf of", type: "prepositional", meaning: "代表；为了" },
  { pattern: "on the basis of", type: "prepositional", meaning: "基于；根据" },
  { pattern: "on account of", type: "prepositional", meaning: "因为；由于" },
  { pattern: "on the point of", type: "prepositional", meaning: "即将…的时候" },
  { pattern: "on top of", type: "prepositional", meaning: "在…之上；除…之外" },
  { pattern: "on the verge of", type: "prepositional", meaning: "濒临；即将" },
  { pattern: "at the expense of", type: "prepositional", meaning: "以…为代价" },
  { pattern: "at the same time", type: "prepositional", meaning: "同时" },
  { pattern: "at the moment", type: "prepositional", meaning: "此刻；目前" },
  { pattern: "at first", type: "prepositional", meaning: "起初；最初" },
  { pattern: "at last", type: "prepositional", meaning: "终于；最后" },
  { pattern: "at least", type: "prepositional", meaning: "至少" },
  { pattern: "at most", type: "prepositional", meaning: "最多；至多" },
  { pattern: "at once", type: "prepositional", meaning: "立刻；马上；同时" },
  { pattern: "at present", type: "prepositional", meaning: "目前；现在" },
  { pattern: "at risk", type: "prepositional", meaning: "处于危险中" },
  { pattern: "by means of", type: "prepositional", meaning: "通过…方式；依靠" },
  { pattern: "by the way", type: "prepositional", meaning: "顺便说一下" },
  { pattern: "by chance", type: "prepositional", meaning: "偶然；碰巧" },
  { pattern: "by accident", type: "prepositional", meaning: "偶然地；意外地" },
  { pattern: "by no means", type: "prepositional", meaning: "决不；一点也不" },
  { pattern: "by far", type: "prepositional", meaning: "显然；…得多" },
  { pattern: "for example", type: "prepositional", meaning: "例如" },
  { pattern: "for instance", type: "prepositional", meaning: "例如" },
  { pattern: "for the purpose of", type: "prepositional", meaning: "为了…的目的" },
  { pattern: "for the sake of", type: "prepositional", meaning: "为了…的利益" },
  { pattern: "with regard to", type: "prepositional", meaning: "关于；至于" },
  { pattern: "with respect to", type: "prepositional", meaning: "关于；就…而言" },
  { pattern: "with the exception of", type: "prepositional", meaning: "除…之外" },
  { pattern: "as a result of", type: "prepositional", meaning: "由于…的结果" },
  { pattern: "as a matter of fact", type: "prepositional", meaning: "事实上" },
  { pattern: "as well as", type: "prepositional", meaning: "也；和；以及" },
  { pattern: "as far as", type: "prepositional", meaning: "就…而言；远至" },
  { pattern: "as if", type: "prepositional", meaning: "仿佛；好像" },
  { pattern: "as though", type: "prepositional", meaning: "仿佛；好像" },
  { pattern: "out of control", type: "prepositional", meaning: "失控" },
  { pattern: "out of date", type: "prepositional", meaning: "过时的；过期的" },
  { pattern: "out of order", type: "prepositional", meaning: "发生故障；次序混乱" },
  { pattern: "out of reach", type: "prepositional", meaning: "够不着；遥不可及" },
  { pattern: "out of sight", type: "prepositional", meaning: "看不见；在视线之外" },
  { pattern: "out of work", type: "prepositional", meaning: "失业" },
  { pattern: "out of touch", type: "prepositional", meaning: "失去联系" },
  { pattern: "out of the question", type: "prepositional", meaning: "不可能的" },
  { pattern: "up to date", type: "prepositional", meaning: "最新的；现代的" },

  // ===== Fixed Collocations (固定搭配) =====
  { pattern: "catch sight of", type: "collocation", meaning: "看到；瞥见" },
  { pattern: "keep pace with", type: "collocation", meaning: "跟上…的步伐" },
  { pattern: "give rise to", type: "collocation", meaning: "引起；导致" },
  { pattern: "have access to", type: "collocation", meaning: "可以使用；可以进入" },
  { pattern: "play a role in", type: "collocation", meaning: "在…中起作用" },
  { pattern: "put emphasis on", type: "collocation", meaning: "重视；强调" },
  { pattern: "lose touch with", type: "collocation", meaning: "与…失去联系" },
  { pattern: "make a difference", type: "collocation", meaning: "有影响；起作用" },
  { pattern: "shed light on", type: "collocation", meaning: "阐明；为…提供解释" },
  { pattern: "take into account", type: "collocation", meaning: "考虑到；顾及" },
  { pattern: "bear in mind", type: "collocation", meaning: "记住；考虑到" },
  { pattern: "draw attention to", type: "collocation", meaning: "引起对…的注意" },
  { pattern: "gain access to", type: "collocation", meaning: "获得进入/使用权" },
  { pattern: "have an impact on", type: "collocation", meaning: "对…有影响" },
  { pattern: "keep an eye on", type: "collocation", meaning: "留意；照看" },
  { pattern: "make an effort", type: "collocation", meaning: "努力；尽力" },
  { pattern: "take responsibility for", type: "collocation", meaning: "为…负责" },
  { pattern: "give careful consideration", type: "collocation", meaning: "仔细考虑" },
  { pattern: "make progress", type: "collocation", meaning: "取得进步" },
  { pattern: "take action", type: "collocation", meaning: "采取行动" },
  { pattern: "make a decision", type: "collocation", meaning: "做决定" },
  { pattern: "take measures", type: "collocation", meaning: "采取措施" },
  { pattern: "play an important role", type: "collocation", meaning: "扮演重要角色" },
  { pattern: "provide evidence", type: "collocation", meaning: "提供证据" },
  { pattern: "receive attention", type: "collocation", meaning: "受到关注" },
  { pattern: "seek help", type: "collocation", meaning: "寻求帮助" },
  { pattern: "take steps", type: "collocation", meaning: "采取步骤" },
  { pattern: "raise awareness", type: "collocation", meaning: "提高意识" },
  { pattern: "offer assistance", type: "collocation", meaning: "提供帮助" },
  { pattern: "have difficulty", type: "collocation", meaning: "有困难" },
  { pattern: "give advice", type: "collocation", meaning: "提供建议" },
  { pattern: "make arrangements", type: "collocation", meaning: "做安排" },
  { pattern: "take a break", type: "collocation", meaning: "休息一下" },
  { pattern: "keep a promise", type: "collocation", meaning: "遵守诺言" },
  { pattern: "break a promise", type: "collocation", meaning: "违背诺言" },
  { pattern: "take turns", type: "collocation", meaning: "轮流" },
  { pattern: "make a choice", type: "collocation", meaning: "做出选择" },
  { pattern: "have an opportunity", type: "collocation", meaning: "有机会" },
  { pattern: "seize an opportunity", type: "collocation", meaning: "抓住机会" },
  { pattern: "reach an agreement", type: "collocation", meaning: "达成协议" },
  { pattern: "come to a conclusion", type: "collocation", meaning: "得出结论" },
  { pattern: "put pressure on", type: "collocation", meaning: "对…施加压力" },
  { pattern: "play a part in", type: "collocation", meaning: "在…中发挥作用" },
  { pattern: "take control of", type: "collocation", meaning: "控制" },
  { pattern: "lose control of", type: "collocation", meaning: "失去对…的控制" },

  // ===== Idioms (习语) =====
  { pattern: "piece of cake", type: "idiom", meaning: "小菜一碟；非常容易" },
  { pattern: "break a leg", type: "idiom", meaning: "祝你成功；祝你好运" },
  { pattern: "hit the books", type: "idiom", meaning: "用功学习；啃书本" },
  { pattern: "once in a blue moon", type: "idiom", meaning: "千载难逢；十分罕见" },
  { pattern: "under the weather", type: "idiom", meaning: "身体不适；不舒服" },
  { pattern: "a drop in the bucket", type: "idiom", meaning: "沧海一粟；杯水车薪" },
  { pattern: "beat around the bush", type: "idiom", meaning: "拐弯抹角；旁敲侧击" },
  { pattern: "bite the bullet", type: "idiom", meaning: "硬着头皮面对；咬紧牙关" },
  { pattern: "call it a day", type: "idiom", meaning: "收工；到此为止" },
  { pattern: "cut corners", type: "idiom", meaning: "偷工减料；走捷径" },
  { pattern: "see eye to eye", type: "idiom", meaning: "看法一致；意见相同" },
  { pattern: "the ball is in your court", type: "idiom", meaning: "轮到你做决定了" },
  { pattern: "break the ice", type: "idiom", meaning: "打破沉默；缓和气氛" },
  { pattern: "burn the midnight oil", type: "idiom", meaning: "挑灯夜战；熬夜工作" },
  { pattern: "face the music", type: "idiom", meaning: "面对现实；承担后果" },
  { pattern: "hit the nail on the head", type: "idiom", meaning: "一针见血；说到点子上" },
  { pattern: "let the cat out of the bag", type: "idiom", meaning: "泄露秘密；说漏嘴" },
  { pattern: "miss the boat", type: "idiom", meaning: "错失良机" },
  { pattern: "on the ball", type: "idiom", meaning: "机灵；警觉；有效的" },
  { pattern: "pull someone's leg", type: "idiom", meaning: "开某人玩笑；逗某人" },
  { pattern: "rain cats and dogs", type: "idiom", meaning: "下倾盆大雨" },
  { pattern: "sit on the fence", type: "idiom", meaning: "骑墙观望；保持中立" },
  { pattern: "spill the beans", type: "idiom", meaning: "泄露秘密；说漏嘴" },
  { pattern: "take it easy", type: "idiom", meaning: "放轻松；别紧张" },
  { pattern: "the best of both worlds", type: "idiom", meaning: "两全其美" },
  { pattern: "throw in the towel", type: "idiom", meaning: "认输；放弃" },
  { pattern: "when pigs fly", type: "idiom", meaning: "不可能的事" },
  { pattern: "actions speak louder than words", type: "idiom", meaning: "事实胜于雄辩" },
  { pattern: "a blessing in disguise", type: "idiom", meaning: "因祸得福" },
  { pattern: "barking up the wrong tree", type: "idiom", meaning: "找错对象；弄错原因" },
  { pattern: "cost an arm and a leg", type: "idiom", meaning: "花费一大笔钱" },
  { pattern: "hit the sack", type: "idiom", meaning: "上床睡觉" },
  { pattern: "kill two birds with one stone", type: "idiom", meaning: "一石二鸟；一举两得" },
  { pattern: "speak of the devil", type: "idiom", meaning: "说曹操曹操到" },
  { pattern: "steal the show", type: "idiom", meaning: "抢风头；出尽风头" },
  { pattern: "take with a grain of salt", type: "idiom", meaning: "对…持保留态度" },
  { pattern: "the elephant in the room", type: "idiom", meaning: "显而易见却被回避的问题" },
  { pattern: "the last straw", type: "idiom", meaning: "压垮骆驼的最后一根稻草" },
  { pattern: "up in the air", type: "idiom", meaning: "悬而未决" },
  { pattern: "cross that bridge when you come to it", type: "idiom", meaning: "船到桥头自然直" },
];

function tokenize(text: string): { tokens: string[]; offsetMap: Map<number, number> } {
  const lowered = text.toLowerCase();
  const tokens: string[] = [];
  const offsetMap = new Map<number, number>();
  let i = 0;
  while (i < lowered.length) {
    const code = lowered.charCodeAt(i);
    if ((code >= 97 && code <= 122) || (code >= 48 && code <= 57)) {
      const start = i;
      while (i < lowered.length &&
        ((lowered.charCodeAt(i) >= 97 && lowered.charCodeAt(i) <= 122) ||
         (lowered.charCodeAt(i) >= 48 && lowered.charCodeAt(i) <= 57))) {
        i++;
      }
      offsetMap.set(tokens.length, start);
      tokens.push(lowered.substring(start, i));
    } else if (lowered[i] === "'" &&
      i > 0 && i + 1 < lowered.length &&
      lowered.charCodeAt(i - 1) >= 97 && lowered.charCodeAt(i - 1) <= 122 &&
      lowered.charCodeAt(i + 1) >= 97 && lowered.charCodeAt(i + 1) <= 122) {
      const last = tokens[tokens.length - 1];
      tokens[tokens.length - 1] = last + "'";
      i++;
      if (i < lowered.length && lowered.charCodeAt(i) >= 97 && lowered.charCodeAt(i) <= 122) {
        const cStart = i;
        while (i < lowered.length && lowered.charCodeAt(i) >= 97 && lowered.charCodeAt(i) <= 122) {
          i++;
        }
        tokens[tokens.length - 1] += lowered.substring(cStart, i);
      }
    } else {
      i++;
    }
  }
  return { tokens, offsetMap };
}

const phraseCache = new Map<string, RecognizedPhrase[]>();

function phraseKey(pat: string): string {
  return pat.replace(/\s+/g, "_");
}

function computeConfidence(wordCount: number, type: string): number {
  let base = 0.85;
  if (wordCount >= 5) base = 0.97;
  else if (wordCount >= 4) base = 0.94;
  else if (wordCount >= 3) base = 0.91;
  else if (wordCount >= 2) base = 0.88;
  const typeBonus = type === "idiom" ? 0.03 : type === "prepositional" ? 0.02 : 0;
  return Math.min(0.99, base + typeBonus);
}

export function recognizePhrases(sentenceText: string): RecognizedPhrase[] {
  if (!sentenceText) return [];
  const cacheKey = sentenceText;
  const cached = phraseCache.get(cacheKey);
  if (cached) return cached;

  const { tokens, offsetMap } = tokenize(sentenceText);
  if (tokens.length === 0) return [];

  const phraseWords = PHRASE_PATTERNS.map(p => ({
    words: p.pattern.split(" "),
    pattern: p.pattern,
    type: p.type,
    meaning: p.meaning,
  }));

  const matches: RecognizedPhrase[] = [];
  const covered = new Set<string>();

  for (let winSize = Math.min(tokens.length, 12); winSize >= 1; winSize--) {
    for (let start = 0; start + winSize <= tokens.length; start++) {
      const slice = tokens.slice(start, start + winSize).join(" ");
      for (const pw of phraseWords) {
        if (pw.words.length !== winSize) continue;
        if (pw.pattern !== slice) continue;
        const key = `${start}-${start + winSize}`;
        let isOverlapped = false;
        for (const c of covered) {
          const [cs, ce] = c.split("-").map(Number);
          if (!(start + winSize <= cs || start >= ce)) { isOverlapped = true; break; }
        }
        if (isOverlapped) continue;
        const startOff = offsetMap.get(start)!;
        let endIdx = start + winSize - 1;
        const endOffMap = offsetMap.get(endIdx);
        let endOff = endOffMap !== undefined ? endOffMap + tokens[endIdx].length : startOff + slice.length;
        endOff = Math.min(endOff, sentenceText.length);
        covered.add(key);
        matches.push({
          phraseKey: phraseKey(pw.pattern),
          text: sentenceText.substring(startOff, endOff),
          type: pw.type,
          meaning: pw.meaning,
          startOffset: startOff,
          endOffset: endOff,
          confidence: computeConfidence(winSize, pw.type),
        });
        break;
      }
    }
  }

  matches.sort((a, b) => a.startOffset - b.startOffset);
  phraseCache.set(cacheKey, matches);
  return matches;
}

export function getPhrasesByType(): Record<string, RecognizedPhrase[]> {
  const groups: Record<string, RecognizedPhrase[]> = {};
  for (const p of PHRASE_PATTERNS) {
    const key = phraseKey(p.pattern);
    const entry: RecognizedPhrase = {
      phraseKey: key,
      text: p.pattern,
      type: p.type,
      meaning: p.meaning,
      startOffset: 0,
      endOffset: 0,
      confidence: computeConfidence(p.pattern.split(" ").length, p.type),
    };
    if (!groups[p.type]) groups[p.type] = [];
    groups[p.type].push(entry);
  }
  return groups;
}
