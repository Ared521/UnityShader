# Edge、Scan(边缘光、流光)
## 1. 边缘光：
* 1、计算出物体的世界空间坐标，法线在世界空间下的坐标，view在世界空间下的向量方向(摄像机在世界空间下的坐标 - 物体在世界空间下的坐标)
* 2、计算世界坐标系下的法线向量，有两种代码方法：
```
normal_WorldDir = normalize(UnityObjectToWorldNormal(v.normal));
normal_WorldDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
```
* 3、求NdotV，即max(0, 法线向量和view向量点乘)，可以配合上边缘强度系数做pow计算，计算出最终的 fragment shader return 的 a 通道的值
```
float fresnel = 1 - pow((1 - NdotV), _EdgeIntensity);
```
* 4、ZWrite Off
* 5、混合模式为 Blend SrcAlpha One 或 Blend SrcAlpha OneMinusSrcAlpha

## 2. 流光：
* 1、计算出物体的世界空间坐标
* 2、齐次坐标概念，4维向量最后一位：1表示点，0表示向量。假设模型身上有一点 xyz:(0, 0, 0)，也转换到世界坐标系下: 
```
pos_ZeroToWorld = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
```
* 3、计算流光采样的uv：通过物体世界空间坐标的x,y值，作为u,v采样。将模型顶点的世界空间坐标x,y值减去假设的模型身上的(0, 0, 0)的世界空间坐标x,y值
```
uv_WorldPos = (o.pos_World.xy - o.pos_ZeroToWorld.xy);
```
* 4、加上时间函数，tex2D采样流光贴图:
```
half2 scan_UV = (i.uv_WorldPos + (_ScanSpeed * _Time.y));
half4 scanColor = tex2D(_ScanTex, scan_UV) * _BloomIntensity;
```

<div align=center>
<img src="https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/Edge%26Scan.gif" width="800" height="400">
</div>
