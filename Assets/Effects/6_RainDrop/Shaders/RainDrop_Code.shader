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

                // 更改雨滴下落速度(基础)
                UV_Center.y += time;

                // Random
                // 注！！！ 由于这里的 UV_Center 求 floor，所以每个格子的随机值都是不一样的。
                float random = dot(floor(UV_Center), float2(12.9898,78.233));
				random = lerp(0.0, 1.0, frac((sin(random) * 43758.55)));

                // 更改雨滴下落速度(附加)
                // UV_Center.y += cos(time * random);

                // Y_Wiggle
                float V_Wiggle = random * 6.15 + time;
                V_Wiggle = 0.3 * sin(sin(sin(V_Wiggle) * 0.5 + V_Wiggle) + V_Wiggle);

                // 会根据水滴竖直轨迹的 V，也就是高度，水平速度变换。
                float U_Wiggle_Speed = i.uv.y * 8;
                float U_Wiggle = pow(sin(U_Wiggle_Speed), 6) * sin(3 * U_Wiggle_Speed) * 0.25;
                U_Wiggle += (random - 0.5) * 0.5;
                
                UV_Center = frac(UV_Center);
                UV_Center -= float2(0.5, 0.5);
                float UV_Mask_Y = UV_Center.y;
                UV_Center.x -= U_Wiggle;
                UV_Center.y -= V_Wiggle;

                // TrackDrop 小雨滴
                float trackDropCount = 8;
                float trackDrop_Center_Y = frac((UV_Center.y - time) * trackDropCount) + float2(-0.5, -0.5);
                trackDrop_Center_Y /= trackDropCount;
                float2 UV_Center_LittleDrop = float2(UV_Center.x, trackDrop_Center_Y);
                UV_Center_LittleDrop /= float2(drop_HorizonSize, 1);
                float length_Center_LittleDrop = length(UV_Center_LittleDrop);
                float trackDrop = smoothstep(0.05, 0.03, length_Center_LittleDrop);
                
                // 第一个 Mask 是，大雨滴下面不显示小雨滴。
                float trackDropMask1 = smoothstep(0, 0.01, UV_Center.y);
                // 第二个 Mask 是，小雨滴越往上，颜色值越浅，视觉上有一个透明度变换的效果，其实改变的
                // 是颜色值，不是透明度。
                float trackDropMask2 = smoothstep(0.7, -0.3, UV_Mask_Y);
                trackDrop *= trackDropMask1;
                trackDrop *= trackDropMask2;

                // Track
                float track_U = 1 - smoothstep(0.125, 0.175, abs(UV_Center.x));
                float track_V = smoothstep(-0.02, 0, UV_Center.y);
                float track = track_U * track_V * trackDropMask2;

                // MainDrop 大雨滴
                UV_Center /= float2(drop_HorizonSize, 1);
                float length_Center = length(UV_Center);
                float mainDrop = smoothstep(0.1, 0.075, length_Center);

                return (mainDrop + trackDrop + track).xxxx;
            }
            ENDCG
        }
    }
}
