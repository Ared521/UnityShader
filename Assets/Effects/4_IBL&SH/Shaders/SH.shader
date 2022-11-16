Shader "Effects_Unlit/4_SH"
{
	Properties
	{
		_Tint("Tint",Color) = (1,1,1,1)
		_Expose("Expose",Float) = 1.0
		_Rotate("Rotate",Range(0,360)) = 0
		_NormalMap("Normal Map",2D) = "bump"{}
		_NormalIntensity("Normal Intensity",Float) = 1.0
		_AOMap("AO Map",2D) = "white"{}
		_AOAdjust("AO Adjust",Range(0,1)) = 1

		custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
		custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
		custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
		custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
		custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
		custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
		custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 normal_world : TEXCOORD1;
				float3 pos_world : TEXCOORD2;
				float3 tangent_world : TEXCOORD3;
				float3 binormal_world : TEXCOORD4;
			};

			//sampler2D _MainTex;
			//float4 _MainTex_ST;
			samplerCUBE _CubeMap;
			float4 _CubeMap_HDR;
			float4 _Tint;
			float _Expose;

			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			float _NormalIntensity;
			sampler2D _AOMap;
			float _AOAdjust;
			float _Rotate;
			float _Roughness;
			sampler2D _RoughnessMap;
			float _RoughnessContrast;
			float _RoughnessBrightness;
			float _RoughnessMin;
			float _RoughnessMax;

			half4 custom_SHAr;
			half4 custom_SHAg;
			half4 custom_SHAb;
			half4 custom_SHBr;
			half4 custom_SHBg;
			half4 custom_SHBb;
			half4 custom_SHC;

			float3 RotateAround(float degree, float3 target)
			{
				float rad = degree * UNITY_PI / 180;
				float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
					sin(rad), cos(rad));
				float2 dir_rotate = mul(m_rotate, target.xz);
				target = float3(dir_rotate.x, target.y, dir_rotate.y);
				return target;
			}

			inline float3 ACES_Tonemapping(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x + d) + e));
				return encode_color;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_world = normalize(cross(o.normal_world, o.tangent_world)) * v.tangent.w;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half3 normal_dir = normalize(i.normal_world);
				half3 normaldata = UnpackNormal(tex2D(_NormalMap,i.uv));
				normaldata.xy = normaldata.xy* _NormalIntensity;
				half3 tangent_dir = normalize(i.tangent_world);
				half3 binormal_dir = normalize(i.binormal_world);
				normal_dir = normalize(tangent_dir * normaldata.x
					+ binormal_dir * normaldata.y + normal_dir * normaldata.z);

				half ao = tex2D(_AOMap, i.uv).r;
				ao = lerp(1.0,ao, _AOAdjust);

				
				
				//130行 ~ 150行是根据计算出来的值，计算间接光漫反射。并看不懂 = =
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
			}
			ENDCG
		}
	}
}
