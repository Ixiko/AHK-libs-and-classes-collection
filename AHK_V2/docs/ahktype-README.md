# 库名称：Ahktype

---

## 目录

1. 库简介
2. 库使用方法
3. 库依赖
4. 库结构
5. 关于作者
6. 更新日志（已更新至1.0.1）

---

## 库简介
### 库定位
是为了加强AHK自带的各种类型，通过修改原始值属性以达到有关目的。
### 库特点
纯AutoHotkey实现，尽可能使各类型使用简洁方便。
### 版本信息
2022.11.08 发布1.0.1版本
2022.11.03 发布1.0.0版本

---

## 库使用方法
在正常使用原有AHK各种类型的前提下，提供了许多方便的属性，例如 ``` "".join([1,2,3]) ```

## 库依赖
Ahktype -> print | std

## 库结构
### 抽象模型，具体结构见源代码
```
Ahktype
底层函数：DefProp & DelProp
├── Common                    // 通用
│   ├── Array                    // 转换数组函数（对除数组外类型有效）
│   ├── Dims/NDim                    // 维度定义
│   ├── In                    // 包含函数
│   ├── Range                    // 区间转换定义（对整数、浮点数、字符串有效）
│   ├── Shape                    // 形状定义
│   ├── Sign                    // 符号定义（对整数、浮点数、字符串有效）
├── Interger                    // 整数
│   ├── Bit_Count                    // 二进制“1”计数函数
│   ├── Bit_Length                    // 二进制长度函数
│   ├── ToBase                    // 进制转换函数
├── Float                    // 浮点数
├── String                    // 字符串
│   ├── Decode                    // 解密函数
│   ├── Encode                    // 加密函数
│   ├── Format                    // 格式化函数
│   ├── Join                    // 拼接函数
│   ├── Replace                    // 替值函数
│   ├── Type                    // 字符串属性定义（包括"Base64", "Bytes", "String", "Unicode", "Url", "Utf-8"中的任意一种）（正在完善）
├── Array                    // 数组
│   ├── Append                    // 添加函数
│   ├── Copy                    // 拷贝函数
│   ├── Count                    // 计数函数
│   ├── Extend                    // 延展函数
│   ├── Index                    // 查找第一个符合值索引函数
│   ├── Insert                    // 插入函数
│   ├── IReshape                    // 变形函数
│   ├── Item                    // 多维取值函数
│   ├── Max                    // 最大值函数
│   ├── MaxDim                    // 最大维度函数
│   ├── MaxDimIndex                    // 最大维度索引函数
│   ├── MaxLength                    // 某一维度的最长子序列长度函数
│   ├── Min                    // 最小值函数
│   ├── MinDim                    // 最小维度函数
│   ├── MinDimIndex                    // 最小维度索引函数
│   ├── Mul                    // 乘法函数
│   ├── Product                    // 求积函数
│   ├── Ravel                    // 展平函数
│   ├── Remove                    // 移除函数
│   ├── Reshape                    // 变形函数
│   ├── Reverse                    // 反转函数
│   ├── SetItem                    // 多维赋值函数
│   ├── Size                    // 面积函数
│   ├── Sort                    // 排序函数
│   ├── Standardization                    // 规整化（矩阵化）函数
│   ├── Sum                    // 求和函数
│   ├── Swap                    // 交换函数
├── Map                    // 字典
│   ├── Copy                    // 拷贝函数
│   ├── FromKeys                    // 增键函数
│   ├── Items                    // 键值对转数组函数
│   ├── Keys                    // 键序列转数组函数
│   ├── Pop                    // 移除函数（返回指定值）
│   ├── PopItem                    // 移除键值对（返回指定值）
│   ├── Setdefault                    // 添加键赋默认值
│   ├── Sort                    // 键值对序列转数组排序函数
│   ├── Update                    // 更新函数
│   ├── Values                    // 值序列转数组函数
├── Object                    // AHK所有类对象统一属性
│   ├── Copy                    // 拷贝函数
│   ├── Extends                    // 继承函数
```

---

## 关于作者
Mono，另名MonoEven，在AutoHotkey v2研究上有较深理解

---

## 更新日志
### 已更新至1.0.1
1. 修复了一些Bug
2. 更改了一些冗余的源代码
3. 新增(int)._.(int)和(int).._的语法糖
```
a := numahk.array([1,2,[1,3]])
debug a[2._.3, 1._.2] ; equal to a["2:3", "1:2"]
debug a[2.._, 1.._] ; equal to a["2:", "1:"]
```
4.删除Object的大量冲突属性，保留Copy，新增Extends
### 已更新至1.0.0
1. 更新了README.md