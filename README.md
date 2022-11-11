# Learn Unity Shader
记录学习Kerry Unity Shader课程和《Unity Shader入门精要》

实现的效果 demo 都放在 Effects 文件夹，在之后的学习过程中会持续更新 ~ ~ ~ 

unity版本：2020.3.19

## 边缘光、流光
技术文档：[边缘光、流光](https://www.yuque.com/u27384247/pkfic1/au7hal)
![img](https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/Edge%26Scan.gif)

## Stencil Test
技术文档：[Stencil Test](https://www.yuque.com/u27384247/pkfic1/yfsabt)

深度测试示例：
![img](https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/StencilTest_1.gif)

原神里有一个场景是人物穿过一面纸窗户，能够看到人的影子，这里实现方式用一个球代替人物模型，球正常渲染，球的子物体设置一个跟球大小一样的物体，shader设置为模板测试代码，效果如下：
![img](https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/StencilTest_2.gif)
