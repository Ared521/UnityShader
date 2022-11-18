# Unity Shader Effects
## 记录学习Kerry Unity Shader课程的效果，新效果也会持续更新 ~ ~ ~

> unity版本：2021.3.13

> 实现的效果 demo 都放在 Effects 文件夹，欢迎各位大佬交流指正

> ### $\color{yellow}{点击效果名称，查看效果 demo 实现详情}$

> 暂时还不会做模型和贴图，示例中的模型来自别的课程和工程中= =
---

## 1、[Edge、Scan(边缘光、流光)](https://github.com/Ared521/UnityShader/tree/main/Assets/Effects/1_Scan%20&%20Edge)
![img](https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/Edge%26Scan.gif)

---
## 2、[Stencil Test(模板测试)](https://github.com/Ared521/UnityShader/tree/main/Assets/Effects/2_Stencil%20Test)
![img](https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/StencilTest_1.gif)

> 原神里有一个场景是人物站在纸窗户后面，能够从纸窗户看到人的影子，这里实现方式用一个球代替人物模型，球正常渲染，球的子物体设置一个跟球大小一样的物体，shader 设置为模板测试代码，效果示例：

![img](https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/StencilTest_2.gif)

---
## 3、[IBL、SH(基于图片照明、球谐光照)](https://github.com/Ared521/UnityShader/tree/main/Assets/Effects/4_IBL%26SH)
![image](https://user-images.githubusercontent.com/104584816/201355414-ce565b4b-5ee5-4de8-82b0-d1a5d5a1ecc9.png)

---
## 4、[光照模型(Blinn-Phong、PBR)](https://www.yuque.com/u27384247/pkfic1/ruk770)
![image](https://user-images.githubusercontent.com/104584816/201355414-ce565b4b-5ee5-4de8-82b0-d1a5d5a1ecc9.png)
