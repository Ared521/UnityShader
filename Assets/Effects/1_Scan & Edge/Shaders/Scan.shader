Shader "Effects_Unlit/1_Scan"
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
                /*���������4ά�������һλ��1��ʾ�㣬0��ʾ������ע������ӵ�flaot4(0,0,0,1),
                ���е� 0 �ĳɱ������ֵ�����ԣ�������Ϊ��ģ���ϵ�ĳһ�㡣
                ��Ϊֻ�Ǳ�֤�����ĳ����Ĵ�С�ǲ���������λ�ñ仯���仯�ġ�
                ���ĳ����λ�ò������˼�ǣ����������ƶ�����ת��ʱ��ģ���ϵ�ĳһ��(Ҳ���������float4(0,0,0,1))Ҳͬ���� M ����任��
                ��������Ľ�����ǣ��������Ǿ�ֹ�ģ�������� UV ������������ƶ����ı䡣*/
                o.pos_ZeroToWorld = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                //ɨ��Ч����������λ�ñ任Ӱ�졣
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

//fixed4 col = (0, 0, 0, 0);
//for (int i = 0; i < 32; i++) {
//    float2 offset = float2(sin(Random), cos(Random)) * BlurIntensity;
//    offset *= frac(sin(i) * 12.05);
//    float2 normal = tex2D(NormalTex, Texcoord).xy;
//    col += tex2D(MainTex, UV + normal + offset);
//    Random++;
//}
//col /= 32;
//return col;
