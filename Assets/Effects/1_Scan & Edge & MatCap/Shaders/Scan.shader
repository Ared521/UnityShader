Shader "Unlit/Scan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanTex ("ScanTex", 2D) = "white" {}
        _ScanSpeed ("ScanSpeed", Range(0, 10)) = 1
        _EdgeIntensity ("EdgeIntensity", Range(0, 100)) = 1
        _BloomIntensity ("BloomIntensity", Range(0, 5)) = 2
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
                float3 view_WorldDir : TEXCOORD2;
                float3 pos_World : TEXCOORD3;
                float3 pos_ZeroToWorld : TEXCOORD4;
                float2 uv_WorldPos : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ScanTex;
            float4 _ScanTex_ST;
            float _ScanSpeed;
            float _EdgeIntensity;
            float _BloomIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_World = mul(unity_ObjectToWorld, v.vertex);
                o.view_WorldDir = normalize(_WorldSpaceCameraPos.xyz - o.pos_World);
                o.normal_WorldDir = normalize(UnityObjectToWorldNormal(v.normal));
                /*齐次坐标概念，4维向量最后一位：1表示点，0表示向量。注：下面加的flaot4(0,0,0,1),
                其中的 0 改成别的任意值都可以，因为只是保证相对于某个点的大小是不会随物体位置变化而变化的。
                相对某个点位置不变的意思是：当物体在移动或旋转的时候，与他相对的也同样做 M 矩阵变换，
                两者相减的结果就是，该物体是静止的，计算出的 UV 不会随物体的移动而改变。*/
                o.pos_ZeroToWorld = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                //扫光效果不受物体位置变换影响。
                o.uv_WorldPos = (o.pos_World.xy - o.pos_ZeroToWorld.xy);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 baseColor = tex2D(_MainTex, i.uv);
                half NdotV = max(0.0, dot(i.view_WorldDir, i.normal_WorldDir));
                half fresnel = pow((1 - NdotV), _EdgeIntensity);


                half2 scan_UV = (i.uv_WorldPos + (_ScanSpeed * _Time.y));
                half4 scanColor = tex2D(_ScanTex, scan_UV) * _BloomIntensity;
                half4 finalColor = baseColor * fresnel + scanColor;
                return finalColor;
            }
            ENDCG
        }
    }
}
