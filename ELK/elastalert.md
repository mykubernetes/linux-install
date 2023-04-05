ElastAlert是一个开源的工具,用于从Elastisearch中检索数据,并根据匹配模式发出告警。  
github项目地址如下:https://github.com/Yelp/elastalert  
官方文档如下:https://elastalert.readthedocs.io/en/latest/elastalert.html  

它支持多种监控模式和告警方式,具体可以查阅Github项目介绍.但是自带的ElastAlert并不支持钉钉告警,在github上有第三方的钉钉python项目。地址如下:https://github.com/xuyaoqiang/elastalert-dingtalk-plugin

ElastAlert 有以下特点：
- 支持多种匹配规则（频率、阈值、数据变化、黑白名单、变化率等）。
- 支持多种告警类型（邮件、HTTP POST、自定义脚本等）。
- 支持用户自定义规则和告警类型。
- 匹配项汇总报警，重复告警抑制，告警失败重试和过期。
- 可用性强，状态信息保存到 Elasticsearch 的索引中。
- 支持调试和审计。
