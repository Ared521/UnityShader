Shader "FengLL_Book/Chapter4/ComputeScreenPos"
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
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            
            inline float4 ComputeScreenPos_Code(float4 pos) {
                float4 o = pos * 0.5f;
                #if defined(UNITY_HALF_TEXEL_OFFSET)
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + 0.w * _ScreenParams.zw;
                #else
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                #endif

                o.zw = pos.zw;
                return o;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //ComputeScreenPos_Code ÊÇ ComputeScreenPos µÄÔ´Âë¡£
                o.screenPos = ComputeScreenPos(o.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv_viewprotSpace = i.screenPos.xy / i.screenPos.w;

                return fixed4(uv_viewprotSpace, 0, 1);
            }
            ENDCG
        }
    }
}
