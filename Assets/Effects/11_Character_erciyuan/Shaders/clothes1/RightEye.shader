Shader "Unlit/LeftEye"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _FresnelMin ("Fresnel Min", Float) = 0.5
        _FresnelMax ("Fresnel Max", Float) = 0.5
        _DetailMap ("Detail Map", 2D) = "white" {}
        _EnvRotate ("Env Rotate", Float) = 0
        _Envmap ("Evnmap", Cube) = "white" {}
        _Roughness ("Roughness", Float) = 0.5
        _EnvIntensity ("Env Intensity", Float) = 0.5
        _ParallaxIntensity ("Parallax Intensity", Float) = 0.5




    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        LOD 100   
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_World : TEXCOORD1;
                float3 tangent_World : TEXCOORD2;
                float3 binormal_World : Texcoord3;
                float4 pos_World : TEXCOORD4;
                float4 vertexColor : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            sampler2D _DetailMap;
            sampler2D _SpecularMap;           
            float4 _Specular_Color;
            float _Specular_Smoothness;
            float _Specular_Intensity;
            float _FresnelMin;
            float _FresnelMax;
            float _EnvRotate;
            samplerCUBE _Envmap;
            float4 _Envmap_HDR;
            float _Roughness;
            float _EnvIntensity;
            float _ParallaxIntensity;

            

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
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal_World = UnityObjectToWorldNormal(v.normal);
                o.tangent_World = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0)).xyz);
                o.binormal_World = normalize(cross(o.normal_World, o.tangent_World) * v.tangent.w);
                o.pos_World = mul(unity_ObjectToWorld, v.vertex);
                o.vertexColor = v.color;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // Dir
                float3 normal_World = normalize(i.normal_World);
                float3 tangent_World = normalize(i.tangent_World);
                float3 binormal_World = normalize(i.binormal_World);
                float3 pos_World = i.pos_World.xyz;
                // ForwardBase里只能处理平行光
                float3 light_World = normalize(_WorldSpaceLightPos0.xyz);
                float3 view_World = normalize(_WorldSpaceCameraPos.xyz - pos_World);

                // 法线相关数据
                half4 normal_Map   = tex2D(_NormalMap, i.uv);
                half3 normal_Data = UnpackNormal(normal_Map);
                float3x3 TBN = float3x3(tangent_World, binormal_World, normal_World);
                normal_World = normalize(mul(normal_Data, TBN));
                half3 anti_normal_Data = normal_Data;
                anti_normal_Data.xy = -anti_normal_Data.xy;
                half3 anti_normal_World = normalize(mul(anti_normal_Data, TBN));

                // 视差便宜
                float parallax_Depth = smoothstep(1.0, 0.5, (distance(i.uv, float2(0.5, 0.5)) / 0.2));
                float3 view_Tangent = normalize(mul(TBN, view_World));
                float2 parallax_Offset = parallax_Depth * (view_Tangent.xy / view_Tangent.z) * _ParallaxIntensity;

                // 贴图数据
                half3 base_Color   = tex2D(_MainTex, i.uv + parallax_Offset).rgb;
                half3 detail_Color  = tex2D(_DetailMap, i.uv).rgb;

                // 漫反射
                half NdotL = saturate(dot(normal_World, light_World));
                half half_Lambert = NdotL * 0.5 + 0.5;
                half diffuse_Term = half_Lambert;
                half3 final_Diffuse = base_Color * base_Color * diffuse_Term;


                // 边缘光/环境反射
                half fresnel = 1.0 - saturate(dot(normal_World, view_World));
                fresnel = smoothstep(_FresnelMin, _FresnelMax, fresnel);


                half3 reflect_Dir = reflect(-view_World, normal_World);
                reflect_Dir = RotateAround(_EnvRotate, reflect_Dir);
                float roughness = lerp(0, 0.95, saturate(_Roughness));
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mipmap_Level = roughness * 6.0;
                half4 cubemap_Color = texCUBElod(_Envmap, float4(reflect_Dir, mipmap_Level));
                half3 env_Color = DecodeHDR(cubemap_Color, _Envmap_HDR);
                half3 final_Env = env_Color * _EnvIntensity;
                half3 env_Lumin = dot(final_Env, float3(0.2126f, 0.7152f, 0.0722f));
                final_Env = final_Env;

                half3 final_Color = final_Diffuse + final_Env * final_Diffuse * final_Env + detail_Color;

                final_Color = sqrt(ACES_Tonemapping(final_Color));
                
                return half4(final_Color, 1);
            }
            ENDCG
        }
    }
}
