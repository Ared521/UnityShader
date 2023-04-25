Shader "Unlit/LeftEye"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EnvRotate ("Env Rotate", Float) = 0
        _Envmap ("Evnmap", Cube) = "white" {}
        _Roughness ("Roughness", Float) = 0.5
        _EnvIntensity ("Env Intensity", Float) = 0.5

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
            float _EnvRotate;
            samplerCUBE _Envmap;
            float4 _Envmap_HDR;
            float _Roughness;
            float _EnvIntensity;
            

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
                // 贴图数据
                half3 base_Color   = tex2D(_MainTex, i.uv).rgb;

                // Dir
                float3 normal_World = normalize(i.normal_World);
                float3 pos_World = i.pos_World.xyz;

                float3 light_World = normalize(_WorldSpaceLightPos0.xyz);
                float3 view_World = normalize(_WorldSpaceCameraPos.xyz - pos_World);

                // 环境反射
                half3 reflect_Dir = reflect(-view_World, normal_World);
                reflect_Dir = RotateAround(_EnvRotate, reflect_Dir);
                float roughness = lerp(0, 0.95, saturate(_Roughness));
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mipmap_Level = roughness * 6.0;
                half4 cubemap_Color = texCUBElod(_Envmap, float4(reflect_Dir, mipmap_Level));
                half3 env_Color = DecodeHDR(cubemap_Color, _Envmap_HDR);
                half3 final_Env = env_Color * _EnvIntensity;
                // half3 env_Lumin = dot(final_Env, float3(0.2126f, 0.7152f, 0.0722f));
                half3 final_Color = final_Env;

                final_Color = sqrt(ACES_Tonemapping(final_Color));
                
                return half4(final_Color, 1);
            }
            ENDCG
        }
    }
}
