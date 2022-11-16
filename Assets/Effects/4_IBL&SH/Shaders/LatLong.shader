Shader "Effects_Unlit/4_LatLong"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
		_PanoramaMap("Panorama Map",2D) = "white"{}
		_Tint("Tint",Color) = (1,1,1,1)
		_Expose("Expose",Float) = 1.0
		_Rotate("Rotate",Range(0,360)) = 0
		_NormalMap("Normal Map",2D) = "bump"{}
		_NormalIntensity("Normal Intensity",Float) = 1.0
		_AOMap("AO Map",2D) = "white"{}
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
			sampler2D _PanoramaMap;
			float4 _PanoramaMap_HDR;
			float4 _Tint;
			float _Expose;

			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			float _NormalIntensity;
			sampler2D _AOMap;
			float _Rotate;

			float3 RotateAround(float degree, float3 target)
			{
				float rad = degree * UNITY_PI / 180;
				float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
					sin(rad), cos(rad));
				float2 dir_rotate = mul(m_rotate, target.xz);
				target = float3(dir_rotate.x, target.y, dir_rotate.y);
				return target;
			}

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
				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half3 reflect_dir = reflect(-view_dir, normal_dir);

				reflect_dir = RotateAround(_Rotate, reflect_dir);
				
				float3 normalizedCoords = normalize(reflect_dir);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
				float2 uv_panorama =  float2(0.5, 1.0) - sphereCoords;

				half4 color_cubemap = tex2D(_PanoramaMap, uv_panorama);
				half3 env_color = DecodeHDR(color_cubemap, _PanoramaMap_HDR);
				//half4 color_cubemap = texCUBE(_CubeMap, reflect_dir);
				//half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);//确保在移动端能拿到HDR信息
				half3 final_color = env_color * ao * _Tint.rgb * _Expose;
				return float4(final_color,1.0);
			}
			ENDCG
		}
	}
}
