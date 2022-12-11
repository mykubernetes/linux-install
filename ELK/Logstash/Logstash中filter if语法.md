# 一、介绍

- 和其他编程语言中的if判断类似
- 可以使用的符号：
  - `in`
  - `not`
  - `==`
  - `!=`
  - `<=`
  - `>=`
  - `<`
  - `>`
  - `=~`
  - `!~`
  - `and`
  - `or`
  - `xor`
  - `nand`

语法：
```
if EXPRESSION {
  ...
} else if EXPRESSION {
  ...
} else {
  ...
}
```

# 二、示例
```
input{
    syslog{
        port => "514"
        add_field => {
            "flag" => "person"
        }
    }
}
filter{
    if [flag] == "person"{
        grok{
            match => {
                "message" => "%{WORD:word} %{NUMBER:age}"
            }
        }
    }
}
```

```
{
	"message" => "Jack 183",
	"flag" => "person",
	"word" => "Jack",
	"age" => "183",
```

参考：
- https://blog.csdn.net/feizuiku0116/article/details/124491193
