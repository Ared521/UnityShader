Shader "Hidden/Paint in 3D/Decal"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_Shape("Shape", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_Opacity("Opacity", Float) = 1
		_Power("Power", Float) = 1
		_NormalScale("Normal Scale", Float) = 1

		_Channel("Channel", Vector) = (1, 0, 0, 0)
		_SrcRGB("Src RGB", Int) = 1 // 1 = One
		_DstRGB("Dst RGB", Int) = 1 // 1 = One
		_SrcA("Src A", Int) = 1 // 1 = One
		_DstA("Dst A", Int) = 1 // 1 = One
		_Op("Op", Int) = 0 // 0 = Add
		_Direction("Direction", Vector) = (1, 0, 0)
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
			Blend [_SrcRGB] [_DstRGB], [_SrcA] [_DstA]
			BlendOp [_Op]
			Cull Off
			Lighting Off
			ZWrite Off

			CGPROGRAM
				#pragma vertex Vert
				#pragma fragment Frag
				#include "UnityCG.cginc"
				#include "BlendModes.cginc"
				// AlphaBlend, Additive, Swapped AlphaBlend, Shape Lerp, Multiply
				#pragma multi_compile __ P3D_A P3D_B P3D_C P3D_D

				sampler2D _Buffer;
				float4    _Channel;
				float4x4  _Matrix;
				float3    _Direction;
				sampler2D _Texture;
				sampler2D _Shape;
				float4    _Color;
				float     _Opacity;
				float     _Hardness;
				float     _NormalScale;

				struct a2v
				{
					float4 vertex    : POSITION;
					float3 normal    : NORMAL;
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float2 texcoord2 : TEXCOORD2;
					float2 texcoord3 : TEXCOORD3;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					float2 texcoord : TEXCOORD0;
					float3 position : TEXCOORD1;
					float2 coord    : TEXCOORD2;
				};

				struct f2g
				{
					float4 color : COLOR;
				};

				void Vert(a2v i, out v2f o)
				{
					float2 texcoord = i.texcoord0 * _Channel.x + i.texcoord1 * _Channel.y + i.texcoord2 * _Channel.z + i.texcoord3 * _Channel.w;
					float4 worldPos = mul(unity_ObjectToWorld, i.vertex);
					o.vertex   = float4(texcoord.xy * 2.0f - 1.0f, 0.5f, 1.0f);
					o.texcoord = texcoord;
					o.position = mul(_Matrix, worldPos).xyz;
					o.coord    = o.position * 0.5f + 0.5f;
#if UNITY_UV_STARTS_AT_TOP
					o.vertex.y = -o.vertex.y;
#endif
					float3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, i.normal));
					float  normalDot   = dot(worldNormal, _Direction);

					o.position.z += (normalDot + 1.0f) * _NormalScale;
					//if (normalDot >= 0)
					{
						//o.position.z = 2.0f;
					}
				}

				void Frag(v2f i, out f2g o)
				{
					float4 color = tex2D(_Texture, i.coord) * _Color;
					float3 box   = saturate(abs(i.position));

					box.xy = pow(box.xy, 1000.0f); // Make edges with high hardness
					box.z  = pow(box.z, _Hardness); // Make depth with custom hardness

					float strength = 1.0f - max(box.x, max(box.y, box.z));
#if P3D_C // Shape Lerp
					strength *= tex2D(_Shape, i.coord).a;
#endif
					o.color = Blend(color, strength * _Opacity, _Buffer, i.texcoord);
				}
			ENDCG
		} // Pass
	} // SubShader
} // Shader