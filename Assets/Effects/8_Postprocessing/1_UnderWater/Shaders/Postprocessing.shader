Shader "Hidden/effectshader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_UnderWaterColor ("UnderWaterColor", color) = (1, 1, 1, 1)
		_WaterDivisionColor ("WaterDivisionColor", color) = (0, 0, 0, 0)
		_WaterDivisionOffset ("WaterDivisionOffset", float) = 1
		_WaterDivisionWidth ("WaterDivisionWidth", float) = 1
		_UnderWaterColorIntensity ("UnderWaterColorIntensity", Range(1, 10)) = 1
		_HeightOffsetIntensity ("HeightOffsetIntensity", float) = 100
		_FogIntensity ("FogIntensity", float) = 1
		_FogPower ("FogPower", float) = 1
		_DepthIntensity ("DepthIntensity", float) = 1
		_DepthFogContrast ("DepthFogContrast", float) = 1
		_DistortIntensity ("DistortIntensity", float) = 1
		_UnderWaterColor ("UnderWaterColor", color) = (1, 1, 1, 1)

		_UnderWaterDistortTex ("UnderWaterDistortTex", 2D) = "white" {}
	}
	SubShader
	{
	 // No culling or depth
	 Cull Off ZWrite Off ZTest Always


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};


			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
 
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			sampler2D _UnderWaterDistortTex;
		    float _Posy;
			float _HeightOffsetIntensity;
			float4 _UnderWaterColor;
			float4 _WaterDivisionColor;
			float _WaterDivisionOffset;
			float _WaterDivisionWidth;
			float _UnderWaterColorIntensity;
			float _FogIntensity;
			float _FogPower;
			float _DepthIntensity;
			float _DepthFogContrast;
			float _DistortIntensity;


			float4 frag (v2f i) : SV_Target
			{
				float heightOffset = sin(pow(abs(sin(_Time.y)), 3)) * _HeightOffsetIntensity;
				

				float4 col = tex2D(_MainTex, i.uv);
				if(_ScreenParams.y - i.vertex.y - _Posy - heightOffset - _WaterDivisionOffset < 0)
				{	
					
					// 水上，水下 分割线
					if(_ScreenParams.y - i.vertex.y - _Posy - heightOffset - _WaterDivisionOffset > -_WaterDivisionWidth)
					{
						return _WaterDivisionColor;
					}
					
					// Fog
					float depth = 1 - SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture , i.uv) * _DepthIntensity;
					//float linearDepth = Linear01Depth(depth);
					float fog = saturate(pow(depth, _FogIntensity));
					fog = saturate(pow(1 - fog, _FogPower));

					// Distort
					float2 distort_uv1 = float2(i.uv.x, i.uv.y + _Time.y * 0.012);
					float2 distort_uv2 = float2(i.uv.x + _Time.y * 0.032, i.uv.y);

					float distort_Noise1 = tex2D(_UnderWaterDistortTex, distort_uv1).r;
					float distort_Noise2 = tex2D(_UnderWaterDistortTex, distort_uv2).r;
					float distort_FinalNoise = lerp(distort_Noise1, distort_Noise2, 0.5);

					float2 distort_ScreenUV = float2(distort_FinalNoise * depth * _DistortIntensity, distort_FinalNoise * depth * _DistortIntensity) + i.uv;
					float4 col = tex2D(_MainTex, distort_ScreenUV);
					

					col = lerp(_UnderWaterColor * col * _UnderWaterColorIntensity, col, fog) * _DepthFogContrast;
					return col;
				}
				else 
				{
					float4 col = tex2D(_MainTex, i.uv);
					return col;
				}
			 }
			ENDCG
		}
	}
}