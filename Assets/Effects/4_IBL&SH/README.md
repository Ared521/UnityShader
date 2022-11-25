# IBL & SH (基于图片照明 & 球谐光照)
## 1、IBL:
### 1.1 IBL 执行流程:
* 1、需要的数据有：cubeMap、AOMap、RoughnessMap。
* 2、根据cubeMap的原理，先求出反射向量，代码如下：
```
    half3 cubeMap_ReflectDir = reflect(-view_WorldDir, i.normal_WorldDir);
```
* 3、根据粗糙度，求mipmap层级，然后使用texCUBElod采样，代码如下：
```
    half roughness = tex2D(_RoughnessMap, i.uv).r;
    roughness = 1 - saturate(pow(roughness, _RoughnessMapIntensity));
    // texCUBElod 求 mipmap值的写法。
    roughness = roughness * (1.7 - 0.7 * roughness);
    float mipmap_level = roughness * 6.0;

    half4 cubeMap = texCUBElod(_CubeMap, float4(cubeMap_ReflectDir, mipmap_level));
    //确保在移动端能拿到HDR信息
    half3 IBL = DecodeHDR(cubeMap, _CubeMap_HDR);
```
* 4、cubeMap设置如下：
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/203937455-60620459-6895-4a0e-b73f-854d7f71817d.png" width="800" height="750">
</div>

### 1.2 IBL 中使用 CubeMap 会出现的问题:
* CubeMap会有问题，当物体上不同的两个点的反射向量是同一方向时(即`cubeMap_ReflectDir`相同)，就会造成结果一样的情况。 **采用unity内置经纬度计算公式如下，传入三维反射方向向量，可以求出uv坐标，然后采样 2D 贴图(`tex2D`)(`_PanoramaMap`)即可。** 代码如下：
```
    float3 normalizedCoords = normalize(reflect_dir);
    float latitude = acos(normalizedCoords.y);
    float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
    float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
    float2 uv_panorama =  float2(0.5, 1.0) - sphereCoords;
    float4 color_LatLong = tex2D(_PanoramaMap, uv_panorama);
    //确保在移动端能拿到HDR信息
    float3 env_color = DecodeHDR(color_LatLong, _PanoramaMap_HDR);
    float3 final_color = env_color * ao * _Tint.rgb * _Expose;
    return float4(final_color, 1.0);
```

---
## 2、SH:
* 根据一张cubeMap图片，在 Unity 中用工具计算出里面需要的信息(Custom SHAr ~ SHBb SHC。一共7个值)，怎么计算的暂时没有研究，代码也看不懂= =
```
    float4 normalForSH = float4(normal_dir, 1.0);
    //SHEvalLinearL0L1
    half3 x;
    x.r = dot(custom_SHAr, normalForSH);
    x.g = dot(custom_SHAg, normalForSH);
    x.b = dot(custom_SHAb, normalForSH);

    //SHEvalLinearL2
    half3 x1, x2;
    // 4 of the quadratic (L2) polynomials
    half4 vB = normalForSH.xyzz * normalForSH.yzzx;
    x1.r = dot(custom_SHBr, vB);
    x1.g = dot(custom_SHBg, vB);
    x1.b = dot(custom_SHBb, vB);

    // Final (5th) quadratic (L2) polynomial
    half vC = normalForSH.x*normalForSH.x - normalForSH.y*normalForSH.y;
    x2 = custom_SHC.rgb * vC;

    float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
    sh = pow(sh, 1.0 / 2.2);

    half3 env_color = sh;
    half3 final_color = env_color * ao * _Tint.rgb * _Expose;

    return float4(final_color,1.0);
```

---
## $\color{red}{3、SH 具体的实现，以及间接光漫反射先挖个坑，到时候填上。}$










