# 1.消息

protobuf中的基本消息体是messege，message由一个或多个字段组成，一个message可以认为是C中的结构体，定义在XXX.proto文件中
基本语法：

![](D:\study_record\note\protobuf\930d40928c862ea95c0b0634beab68a3.png)

## 1.1 字段类型

| .proto Type | Notes                                                     | C++ Type |
| ----------- | --------------------------------------------------------- | -------- |
| double      |                                                           | double   |
| float       |                                                           | float    |
| int32       | 32位符号整型，使用可变长度编码，数值越小，占用的字节越少。编码负数效率低——如果字段可能有负值，使用sint32 | int32    |
| int64       | 64位符号整型，其余同上                                              | int64    |
| uint32      | 32位无符号整型                                                  | uint32   |
| uint64      | 64位无符号整型                                                  | uint64   |
| sint32      | 32位符号整型，负值效率比int32高很多                                     | int32    |
| sint64      | 64位符号整型，负值效率比int64高很多                                     | int64    |
| fixed32     | 固定4字节长度编码. 如果值经常大于228，则比uint32效率更高                        | uint32   |
| fixed64     | 固定8字节长度编码. 如果值经常大于256，则比uint64效率更高                        | uint64   |
| sfixed32    | 固定4字节长度编码                                                 | int32    |
| sfixed64    | 固定8字节长度编码                                                 | int64    |
| bool        |                                                           | bool     |
| string      | 字符串必须始终包含UTF-8编码或7位ASCII文本，值不能超过232                       | string   |
| bytes       | 可以包含任何值不超过232的任意字节序列                                      | string   |

## 1.2 字段编号

消息定义中的每个字段必须赋予一个介于 1 和 536,870,911 之间的数字，但有以下限制：

- 给定的数字在该消息的所有字段中必须是唯一的。

- 字段号 19,000 到 19,999 是为协议缓冲区实现保留的。如果您在消息中使用这些保留字段号之一，协议缓冲区编译器会报错。

- 不能使用任何以前保留的字段号或任何已分配给扩展的字段号

- 一旦您的消息类型开始使用，此数字就无法更改，因为它用于标识消息有线格式中的字段。“更改”字段编号相当于删除该字段并创建具有相同类型但新编号的新字段。

- 字段号永远不应重复使用。

- 切勿从保留列表中取出字段号以用于新的字段定义。

- 对于最常设置的字段，应该使用字段编号 1 到 15。较低的字段数值在线路格式中占用的空间较少。例如，1 到 15 范围内的字段编号占用一个字节进行编码。16 到 2047 范围内的字段编号占用两个字节。

# 2.生成C++代码

安装编译器：

```
sudo apt install -y protobuf-compiler
```

编译：

```
protoc --proto_path=<proto 文件目录> --cpp_out=<输出目录> <proto 文件>
```

# 2. C++ API

- `bool SerializeToString(string* output) const;`: serializes the message and stores the bytes in the given string. Note that the bytes are binary, not text; we only use the `string` class as a convenient container.
- `bool ParseFromString(const string& data);`: parses a message from the given string.
- `bool SerializeToOstream(ostream* output) const;`: writes the message to the given C++ `ostream`.
- `bool ParseFromIstream(istream* input);`: parses a message from the given C++ `istream`.
- <字段类型> <字段名>() const;: 字段值获取函数
- set_<字段名>(const <字段类型> value);: 设置字段值
- clear_<字段名>();: 清空字段值