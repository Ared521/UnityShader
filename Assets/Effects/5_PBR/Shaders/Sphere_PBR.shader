Shader "Effects_Unlit/5_PBR"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("BaseColor", Color) = (1 ,1 ,1 ,1)
		[Gamma] _Metallic ("Metallic", Range(0, 5)) = 0 //������Ҫ����٤��У��
		_Smoothness ("Smoothness", Range(0, 5)) = 0.5
		_LUT ("LUT", 2D) = "white" {}
		_MetallicGlossMap ("Metallic",2D) = "white"{} //����ͼ��rͨ���洢�����ȣ�aͨ���洢�⻬��
		_NormalMap ("Normal Map",2D) = "bump"{}//������ͼ
		_NormalIntensity ("NormalIntensity", Range(-5, 5)) = 1
		_OcclusionMap ("Occlusion",2D) = "white"{}//�������ڵ�����
		_IBLDiffuseIntensity ("IBLDiffuseIntensity", Range(0, 5)) = 1
		_IBLSpecIntensity ("IBLSpecIntensity", Range(0, 5)) = 1
	}

		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags {
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM


			#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#include "UnityStandardBRDF.cginc" 

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			float4 _BaseColor;
			float _Metallic;
			float _Smoothness;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LUT;
			sampler2D _MetallicGlossMap;
			sampler2D _NormalMap;
			float _NormalIntensity;
			sampler2D _OcclusionMap;
			float _IBLDiffuseIntensity;
			float _IBLSpecIntensity;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = normalize(UnityObjectToWorldNormal(v.normal));
				return o;
			}

			half3 ComputeDisneyDiffuseTerm(half nv, half nl, half lh, half roughness, half3 baseColor)
			{
				half Fd90 = 0.5f + 2 * roughness * lh * lh;
				return baseColor * UNITY_INV_PI * (1 + (Fd90 - 1) * pow(1-nl,5)) * (1 + (Fd90 - 1) * pow(1-nv,5));
			}

			half ComputeSmithJointGGXVisibilityTerm(half nl,half nv,half roughness)
			{
				half ag = roughness * roughness;
				half lambdaV = nl * (nv * (1 - ag) + ag);
				half lambdaL = nv * (nl * (1 - ag) + ag);
			
				return 0.5f/(lambdaV + lambdaL + 1e-5f);
			}

			float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
			{
				return F0 + (max(float3(1 ,1, 1) * (1 - roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
			}

			float3 frag(v2f i) : SV_Target
			{
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				float3 lightColor = _LightColor0.rgb;
				float3 halfVector = normalize(lightDir + viewDir);  //�������

				half2 metallicGloss = tex2D(_MetallicGlossMap,i.uv).ra;
				half metallic = metallicGloss.x * _Metallic;//������
				half smoothness =  saturate(1 - metallicGloss.y * _Smoothness);//�ֲڶ�

				float perceptualRoughness = 1 - smoothness;

				float roughness = perceptualRoughness * perceptualRoughness;
				float squareRoughness = roughness * roughness;

				float3 normalTex = UnpackNormal(tex2D(_NormalMap, i.uv));
				float3 normal_world = i.normal;
				normal_world = normalize(float3(normalTex.x * _NormalIntensity + normal_world.x,
												normalTex.y * _NormalIntensity + normal_world.y, normal_world.z));

				float nl = max(saturate(dot(normal_world, lightDir)), 0.000001);//��ֹ��0
				float nv = max(saturate(dot(normal_world, viewDir)), 0.000001);
				float vh = max(saturate(dot(viewDir, halfVector)), 0.000001);
				float lh = max(saturate(dot(lightDir, halfVector)), 0.000001);
				float nh = max(saturate(dot(normal_world, halfVector)), 0.000001);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);//������Ӱ��˥��,������AutoLight.cginc

				
				float3 Albedo = tex2D(_MainTex, i.uv) * _BaseColor;
				

				//D: normal distribution function��NDF�����߷ֲ�����
				float lerpSquareRoughness = pow(lerp(0.002, 1, smoothness), 2);//Unity��roughness lerp����0.002
				float D = lerpSquareRoughness / (pow((pow(nh, 2) * (lerpSquareRoughness - 1) + 1), 2) * UNITY_PI);

				//G shadowing-masking function����Ӱ�����ں���
				float kInDirectLight = pow(squareRoughness + 1, 2) / 8;
				float kInIBL = pow(squareRoughness, 2) / 2;
				float GLeft = nl / lerp(nl, 1, kInDirectLight);
				float GRight = nv / lerp(nv, 1, kInDirectLight);
				float G = GLeft * GRight;
				float V = ComputeSmithJointGGXVisibilityTerm(nl, nv, smoothness);

			    //F Fresnel reflectance���ķ���������
				float3 F0 = lerp(unity_ColorSpaceDielectricSpec.rgb, Albedo, metallic);
				//΢�ۣ�����NDF���������������� h
				float3 F = F0 + (1 - F0) * exp2((-5.55473 * vh - 6.98316) * vh);
				//���
				float3 F1 = lerp((1 - (pow(dot(normal_world, viewDir), 5))), 1, F0);

				float kd = (1 - F) * (1 - metallic);

				//ֱ�ӹ�������
				float3 diffColor = kd * Albedo;
				diffColor = ComputeDisneyDiffuseTerm(nv, nl, lh, smoothness, diffColor);

				//float3 SpecularResult = (D * G * F * 0.25) / (nv * nl);
				float3 SpecularResult = D * V * F;
				float3 specColor = SpecularResult;
				float3 DirectLightResult = UNITY_PI * (diffColor + specColor) * lightColor * nl * atten;

				//��ӹⲿ��
				//��ӹ�������
				half3 ambient_contrib = ShadeSH9(float4(normal_world, 1));
				float3 ambient = 0.03 * Albedo;
				float3 iblDiffuse = max(half3(0, 0, 0), ambient.rgb + ambient_contrib);
				float kdLast = 1;
				float3 iblDiffuseResult = iblDiffuse * kdLast * Albedo;
				
				//��ӹ⾵�淴��
				float mip_roughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
				float3 reflectVec = reflect(-viewDir, normal_world);

				half mip = mip_roughness * UNITY_SPECCUBE_LOD_STEPS;
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVec, mip);
				float3 iblSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);

				//float2 envBDRF = tex2D(_LUT, float2(lerp(0, 0.99, nv), lerp(0, 0.99, roughness))).rg; // LUT����

				//float3 Flast = fresnelSchlickRoughness(max(nv, 0.0), F0, roughness);
				//kdLast = (1 - Flast) * (1 - metallic);

				//iblDiffuseResult = iblDiffuse * kdLast * Albedo;
				//float3 iblSpecularResult = iblSpecular * (Flast * envBDRF.r + envBDRF.g);
				float3 iblSpecularResult = iblSpecular;

				float3 IndirectResult = (iblDiffuseResult * _IBLDiffuseIntensity) + (iblSpecularResult * _IBLSpecIntensity);

				float3 color = DirectLightResult + IndirectResult;
				float4 result = float4(color, 1);

				return result;
			}
			ENDCG
		}
	}
}