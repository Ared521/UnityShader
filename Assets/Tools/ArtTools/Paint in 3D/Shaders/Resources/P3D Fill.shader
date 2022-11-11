Shader "Hidden/Paint in 3D/Fill"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_Opacity("Opacity", Float) = 1

		_SrcRGB("Src RGB", Int) = 1 // 1 = One
		_DstRGB("Dst RGB", Int) = 1 // 1 = One
		_SrcA("Src A", Int) = 1 // 1 = One
		_DstA("Dst A", Int) = 1 // 1 = One
		_Op("Op", Int) = 0 // 0 = Add
	}
	SubShader
	{
		Tags
		{
			"Queue"           = "Transparent"
			"RenderType"      = "Transparent"
			"IgnoreProjector" = "True"
			"Paint in 3D"     = "True"
		}
		Pass
		{
			Blend[_SrcRGB][_DstRGB],[_SrcA][_DstA]
			BlendOp[_Op]
			Cull Off
			Lighting Off
			ZWrite Off

			CGPROGRAM
				#pragma vertex vert_img
				#pragma fragment Frag
				#include "UnityCG.cginc"
				#include "BlendModes.cginc"
				// AlphaBlend, Additive, Swapped AlphaBlend, Shape Lerp, Multiply
				#pragma multi_compile __ P3D_A P3D_B P3D_C P3D_D

				sampler2D _Buffer;
				sampler2D _Texture;
				float4    _Color;
				float     _Opacity;

				struct f2g
				{
					float4 color : COLOR;
				};

				void Frag(v2f_img i, out f2g o)
				{
					float4 color = tex2D(_Texture, i.uv) * _Color;

					//o.color = Blend(color, _Opacity, _Buffer, i.uv);
					o.color = BlendMinimum(color, _Opacity, _Buffer, i.uv, 1.0f / 255.0f);
				}
			ENDCG
		} // Pass
	} // SubShader
} // Shader