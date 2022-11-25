# Unity 中的光照

## 1. 基础光照: Lambert、Half Lambert、Phong、Blinn-Phong、[PBR](https://github.com/Ared521/UnityShader/tree/main/Assets/Effects/5_PBR)
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/203103228-eeeae2e5-c8ef-4b32-afa5-1847c2d6d9e1.png" width="800" height="400">
</div>

---
## 2. [Unity 的渲染路径、光源类型](https://github.com/Ared521/UnityShader/tree/main/Assets/FengLL_Book/6%20%26%209%20%26%2018_LightingModel/Scenes/RenderingPath)

---
## 3. 多光源([详情参考上一条: Unity 的渲染路径、光源类型](https://github.com/Ared521/UnityShader/tree/main/Assets/FengLL_Book/6%20%26%209%20%26%2018_LightingModel/Scenes/RenderingPath))
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202725156-faab04a3-f5db-4e75-af97-9e484e7b2586.png" width="800" height="550">
</div>

---
## 4. 衰减、阴影
<details>
<summary>笔记展开 ~ </summary>

### 1. 衰减(两种方式)
#### 1）采样衰减纹理贴图: 
* Unity 默认使用纹理查找的方式来计算逐像素的点光源和聚光灯的衰减。缺点: 1、需要预处理得到的采样纹理，纹理的大小也会影响精度。2、不直观，无法使用数据公式来计算衰减。
* Unity在内部使用一张名为 _LightTexture0 的纹理来计算光源衰减。需要注意的是，如果我们对该光源使用了 cookie，那么衰减查找纹理是 _LightTextureB0，这里不讨论这种情况。我们通常只关心 _LightTexture0 对角线上的纹理颜色值，这些值表明了在光源空间中不同位置的点的衰减值。例如，(0, 0)点表明了与光源位置重合的点的衰减值，而(1, 1)点表明了在光源空间中所关心的距离最远的点的衰减。
* 为了对 _LightTexture0 纹理采样得到给定点到该光源的衰减值，我们首先需要得到该点在光源空间中的位置，通过把顶点从世界空间变换到光源空间的变换矩阵 _LightMatrix0，**得到该顶点在光源空间坐标下的位置。**
* 使用了光源空间中顶点距离的平方(通过dot函数来得到，又因为是对对角线采样)来对纹理采样，之所以没有使用距离值来采样是因为这种方法可以避免开方操作。然后，我们使用宏 UNITY_ATTEN_CHANNEL 来得到衰减纹理中衰减值所在的分量，以得到最终的衰减值。
```
  float3 lightCoord = mul(_LightMatrix0, float4(i.worldPosition, 1)).xyz;
  fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
```

#### 2）使用数学公式: 
* 无法在 shader 中通过内置变量得到光源的范围、聚光灯的朝向、张开角度等信息。如果物体不在光源的照明范围内，Unity 不会为物体执行 Additional Pass。我们可以通过 **脚本** 将光源信息传递给 shader。
```
  float distance = length(_WorldSpaceLightPos0.xyz - i.worldPosition.xyz);
  atten = 1.0 / distance; // linear attenuation
```
</details>

## 2. 阴影(书中笔记待整理 ~ )
---
## 5. UnityCG.cginc 中的一些常用的帮助函数
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202622070-46e296cf-def5-403a-9527-58d6063a720b.png" width="800" height="1350">
</div>
