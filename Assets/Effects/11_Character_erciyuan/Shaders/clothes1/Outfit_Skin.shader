Shader "Unlit/Outfit_Skin"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AOMap ("AO Map", 2D) = "white" {}
        _DiffuseRamp ("Diffuse Ramp", 2D) = "white" {}
        _DiffuseLayer1_Offset ("Diffuse Layer1 Offset", Range(0, 1)) = 0.5
        _DiffuseLayer1_Color ("Diffuse Layer1 Color", Color) = (1, 1, 1, 1)
        _DiffuseLayer2_Offset ("Diffuse Layer2 Offset", Range(0, 1)) = 0.5
        _DiffuseLayer2_Color ("Diffuse Layer2 Color", Color) = (1, 1, 1, 1)
        _DiffuseLayer3_Offset ("Diffuse Layer3 Offset", Range(0, 1)) = 0.5
        _DiffuseLayer3_Color ("Diffuse Layer3 Color", Color) = (1, 1, 1, 1)
        _Specular_Color ("Specular Color", Color) = (1, 1, 1, 1)
        _Specular_Smoothness ("Specular Smoothness", Float) = 0.5
        _Specular_Intensity ("Specular Intensity", Float) = 0.5
        _FresnelMin ("Fresnel Min", Float) = 0.5
        _FresnelMax ("Fresnel Max", Float) = 0.5
        _Outline ("Outline", Range(0, 1)) = 0.2
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)


    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        LOD 100
        Pass
        {
            Name "Outline"
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _Outline;
            float4 _OutlineColor;

            struct v2f
            {
                float4 vertex:SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                // 将顶点变换到视角空间
                float4 pos = mul(UNITY_MATRIX_V, mul(unity_ObjectToWorld,v.vertex));
                // 将法线变换到视角空间
                float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
                pos = pos + float4(normal,0) * _Outline * 0.01;
                // 将顶点变换到裁剪空间
                o.vertex = mul(UNITY_MATRIX_P,pos);
                return o;
            }
            fixed4 frag(v2f i):SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
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
            sampler2D _AOMap;
            sampler2D _DiffuseRamp;
            float _DiffuseLayer1_Offset;
            float4 _DiffuseLayer1_Color;
            float4 _DiffuseLayer2_Color;
            float _DiffuseLayer2_Offset;
            float4 _DiffuseLayer3_Color;
            float _DiffuseLayer3_Offset;
            float4 _Specular_Color;
            float _Specular_Smoothness;
            float _Specular_Intensity;
            float _FresnelMin;
            float _FresnelMax;


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

                // 贴图数据
                half3 base_Color   = tex2D(_MainTex, i.uv).rgb;
                half AO            = tex2D(_AOMap, i.uv).r;
                half3 diffuseRamp  = tex2D(_DiffuseRamp, i.uv).rgb;

                // 漫反射
                half NdotL = saturate(dot(normal_World, light_World));
                half half_Lambert = NdotL * 0.5 + 0.5;
                half diffuse_Term = half_Lambert * AO;

                half3 final_Diffuse = half3(0, 0, 0);
                // 第一层上色
                half2 uv_Ramp1 = half2(diffuse_Term + _DiffuseLayer1_Offset, 0.5);
                half diffuseLayer1 = tex2D(_DiffuseRamp, uv_Ramp1).r;
                half3 diffuseLayer1_Color = lerp(half3(1, 1, 1), _DiffuseLayer1_Color.rgb, diffuseLayer1 * _DiffuseLayer1_Color.a);
                final_Diffuse = base_Color * diffuseLayer1_Color;
                // 第二层上色
                half2 uv_Ramp2 = half2(diffuse_Term + _DiffuseLayer2_Offset, i.vertexColor.r);
                half diffuseLayer2 = tex2D(_DiffuseRamp, uv_Ramp2).g;
                half3 diffuseLayer2_Color = lerp(half3(1, 1, 1), _DiffuseLayer2_Color.rgb, diffuseLayer2 * _DiffuseLayer2_Color.a);
                final_Diffuse = final_Diffuse * diffuseLayer2_Color;
                // 第三层上色
                half2 uv_Ramp3 = half2(diffuse_Term + _DiffuseLayer3_Offset, 0.5);
                half diffuseLayer3 = tex2D(_DiffuseRamp, uv_Ramp2).b;
                half3 diffuseLayer3_Color = lerp(half3(1, 1, 1), _DiffuseLayer3_Color.rgb, diffuseLayer3 * _DiffuseLayer3_Color.a);
                final_Diffuse = final_Diffuse * diffuseLayer3_Color;

                // 高光
                half3 H = normalize(light_World + view_World);
                half NdotH = saturate(dot(normal_World, H));
                half specular_Term = max(0.0001, pow(NdotH, _Specular_Smoothness * 5)) * AO;
                half3 final_Specular = specular_Term * _Specular_Intensity * _Specular_Color.rgb;

                // 边缘光/环境反射
                half fresnel = 1.0 - saturate(dot(normal_World, view_World));
                fresnel = smoothstep(_FresnelMin, _FresnelMax, fresnel);

                half3 final_Color = final_Diffuse + final_Specular + fresnel.xxx;

                
                return half4(final_Color, 1);
            }
            ENDCG
        }
    }
}
