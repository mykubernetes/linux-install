
```
input {
    file {
       type => "e_mall-bank"
       path => "/var/logs/*.log"
       start_position => "beginning"
       codec=>multiline{
                pattern => "\s*\["
                negate => true
                what => "previous"
        }

    }
}
```
- pattern: 必须的设置，要匹配的正则表达式。
- negate: 可选值（false,true）.true表示匹配模式的内容将成为匹配项，被what应用，即取反。false为默认值。
- what必须设置，可选值(previous，next).如果模式匹配，则事件是属于下一个事件还是上一个事件，即指定将匹配到的行与前面的行合并还是后面的行合并。
