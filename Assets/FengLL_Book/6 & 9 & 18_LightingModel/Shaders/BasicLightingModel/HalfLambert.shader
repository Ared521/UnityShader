Shader "FengLL_Book/Chapter6 & 9 & 18/6_HalfLambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse Color", COLOR) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"


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
                float3 pos_world : TEXCOORD1;
                float3 normal_WorldDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _DiffuseColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal_WorldDir = mul(v.normal, (float3x3)unity_WorldToObject);
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

                fixed3 color_FinalRGB = ambient + diffuse;
                return fixed4(color_FinalRGB, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
