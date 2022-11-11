Shader "Unlit/IBL_CubeMap"
{
    Properties
    {
        _CubeMap ("CabeMap", CUBE) = "white" {}
        _IBLIntensity ("IBL Intensity", Range(1, 10)) = 1
        _baseColor ("Base Color", COLOR) = (1, 1, 1, 1)
        _reflectDirRotate ("ReflectDir Rotate", Range(0, 360)) = 0
        _AOMap ("AO Map", 2D) = "white" {}
        _AOIntensity ("AO Intensity", Range(0, 1)) = 1
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _RoughnessMapIntensity ("RoughnessMap Intensity", Range(0, 1)) = 1
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 pos_World : TEXCOORD1;
                float3 normal_WorldDir : TEXCOORD2;
            };

            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            float4 _baseColor;
            sampler2D _AOMap;
            float _AOIntensity;
            sampler2D _RoughnessMap;
            float4 _RoughnessMap_ST;
            float _RoughnessMapIntensity;
            float _IBLIntensity;
            float _reflectDirRotate;


            float3 RotateAround(float degree, float3 target)
			{
				float rad = degree * UNITY_PI / 180;
				float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
					sin(rad), cos(rad));
				float2 dir_rotate = mul(m_rotate, target.xz);
				target = float3(dir_rotate.x, target.y, dir_rotate.y);
				return target;
			}

			inline float3 ACES_Tonemapping(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x + d) + e));
				return encode_color;
			};

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_World = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_WorldDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = TRANSFORM_TEX(v.texcoord, _RoughnessMap);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half ao = tex2D(_AOMap, i.uv).r;
                ao = pow(ao, _AOIntensity);

                half roughness = tex2D(_RoughnessMap, i.uv).r;
                roughness = 1 - saturate(pow(roughness, _RoughnessMapIntensity));
                // texCUBElod 求 mipmap值的写法。
                roughness = roughness * (1.7 - 0.7 * roughness);
				float mipmap_level = roughness * 6.0;

                half3 view_WorldDir = normalize(_WorldSpaceCameraPos.xyz - i.pos_World);
                half3 cubeMap_ReflectDir = reflect(-view_WorldDir, i.normal_WorldDir);
                cubeMap_ReflectDir = RotateAround(_reflectDirRotate, cubeMap_ReflectDir);


                /*
                //CubeMap会有问题，当物体上不同的两个点的反射向量是同一方向，就会造成结果一样的情况。
                //采用unity内置经纬度计算公式如下，传入三维反射方向向量，可以求出uv坐标，然后采样2D贴图即可。
                float3 normalizedCoords = normalize(reflect_dir);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
				float2 uv_panorama =  float2(0.5, 1.0) - sphereCoords;
                */


                half4 cubeMap = texCUBElod(_CubeMap, float4(cubeMap_ReflectDir, mipmap_level));
                //确保在移动端能拿到HDR信息
                half3 IBL = DecodeHDR(cubeMap, _CubeMap_HDR);
                half3 finalColor = IBL * ao * _IBLIntensity * _baseColor.rgb * _baseColor.rgb;
                half3 finalColor_LinearSpace = pow(finalColor, 2.2);
				finalColor = ACES_Tonemapping(finalColor_LinearSpace);
				half3 finalColor_GammaSpace = pow(finalColor, 1.0 / 2.2);

				return float4(finalColor_GammaSpace, 1.0);
            }
            ENDCG
        }
    }
}
