// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "FengLL_Book/Chapter6 & 9 & 18/9_Use UNITY_LIGHT_ATTENUATION"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse Color", COLOR) = (1, 1, 1, 1)
        _SpeclarColor ("Speclar Color", COLOR) = (1, 1, 1, 1)
        _SpecularPower ("Specular Power", Range(8, 256)) = 32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 pos_World : TEXCOORD1;
                float3 normal_WorldDir : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _DiffuseColor;
            float4 _SpeclarColor;
            float _SpecularPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.pos_World = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_WorldDir = mul(v.normal, (float3x3)unity_WorldToObject);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 颜色和方向矢量都可以用 fixed
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 normal_WorldDir = normalize(i.normal_WorldDir);
                fixed3 light_WorldDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed halfLambert = dot(normal_WorldDir, light_WorldDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.xyz * _DiffuseColor.xyz * halfLambert;

                fixed3 view_WorldDir = normalize(_WorldSpaceCameraPos.xyz - i.pos_World);
                fixed3 halfNormalAndLight_WorldDir = normalize(light_WorldDir + view_WorldDir);
                fixed3 specular = _LightColor0.xyz * _SpeclarColor * pow(max(0, dot(halfNormalAndLight_WorldDir, normal_WorldDir)), _SpecularPower);

                UNITY_LIGHT_ATTENUATION(atten, i, i.pos_World);

                fixed3 color_FinalRGB = ambient + (diffuse + specular) * atten;
                return fixed4(color_FinalRGB, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            // Use the line below to add shadows for point and spot lights
            #pragma multi_compile_fwdadd_fullshadows

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 pos_World : TEXCOORD1;
                float3 normal_WorldDir : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _DiffuseColor;
            float4 _SpeclarColor;
            float _SpecularPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.pos_World = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_WorldDir = mul(v.normal, (float3x3)unity_WorldToObject);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 颜色和方向矢量都可以用 fixed
                
                // ForwardAdd Pass 中就不需要再次计算环境光了。
                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;


                // 计算不同光源方向，平行光跟物体的顶点位置无关。
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 light_WorldDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 light_WorldDir = normalize(_WorldSpaceLightPos0.xyz - i.pos_World);
                #endif

                UNITY_LIGHT_ATTENUATION(atten, i, i.pos_World);

                fixed3 normal_WorldDir = normalize(i.normal_WorldDir);
                fixed halfLambert = dot(normal_WorldDir, light_WorldDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.xyz * _DiffuseColor.xyz * halfLambert;

                fixed3 view_WorldDir = normalize(_WorldSpaceCameraPos.xyz - i.pos_World);
                fixed3 halfNormalAndLight_WorldDir = normalize(light_WorldDir + view_WorldDir);
                fixed3 specular = _LightColor0.xyz * _SpeclarColor * pow(max(0, dot(halfNormalAndLight_WorldDir, normal_WorldDir)), _SpecularPower);

                fixed3 color_FinalRGB = (diffuse + specular) * atten;
                return fixed4(color_FinalRGB, 1);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}