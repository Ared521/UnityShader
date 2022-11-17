Shader "FengLL_Book/Chapter5/UnityCG_cginc"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal_WorldDir : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // appdata_base 是 UnityCG.cginc 里的结构体。
            // struct appdata_base {
            // float4 vertex : POSITION;
            // float3 normal : NORMAL;
            // float4 texcoord : TEXCOORD0;
            // UNITY_VERTEX_INPUT_INSTANCE_ID
            // };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal_WorldDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.normal_WorldDir, 1);
                return col;
            }
            ENDCG
        }
    }
}
