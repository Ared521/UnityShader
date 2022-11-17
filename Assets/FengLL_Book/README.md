# 《Unity Shader入门精要》读书笔记
> 2022年11月13日创建，计划在11月30日读完此书，书中的重点和自己的理解会记在这里，以便之后复习。

> 笔记主要会以知识点的形式记下。
---
## 第二章 渲染流水线
### 1.《Real-Time Rendering》以概念流水线的角度，把渲染流程分为了 3 个阶段：应用阶段、几何阶段、光栅化阶段
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202356607-afaea005-3660-4506-9130-08d77bb63a3e.png" width="800" height="400">
</div>  

* 应用阶段：准备场景数据，如摄像机位置、视锥体、场景中有哪些模型、哪些光源等；粗粒度剔除；设置每个模型的渲染状态，如使用的材质，漫反射颜色、高光颜色、纹理、shader等。最终输出 **渲染图元**，传递给下一阶段 ———— 几何阶段。
* 几何阶段：几何阶段负责和每个渲染图元打交道，进行逐顶点、逐多边形的操作。几何阶段的一个重要任务就是把 **顶点坐标变换到屏幕空间中**，再交给光栅器进行处理。通过对输入的渲染图元进行多步处理后，这一阶段将会输出屏幕空间的二维顶点坐标、每个顶点对应的深度值、着色等相关信息，并传递给下一个阶段。
* 这一阶段将会使用上个阶段传递的数据来产生屏幕上的像素，并渲染出最终的图像。这一阶段也是在GPU上运行。光栅化的任务主要是决定每个渲染图元中的哪些像素应该被绘制在屏幕上。它需要对上一个阶段得到的逐顶点数据（例如纹理坐标、顶点颜色等）进行 **插值**，然后再进行逐像素处理。

### 2. CPU 与 GPU 之间的通信
* 数据加载：把数据加载到显存中，首先从硬盘加载到系统内存，然后网格和纹理等数据又被加载到显卡上的存储空间 ———— 显存。
* 设置渲染状态：定义了场景中的网格是怎么被渲染的，如使用哪个顶点着色器、片元着色器、光源属性、材质等。
* 调用Draw Call：准备好了上述的数据，接下俩又CPU向GPU发送渲染命令，这个命令就是Draw Call，这个命令仅仅会指向一个需要被渲染的图元列表，不会包含任何材质信息，因为信息已经在前两步准备好了。 **这些数据随后就会被传递给顶点着色器。**
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202360615-c2deeb26-b98d-44f5-a41a-7981382202d5.png" width="600" height="400">
</div> 

### 3. GPU渲染流水线：与概念流水线不同，GPU流水线是硬件真正用于实现上述概念流水线的
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202361827-8987260b-4511-4cf7-a127-131093440e69.png" width="800" height="400">
</div>

* 顶点着色器：顶点着色器本身无法创建或者销毁任何顶点，无法得到顶点之间的关系，由于这种相互独立性，GPU可以利用本身的特性并行化；顶点着色器主要需要完成的工作就是 **坐标变换** 和 **逐顶点光照。** 除此之外就是可以计算并输出后续阶段需要用到的数据。其中，必须要完成的就是坐标变换，即 **把顶点坐标从模型空间转换到齐次裁剪空间。** ``` o.pos = mul(UNITY_MATRIX_MVP, v.vertex); ```
* 透视除法和裁剪：顺序是 **先裁剪，再透视除法。** 先裁剪不在摄像机视野范围的，顶点着色器不同，这一步是不可编程的，即我们无法通过编程来控制裁剪的过程，而是硬件上的固定操作，但我们可以自定义一个裁剪操作来对这一步进行配置（这里怎么自定义没有说，暂时还不知道= =）。由硬件做透视除法后，最终得到归一化的设备坐标（Normalized Device Coordinates ，NDC）。顶点着色器可以有不同的输出方式。最常见的输出路径是经光栅化后交给片元着色器进行处理。而在现代的Shader Model中，它还可以把数据发送给曲面细分着色器或几何着色器。
* 屏幕映射：紧接着上面的 NDC 空间，就是将每个图元的 x, y 坐标转换到 **屏幕坐标系。** 需要注意的是，这一步操作不会对 z 坐标做任何处理。
* 光栅化阶段(三角形设置与三角形遍历)：现在只是知道了每条边上的端点的像素坐标，为了能够计算边界像素坐标信息，需要得到三角形边界的表示方式，一个计算三角网格表示数据的过程就叫做三角形设置； 三角形遍历就是检查每个像素是否被一个三角网格所覆盖，如果被覆盖就生成一个 **片元。片元的信息是对 3 个顶点信息插值得到的。** ， 这样一个找到哪些像素被三角网格覆盖的过程就叫做三角形遍历。此时的片元并不等于像素，而是包含了很多状态的集合，如屏幕坐标、深度信息、法线、纹理等，这些用于计算最终的像素颜色信息。
* 片元着色器：对光栅化插值得到的信息做最后复杂的计算，比较重要的一个技术就是纹理采样，其次还有复杂的逐片元的光照计算等等。虽然片元着色器可以完成很多重要效果，但它的局限在于，它仅可以影响单个片元。也就是说，当执行片元着色器时，它不可以将自己的任何结果直接发送给它的邻居们。有一个情况例外，
$\color{yellow}{就是片元着色器可以访问到导数信息(这个之前做描边接触过，到时候需要再看一下)。}$
* 逐片元操作：就是各种测试，如下图：
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202367474-d4464f28-6308-4c9c-8274-d216b3652f86.png" width="600" height="200">
</div>

### 4. Early —— Z 技术
* 在 Unity 给出的渲染流水线中，我们也可以发现它给出的深度测试是在片元着色器之前。这种将深度测试提前的技术通常被称为 **Early —— Z 技术。** 还有类似透明度提前的操作，本身应该在片元着色器之后，有时候也会考虑提前，这是因为当提前判断是否通过测试就可以避免这些片元再在片元着色器中做不必要的计算，能够节省计算上的性能消耗。**当然，这些也不是万能的，有时候在片元着色器中会造成一些冲突。**

### 5. 双重缓冲
* 当模型的图元经过了上面层层计算和测试后，就会显示到我们的屏幕上。我们的屏幕显示的就是颜色缓冲区中的颜色值。但是，为了避免我们看到那些正在进行光栅化的图元，GPU会使用 **双重缓冲（Double Buffering）** 的策略。这意味着，对场景的渲染是在幕后发生的，即在**后置缓冲（Back Buffer）** 中。一旦场景已经被渲染到了后置缓冲中，GPU就会交换后置缓冲区和**前置缓冲（Front Buffer）** 中的内容，而前置缓冲区是之前显示在屏幕上的图像。由此，保证了我们看到的图像总是连续的。

### 6. 减少 Draw Call
* 批处理思想（直接上图）
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202369104-e69fe905-4884-4394-802a-981e4e991b22.png" width="800" height="1000">
</div>
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202369212-dceba0d9-32c3-49ab-97c8-092c72dbc19a.png" width="800" height="400">
</div>

---
## 第三章 Unity Shader 基础
### 1. ShaderLab
* 在 Unity 中，所有的 Unity Shader 都是使用 ShaderLab 来编写的。ShaderLab 是 Unity 提供的编写 Unity Shader 的一种说明性语言，它不是真正意义上的 shader 文件，它里面可以定义一些材质所需要的所有东西，而**不仅仅是着色器代码。** Unity 在背后会根据使用的平台来把下面代码这些结构编译成真正的代码和 shader 文件，开发者只需要和 Unity Shader 打交道即可。
``` 
Shader "ShaderName" {
      Properties {
          //属性
      }
      SubShader {
          //显卡 A 使用的子着色器
          [Tags]
          [RenderSetup]
          
          Pass {
              [Name]
              [Tags]
              [RenderSetup]
              // Other code
          }
          // Other Passes
      }
      SubShader {
          //显卡 B 使用的子着色器
      }
      /*当Unity需要加载这个 Unity Shader 时，Unity会扫描所有的 SubShader 语义块，然后选择第一个能够在目标平台上运行的 SubShader。
      如果 SubShader 都不支持的话，Unity 就会使用 Fallback 语义指定的 Unity Shader。*/
      Fallback "VertexLit" 
}
```
* Properties 语义块的作用仅仅是为了让这些属性可以出现在材质面板中，我们可以通过脚本向Shader中传递属性。
* SubShader 中定义了一系列Pass 以及可选的状态（[RenderSetup]）和标签 （[Tags]）设置。每个Pass 定义了一次完整的渲染流程，但如果Pass 的数目过多，往往会造成渲染性能的下降。因此，我们应尽量使用最小数目的Pass 。状态和标签同样可以在Pass声明。不同的是，SubShader 中的一些标签设置是特定的。也就是说，这些标签设置和Pass 中使用的标签是不一样的。而对于状态设置来说，其使用的语法是相同的。但是，如果我们在SubShader 进行了这些设置，那么将会用于所有的Pass。
* 渲染状态可在不同的 Pass 中单独设置。
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202373000-298785b5-3334-48a2-a206-128446235458.png" width="600" height="400">
</div>
* SubShader 的标签（Tags）是一个键值对 （Key/Value Pair），它的键和值都是字符串类型。这些键值对是SubShader 和渲染引擎之间的沟通桥梁。它们用来告诉Unity的渲染引擎：我希望怎样以及何时渲染这个对象。标签结构如下：

```Tags { "TagName1" = "Value1" "TagName2" = "Value2" } ```
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202376075-1a554343-0ec1-44bb-badf-5ae887104428.png" width="600" height="800">
</div>
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202376205-facdba44-de77-4db2-b429-5087aa31f12e.png" width="600" height="350">
</div>

### 2. UsePass 和 GrabPass
* UsePass: 如我们之前提到的一样，可以使用该命令来复用其他 Unity Shader 中的 Pass。需要在 Pass 中声明 Name。如上述代码块。
 
```Name "MyPassName"```
* ### GrabPass: 该 Pass 负责抓取屏幕并将结果存储在一张纹理中，以用于后续的Pass 处理。

```在其他 shader 中使用 UsePass 语句： UsePass "MyShader/MyPassName"```
* 事实上，Fallback 还会影响阴影的投射。在渲染阴影纹理时，Unity会在每个Unity Shader中寻找一个阴影投射的Pass。通常情况下，我们不需要自己专门实现一个Pass，这是因为Fallback 使用的内置
Shader中包含了这样一个通用的Pass。因此，为每个Unity Shader正确设置Fallback 是非常重要的。更多关于Unity中阴影的实现，可以参见 Unity Shader 入门精要 9.4节。

### 3. Surface Shader(表面着色器)
* 表面着色器其实就是 Unity 对顶点/片元着色器的更高一层的抽象，它存在的价值就是为我们处理了很多光照细节，方便我们使用。Unity 在背后仍然会把表面着色器转换成对应的顶点/片元着色器。
* CGPROGRAM 和ENDCG 之间的代码是使用Cg/HLSL编写的，也就是说，我们需要把Cg/HLSL语言嵌套在ShaderLab语言中。值得注意的是，这里的Cg/HLSL是Unity经封装后提供的，它的语法和标准的Cg/HLSL语法几乎一样，但还是有细微的不同，例如有些原生的函数和用法Unity并没有提供支持。

### 4. (fix function)固定函数着色器
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202380965-4e4d85fa-b0ec-4b62-93d9-a86d18bb1057.png" width="800" height="500">
</div>

### 5. Unity Shader 的选择
* 低端机器，旧机器用 fix function 固定函数着色器。
* 如果涉及到复杂的光源光照，用表面着色器，需要注意的是在移动平台的性能。
* 光照数目少，用顶点/片元着色器，也就是在 Unity 中创建 Unlit Shader。
* 自定义的渲染效果，用顶点/片元着色器。

### 6. 其他
* 尽管 Unity Shader 翻译过来就是 Unity 着色器。在Unity里，Unity Shader 实际上指的就是一个 ShaderLab 文件——硬盘上以 .shader 作为文件后缀的一种文件。
* Unity Shader 除了上述这些优点外，也有一些缺点。由于 Unity Shader 的高度封装性，我们可以编写的Shader类型和语法都被限制了。对于一些类型的 Shader，例如曲面细分着色器（Tessellation Shader）、几何着色器（Geometry Shader）等，Unity 的支持就相对差一些。
* Cg/HLSL 代码是嵌套在 CGPROGRAM 和 ENDCG 之间的，正如我们之前看到的示例代码一样。由于 Cg 和 DX9 风格的 HLSL 从写法上来说几乎是同一种语言，因此在 Unity 里 Cg 和 HLSL 是等价的。
* Unity 编辑器会把这些 Cg 片段编译成低级语言，如汇编语言等。通常，Unity 会自动把这些 Cg 片段编译到所有相关平台（这里的平台是指不同的渲染平台，例如 Direct3D 9、Direct3D 11、OpenGL、OpenGL ES等）上。这些编译过程比较复杂，Unity 会使用不同的编译器来把 Cg 转换成对应平台的代码。这样就不会在切换平台时再重新编译，而且如果代码在某些平台上发生错误就可以立刻得到错误信息。
* 当发布游戏的时候，游戏数据文件中只包含目标平台需要的编译代码，而那些在目标平台上不需要的代码部分就会被移除。例如，当发布到 Mac OS X 平台上时，DirectX 对应的代码部分就会被移除。

---
## 第四章 学习 Shader 所需的数学基础
> ### 本章涉及过多数学公式，且与 Games101 内容及作业相似，笔记和总结可参考：[Ared521/Games101](https://github.com/Ared521/Games101)

---
## 第五章 开始 Unity Shader 学习之旅
### 1. 语义
* Shader 中，如 `POSITION` 将会告诉 Unity，把模型的顶点坐标赋给 `:` 左边的变量。`SV_POSITION` 则是将顶点着色器输出的裁剪空间下的顶点坐标赋给 `:` 左边的变量。如果没有这些语义来限定输入输出参数的话，渲染器就完全不知道用户的输入输出是什么。对于 fragment shader 来说，`SV_Target` 也是HLSL中的一个系统语义，它等同于告诉渲染器，把片元着色器的输出颜色存储到一个渲染目标`render target` 中，这里将输出到默认的帧缓存中。
* `struct a2v` 中的 `float4 texcoord : TEXCOORD0`，其中 `TEXCOORD0` 表示模型的纹理坐标，后面的数字是几，就是第几个。`#pragma target X.0` 的不同，支持的个数也不同。
* `.cginc`是内置的包含文件，很重要，尤其是`#include UnityCG.cginc`。在 `UnityShaderVariables.cginc`、`Lighting.cginc`、`AutoLight.cginc`等文件中也有 Unity 为我们提供的用于访问时间、光照、雾效和环境光等目的变量。
* 语义实际上就是一个赋给 Shader 输入和输出的字符串，这个字符串表达了这个参数的含义。通俗地讲，这些语义可以让 Shader 知道从哪里读取数据，并把数据输出到哪里，它们在 Cg/HLSL 的 Shader 流水线中是不可或缺的。需要注意的是，Unity 并没有支持所有的语义。
* 为了让我们的 Shader 有更好的跨平台性，对于这些有特殊含义的变量我们最好使用以 SV 开头的语义进行修饰，如 `SV_POSITION`、`SV_Target`
* ，一个语义可以使用的寄存器只能处理4个浮点值`float4`。因此，如果我们想要定义矩阵类型，如`float3×4`、`float4×4`等变量就需要使用更多的空间。一种方法是，把这些变量拆分成多个变量，例如对于`float4×4`的矩阵类型，我们可以拆分成4个`float4`类型的变量，每个变量存储了矩阵中的一行数据。之后关于 切线空间 `TBN` 矩阵会用到。

### 2. 渲染信息
* Frame Debugger 是使用 **停止渲染** 的方法来查看渲染事件的结果，并不是帧拾取(frame capture)功能。想要获得更多的信息，需要使用别的外部工具，如：**RenderDoc(重要！待开坑= =)。**

### 3. 渲染平台的差异
* Unity 默认是使用 DX11 渲染 API，不同的渲染平台会有差异，如 DX11 和 OpenGL 的渲染纹理坐标差异。
* 当我们要使用渲染到纹理技术，把屏幕图像渲染到一张渲染纹理中时，如果不采取任何措施的话，就会出现纹理翻转的情况。幸运的是，Unity 在背后为我们处理了这种翻转问题 —— 当在DirectX平台上使用渲染到纹理技术时，Unity 会为我们翻转屏幕图像纹理，以便在不同平台上达到一致性。
<div align=center>
<img src="https://user-images.githubusercontent.com/104584816/202459069-8e551cdf-9654-479f-8e41-51589ecd697e.png" width="800" height="1200">
</div>
* DirectX 9 / 11也不支持在顶点着色器中使用 tex2D 函数。tex2D 是一个对纹理进行采样的函数，我们在后面的章节中将会具体讲到。之所以DirectX 9 / 11不支持顶点阶段中的 tex2D 运算，是因为在顶点着色器阶段 Shader 无法得到 UV 偏导，而 tex2D 函数需要这样的偏导信息（这和纹理采样时使用的数学运算有关）。如果我们的确需要在顶点着色器中访问纹理，需要使用如下代码：

`tex2Dlod(tex, float4(uv, 0, 0));` 而且我们还需要添加 `#pragma target 3.0`，因为 tex2Dlod 是 Shader Model 3.0 中的特性。

### 4. Shader Model
* 不同的 Shader Target、不同的着色器阶段，我们可使用的临时寄存器和指令数目都是不同的。否则会报错：我们在 Shader 中进行了过多的运算，使得需要的临时寄存器数目或指令数目超过了当前可支持的数目。通常，我们可以通过指定更高等级的 Shader Target 来消除这些错误。Shader Model 是由微软提出的一套规范，通俗地理解就是它们决定了 Shader 中各个特性的能力。这些特性和能力体现在 Shader 能使用的运算指令数目、寄存器个数等各个方面。Shader Model 等级越高，Shader 的能力就越大。






