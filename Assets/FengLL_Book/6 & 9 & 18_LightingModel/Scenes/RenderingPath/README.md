# Unity 的渲染路径、光源类型
## 1. 渲染路径
### 1.1 前向渲染(Forward Rendering Path):
* 如果当前的显卡并不支持所选择的渲染路径，Unity会自动使用更低一级的渲染路径。
* LightMode 标签支持的渲染路径设置如下图：
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202712886-169791c8-ed14-4e3d-b44c-f6126f35933e.png" width="800" height="1000">
</div>

* 必须在 shader 中 Pass 内的 Tag 指定需要的渲染路径，如果没有指定任何渲染路径，那么一些光照变量就可能不会被正确赋值，计算出来的效果也就可能不正确。
* 对于每个逐像素光源，我们都需要进行上面一次完整的渲染流程。如果一个物体在多个逐像素光源的影响区域内，那么该物体就需要执行多个Pass，每个Pass计算一个逐像素光源的光照结果，然后在帧缓冲中把这些光照结果混合起来得到最终的颜色值。假设，场景中有 N 个物体，每个物体受 M 个光源的影响，那么要渲染整个场景一共需要 N * M 个Pass。可以看出，如果有大量逐像素光照，那么需要执行的Pass数目也会很大。因此，渲染引擎通常会限制每个物体的逐像素光照的数目。
* 在Unity中，前向渲染路径有3种处理光照（即照亮物体）的方式：逐顶点处理、逐像素处理，球谐函数(Spherical Harmonics，SH)处理 。而决定一个光源使用哪种处理模式取决于它的类型和渲染模式。光源类型指的是该光源是平行光还是其他类型的光源，而光源的渲染模式指的是该光源是否是重要的(Important)，一般设置成重要的都是逐像素处理，前提是在光源数目小于等于 Unity Setting 中的逐像素光源数量(Pixel Light Count)。
* 场景中最亮的平行光总是按逐像素处理的。
* 一个物体只执行一次 Base Pass, Add Pass 会根据逐像素光源个数多次执行叠加
* 只有分别为 Bass Pass和Additional Pass 使用 `#pragma multi_compile_fwdbase` 和 `#pragma multi_compile_fwdadd` 这两个编译指令，我们才可以在相关的 Pass 中得到一些正确的光照变量，例如光照衰减值等。**这是因为这些指令会处理不同条件下的渲染逻辑，例如是否使用光照纹理(lightmap)、当前处理那种光源类型(重要: 计算 atten)、是否开启了阴影等。**
* Base Pass 中渲染的平行光默认是支持阴影的(如果开启了光源的阴影功能)，而 Additional Pass 中渲染的光源在默认情况下是没有阴影效果的。
* 在Additional Pass 的渲染设置中，我们还开启和设置了混合模式。这是因为，我们希望每个 Additional Pass 可以与上一次的光照结果在帧缓存中进行叠加，从而得到最终的有多个光照的渲染效果。如果我们没有开启和设置混合模式，那么 Additional Pass 的渲染结果会覆盖掉之前的渲染结果，看起来就好像该物体只受该光源的影响。通常情况下，我们选择的混合模式是`Blend One One`
* 对于前向渲染来说，一个Unity Shader通常会定义一个Base Pass(Base Pass也可以定义多次，例如需要双面渲染等情况)以及一个 Additional Pass。一个 Base Pass 仅会执行一次(定义了多个Base Pass的情况除外)，而一个Additional Pass 会根据影响该物体的其他逐像素光源的数目被多次调用，即 **每个逐像素光源** 会执行一次 Additional Pass。
* 根据我们使用的渲染路径(即Pass标签中LightMode的值)，Unity 会把不同的光照变量传递给 Shader。
### 前向渲染 Frame Debugger
<div align=center>
<img src="https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/ForwardRenderingPath.gif" width="800" height="500">
</div>

---
### 1.2 延迟渲染(Deferred Rendering Path):
* 延迟渲染主要包含了两个 Pass。
* $\color{yellow}{在第一个 Pass，不进行光照计算，只计算哪些片元可见，通过深度缓冲技术，当一个片元是可见，就把它的相关信息存储到 G-Buffer 中。}$
* $\color{yellow}{在第二个 Pass，我们利用G缓冲区的各个片元信息，例如表面法线、视角方向、漫反射系数等，进行真正的光照计算。}$
* 延迟渲染的效率不依赖于场景的复杂度，而是和我们使用的屏幕空间的大小有关。这是因为，我们需要的信息都存储在缓冲区中，而这些缓冲区可以理解成是一张张 2D 图像，我们的计算实际上就是在这些图像空间中进行的。
* 如果游戏中使用了大量的实时光照，那么我们可能希望选择延迟渲染路径，但这种路径需要一定的硬件支持。
* 延迟渲染路径中的每个光源都可以按逐像素的方式处理。
* 延迟渲染的缺点：1、不支持真正的抗锯齿（anti-aliasing）功能。2、不能处理半透明物体。3、对显卡有一定要求。如果要使用延迟渲染的话，显卡必须支持MRT(Multiple Render Targets)、Shader Mode 3.0 及以上、深度渲染纹理以及双面的模板缓冲。
* 对于每个物体来说，第一个 Pass 仅会执行一次。
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202718613-fa354798-22da-477f-b6d3-dbcb97a22666.png" width="800" height="400">
</div>

### 延迟渲染 Frame Debugger
<div align=center>
<img src="https://github.com/Ared521/UnityShader/blob/main/Assets/Resources/README_gif/DeferredRenderingPath.gif" width="800" height="500">
</div>

---
## 2. 光源类型
### 2.1 前向渲染多光源
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202833505-8b4263bb-d20f-4ee0-aeb6-3107119cee40.png" width="800" height="500">
</div>

* 平行光的位置跟顶点位置无关，对于任何顶点，平行光位置都不影响光照结果(旋转的时候，平行光方向改变，会影响光照结果)。
* 平行光、点光源、聚光灯的方向属性，都是通过光源的位置减去顶点的位置来得到该顶点指向光源方向的向量。需要注意的是，对于点光源和聚光灯，有光照衰减值，通常可以由一个函数定义。
```
// 计算不同光源方向，平行光跟物体的顶点位置无关。
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 light_WorldDir = normalize(_WorldSpaceLightPos0.xyz);
                    fixed atten = 1.0;
                #else
                    fixed3 light_WorldDir = normalize(_WorldSpaceLightPos0.xyz - i.pos_World);
                    #if defined (POINT)
                        //unity_WorldToLight 在 AutoLight.cginc 文件中的特定宏下被定义，可以用于把点从世界空间变换到该光源的局部空间下
                        float3 lightCoord = mul(unity_WorldToLight, float4(i.pos_World, 1)).xyz;
                        /* UNITY_ATTEN_CHANNEL 是衰减值所在的纹理通道，可以在内置的 HLSLSupport.cginc 文件中查看，
                        一般PC和主机平台的话 UNITY_ATTEN_CHANNEL 是 r 通道，移动平台的话是 a 通道*/
                        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined (SPOT)
                        float4 lightCoord = mul(unity_WorldToLight, float4(i.pos_World, 1));
                        //若不在聚光灯的照射方向，就当然没有光照
                        fixed atten = (lightCoord.z > 0) * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                        //对于聚光灯，_LightTexture0存储的不再是基于距离的衰减纹理，而是一张基于张角范围的衰减纹理
                        atten *= tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w;
                    #else
                        fixed atten = 1.0;
                    #endif
                #endif
```

* 而且还需要判断顶点是否在光源的照明范围内，如果不在范围内，就不调用渲染事件。
* `#pragma multi_compile_fwdbase` 指令可以保证我们在Shader中使用光照衰减等光照变量可以被正确赋值。
* 如果场景中包含了多个平行光，Unity 会选择**最亮**的平行光传递给 Base Pass 进行**逐像素**处理，其他平行光会按照**逐顶点**或在 Additional Pass 中按**逐像素**的方式处理。如果场景中没有任何**平行光**，那么 Base Pass 会当成**全黑的光源**处理。我们提到过，每一个光源有 5 个属性：位置 、方向 、颜色、强度以及衰减 。对于 Base Pass 来说，它处理的逐像素光源类型一定是平行光。
* 在 ForwardAdd 中 通过使用 `#pragma multi_compile_fwdadd` 编译指令，可以保证我们在 Additional Pass 中访问到正确的光照变量。注: 记得 `Blend One One`，否则会覆盖。
* 在 ForwardAdd 中 去掉Base Pass中环境光、自发光、逐顶点光照、SH光照的部分，并添加一些对不同光源类型的支持。
* Unity选择了使用一张纹理作为查找表(Lookup Table，LUT)，以在片元着色器中得到光源的衰减。我们首先得到光源空间下的坐标，然后使用该坐标对衰减纹理进行采样得到衰减值。
* 例: 设置 Edit → Project Settings → Quality → Pixel Light Count = 4。 这种情况下一个物体可以接收除最亮的平行光外的 4 个逐像素光照。
* 可在 Frame Debugger 中调试查看渲染顺序。Unity 处理这些点光源的顺序是按照它们的重要度排序的。
* **Unity官方文档中并没有给出光源强度、颜色和距离物体的远近是如何具体影响光源的重要度排序，仅知道排序结果和这三者都有关系。**
* 当把光源的 Render Mode 设置为 Important 时，当小于等于 Pixel Light Count 时，**会进行逐像素光**来处理。
* 当把光源的 Render Mode 设置为 Not Important 时，则该光源**不会进行逐像素光**来处理。

