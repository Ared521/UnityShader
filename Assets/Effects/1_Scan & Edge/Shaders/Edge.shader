Shader "Effects_Unlit/1_Edge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeIntensity ("EdgeIntensity", Range(0, 100)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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
                float3 normal_WorldDir : TEXCOORD1;
                float3 pos_World : TEXCOORD2;
                float3 view_WorldDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _EdgeIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 pos_World = mul(unity_ObjectToWorld, v.vertex);
                o.pos_World = pos_World;
                //o.normal_WorldDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.normal_WorldDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.view_WorldDir = normalize(_WorldSpaceCameraPos.xyz - pos_World);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 baseColor = tex2D(_MainTex, i.uv).xyz;
                half NdotV = max(0.0, dot(i.view_WorldDir, i.normal_WorldDir));
                half fresnel = pow((1 - NdotV), _EdgeIntensity);
                half4 final_Color = half4(baseColor, fresnel);
                
                return final_Color;
            }
            ENDCG
        }
    }
}
