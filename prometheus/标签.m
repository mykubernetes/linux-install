| ACTION | Regex匹配 | 操作对象 | 重要参数 | 描述 |
|--------|-----------|--------|--------|------|
| keep | 标签值 | Target | 源标签、regex | 丢弃指定源标签的标签值没有匹配到regex的target |
| Drop | 标签值 | Target | 源标签、regex | 丢弃指定源标签的标签值匹配到regex的target |
| labeldrop | 标签名 | Label | Regex | 丢弃匹配到regex 的标签 |
| labelkeep | 标签名 | Label | Regex | 丢弃没有匹配到regex 的标签 |
| Replace | 标签值 | Label名+值 	源标签、目标标签、替换（值）、regex（值） | 更改标签名、更改标签值、合并标签 |
| hashmod | 无 | 标签名+值 | 源标签、hash长度、target标签  | 将多个源标签的值进行hash，作为target标签的值 |
| labelmap | 标签名 | 标签名 | regex、replacement | Regex匹配名->replacement用原标签名的部分来替换名 |
