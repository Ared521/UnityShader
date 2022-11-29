Shader "Effects_Unlit/6_RainDrop_Code"
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
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 baseColor = tex2D(_MainTex, i.uv);
                float time = _Time.y;
                float dropSize = 5;
                float drop_HorizonSize = 2;
                float2 UV_Center = (i.uv * float2(drop_HorizonSize, 1)) * dropSize;

                // ������������ٶ�(����)
                UV_Center.y += time;

                // Random
                // ע������ ��������� UV_Center �� floor������ÿ�����ӵ����ֵ���ǲ�һ���ġ�
                float random = dot(floor(UV_Center), float2(12.9898,78.233));
				random = lerp(0.0, 1.0, frac((sin(random) * 43758.55)));

                // ������������ٶ�(����)
                // UV_Center.y += cos(time * random);

                // Y_Wiggle
                float V_Wiggle = random * 6.15 + time;
                V_Wiggle = 0.3 * sin(sin(sin(V_Wiggle) * 0.5 + V_Wiggle) + V_Wiggle);

                // �����ˮ����ֱ�켣�� V��Ҳ���Ǹ߶ȣ�ˮƽ�ٶȱ任��
                float U_Wiggle_Speed = i.uv.y * 8;
                float U_Wiggle = pow(sin(U_Wiggle_Speed), 6) * sin(3 * U_Wiggle_Speed) * 0.25;
                U_Wiggle += (random - 0.5) * 0.5;
                
                UV_Center = frac(UV_Center);
                UV_Center -= float2(0.5, 0.5);
                float UV_Mask_Y = UV_Center.y;
                UV_Center.x -= U_Wiggle;
                UV_Center.y -= V_Wiggle;

                // TrackDrop С���
                float trackDropCount = 8;
                float trackDrop_Center_Y = frac((UV_Center.y - time) * trackDropCount) + float2(-0.5, -0.5);
                trackDrop_Center_Y /= trackDropCount;
                float2 UV_Center_LittleDrop = float2(UV_Center.x, trackDrop_Center_Y);
                UV_Center_LittleDrop /= float2(drop_HorizonSize, 1);
                float length_Center_LittleDrop = length(UV_Center_LittleDrop);
                float trackDrop = smoothstep(0.05, 0.03, length_Center_LittleDrop);
                
                // ��һ�� Mask �ǣ���������治��ʾС��Ρ�
                float trackDropMask1 = smoothstep(0, 0.01, UV_Center.y);
                // �ڶ��� Mask �ǣ�С���Խ���ϣ���ɫֵԽǳ���Ӿ�����һ��͸���ȱ任��Ч������ʵ�ı��
                // ����ɫֵ������͸���ȡ�
                float trackDropMask2 = smoothstep(0.7, -0.3, UV_Mask_Y);
                trackDrop *= trackDropMask1;
                trackDrop *= trackDropMask2;

                // Track
                float track_U = 1 - smoothstep(0.125, 0.175, abs(UV_Center.x));
                float track_V = smoothstep(-0.02, 0, UV_Center.y);
                float track = track_U * track_V * trackDropMask2;

                // MainDrop �����
                UV_Center /= float2(drop_HorizonSize, 1);
                float length_Center = length(UV_Center);
                float mainDrop = smoothstep(0.1, 0.075, length_Center);

                return (mainDrop + trackDrop + track).xxxx;
            }
            ENDCG
        }
    }
}
