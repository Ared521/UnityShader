// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_WaterDepthPow("WaterDepthPow", Range( 0 , 2)) = 0
		_DeepWater("DeepWater", Color) = (0,0,0,0)
		_ShallowWater("ShallowWater", Color) = (0,0,0,0)
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Range( 5 , 20)) = 5
		_ShallowWaterTransparent("ShallowWaterTransparent", Range( 0 , 1)) = 0
		_NormalTilling("NormalTilling", Range( 0 , 10)) = 0
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalSpeed("Normal Speed", Vector) = (0,0,0,0)
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_ReflectDistort("ReflectDistort", Float) = 1
		_UnderWaterDistort("UnderWaterDistort", Range( 0.01 , 10)) = 0.01
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
		};

		uniform float4 _ShallowWater;
		uniform float _ShallowWaterTransparent;
		uniform float4 _DeepWater;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _WaterDepthPow;
		uniform float4 _FresnelColor;
		uniform float _FresnelPower;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _NormalMap;
		uniform float _NormalTilling;
		uniform float2 _NormalSpeed;
		uniform float _UnderWaterDistort;
		uniform sampler2D _ReflectionTex;
		uniform float _ReflectDistort;


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 appendResult38 = (float4((_ShallowWater).rgb , _ShallowWaterTransparent));
			float3 ase_worldPos = i.worldPos;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 In72_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 PositionFromDepth6 = (mul( unity_CameraToWorld, appendResult49_g1 )).xyz;
			float clampResult8 = clamp( ( ase_worldPos.y - (PositionFromDepth6).y ) , 0.0 , 1.0 );
			float WaterDepthLerp12 = pow( clampResult8 , _WaterDepthPow );
			float4 lerpResult15 = lerp( appendResult38 , _DeepWater , WaterDepthLerp12);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV19 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode19 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV19 , 0.0001 ), _FresnelPower ) );
			float4 lerpResult17 = lerp( lerpResult15 , _FresnelColor , fresnelNode19);
			float4 WaterColor22 = lerpResult17;
			float4 computeGrabScreenPos85 = ComputeGrabScreenPos( float4( 0,0,0,0 ) );
			float2 temp_output_52_0 = ( ( (ase_worldPos).xz * float2( 0.1,0.1 ) ) / _NormalTilling );
			float2 temp_output_56_0 = ( _NormalSpeed * _Time.y * 0.01 );
			float3 WaterNormal60 = BlendNormals( UnpackNormal( tex2D( _NormalMap, ( temp_output_52_0 + temp_output_56_0 ) ) ) , UnpackNormal( tex2D( _NormalMap, ( ( temp_output_52_0 * 2.0 ) + ( temp_output_56_0 * -0.615 ) ) ) ) );
			float4 screenColor84 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( computeGrabScreenPos85 + float4( ( WaterNormal60 * _UnderWaterDistort * 0.01 ) , 0.0 ) ).xy);
			float4 UnderWaterColor92 = screenColor84;
			float4 ReflectionColor80 = tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( (WaterNormal60).xy * ( _ReflectDistort * 0.01 ) ) ) );
			float WaterTransparent27 = pow( (lerpResult17).a , 3.0 );
			float4 lerpResult95 = lerp( ( WaterColor22 + UnderWaterColor92 ) , ReflectionColor80 , WaterTransparent27);
			o.Emission = lerpResult95.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
8;802;1137;189;2060.501;-144.5502;3.026262;True;False
Node;AmplifyShaderEditor.CommentaryNode;69;-1802.447,898.0432;Inherit;False;2198;609.1769;WaterNormal;19;52;67;55;57;66;65;64;62;63;56;68;51;49;61;58;53;50;60;83;WaterNormal;0,0.369226,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1449.769,-117.867;Inherit;False;1774.417;339.0763;WaterDepth;10;10;12;9;8;3;2;7;6;4;1;WaterDepth;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;49;-1765.09,948.0432;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;50;-1562.447,960.2202;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;1;-1417.197,103.8612;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;67;-1498.447,1158.22;Inherit;False;Property;_NormalSpeed;Normal Speed;8;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;51;-1752.447,1091.22;Inherit;False;Property;_NormalTilling;NormalTilling;6;0;Create;True;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1378.291,969.553;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1572.447,1368.22;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;4;-1063.197,98.86116;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-1605.447,1284.22;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1040.447,1212.22;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-894.197,108.8612;Inherit;False;PositionFromDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1285.447,1211.22;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;52;-1218.447,1042.22;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1072.447,1392.22;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;False;0;False;-0.615;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-898.9587,-67.867;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-857.4465,1294.22;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-851.4465,1180.22;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;7;-670.1971,109.8612;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;3;-502.9525,-33.75807;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-672.4466,1254.22;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-775.4465,1043.22;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;61;-489.4466,1231.22;Inherit;True;Property;_NormalMap2;Normal Map2;7;0;Create;True;0;0;False;0;False;58;None;None;True;0;False;bump;Auto;True;Instance;58;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;20;-1756.537,264.955;Inherit;False;2386.11;489.42;WaterColor;16;35;14;13;16;22;27;25;17;18;15;19;24;36;38;97;98;WaterColor;0,0.6176336,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-501.947,96.61121;Inherit;False;Property;_WaterDepthPow;WaterDepthPow;0;0;Create;True;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;8;-358.7141,-39.19384;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-528.4466,1005.22;Inherit;True;Property;_NormalMap;Normal Map;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;68;-68.44651,1139.22;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;14;-1717.945,311.955;Inherit;False;Property;_ShallowWater;ShallowWater;2;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;9;-197.2943,-19.5312;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;35;-1462.7,341.7073;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;171.5536,1133.22;Inherit;False;WaterNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1725.7,485.7071;Inherit;False;Property;_ShallowWaterTransparent;ShallowWaterTransparent;5;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;91.64805,-26.25821;Inherit;False;WaterDepthLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;-1664.309,1643.592;Inherit;False;1597;545;WaterReflection;11;75;73;76;77;71;74;78;72;79;70;80;WaterReflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;93;-1644.077,2261.635;Inherit;False;1182.401;454.9006;UnderWaterColor;8;87;85;86;88;89;84;90;92;UnderWaterColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-1616.077,2506.835;Inherit;False;Property;_UnderWaterDistort;UnderWaterDistort;11;0;Create;True;0;0;False;0;False;0.01;0;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1542.077,2601.536;Inherit;False;Constant;_Float4;Float 4;11;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1585.309,2073.592;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1614.309,1968.592;Inherit;False;Property;_ReflectDistort;ReflectDistort;10;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1578.477,2427.334;Inherit;False;60;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-1262.7,327.7073;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;13;-1304.537,431.69;Inherit;False;Property;_DeepWater;DeepWater;1;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;73;-1564.309,1878.592;Inherit;False;60;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-1094.43,508.3345;Inherit;False;12;WaterDepthLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-720.9639,576.5287;Inherit;False;Property;_FresnelPower;FresnelPower;4;0;Create;True;0;0;False;0;False;5;0;5;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-663.7239,394.2285;Inherit;False;Property;_FresnelColor;FresnelColor;3;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1326.278,2466.335;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComputeGrabScreenPosHlpNode;85;-1433.677,2329.635;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;74;-1312.309,1867.592;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;71;-1572.309,1693.592;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;15;-812.854,320.9095;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1305.309,1962.592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;19;-365.7407,458.6631;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-92.72661,319.4342;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;72;-1287.309,1719.592;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1097.309,1925.592;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1132.577,2346.735;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-940.3086,1818.592;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;84;-967.4783,2320.736;Inherit;False;Global;_GrabScreen0;Grab Screen 0;11;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;-38.68512,536.2513;Inherit;False;Constant;_WaterTransparentPower;WaterTransparentPower;12;0;Create;True;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;25;79.98839,440.9578;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;98;207.3149,493.2513;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-699.6778,2327.235;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;324.9857,314.2285;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;70;-762.7037,1739.434;Inherit;True;Property;_ReflectionTex;ReflectionTex;9;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;23;637.7754,-214.7984;Inherit;False;22;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;357.9885,441.9578;Inherit;False;WaterTransparent;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-295.3086,1789.592;Inherit;False;ReflectionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;627.7062,-125.8939;Inherit;False;92;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;758.6128,80.54021;Inherit;False;27;WaterTransparent;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;779.4273,-27.57666;Inherit;False;80;ReflectionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;958.5945,-153.457;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;95;1149.215,-9.980652;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;48;1485.38,47.41278;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;49;0
WireConnection;83;0;50;0
WireConnection;4;0;1;0
WireConnection;6;0;4;0
WireConnection;56;0;67;0
WireConnection;56;1;55;0
WireConnection;56;2;57;0
WireConnection;52;0;83;0
WireConnection;52;1;51;0
WireConnection;64;0;56;0
WireConnection;64;1;65;0
WireConnection;63;0;52;0
WireConnection;63;1;62;0
WireConnection;7;0;6;0
WireConnection;3;0;2;2
WireConnection;3;1;7;0
WireConnection;66;0;63;0
WireConnection;66;1;64;0
WireConnection;53;0;52;0
WireConnection;53;1;56;0
WireConnection;61;1;66;0
WireConnection;8;0;3;0
WireConnection;58;1;53;0
WireConnection;68;0;58;0
WireConnection;68;1;61;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;35;0;14;0
WireConnection;60;0;68;0
WireConnection;12;0;9;0
WireConnection;38;0;35;0
WireConnection;38;3;36;0
WireConnection;89;0;86;0
WireConnection;89;1;87;0
WireConnection;89;2;88;0
WireConnection;74;0;73;0
WireConnection;15;0;38;0
WireConnection;15;1;13;0
WireConnection;15;2;16;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;19;3;24;0
WireConnection;17;0;15;0
WireConnection;17;1;18;0
WireConnection;17;2;19;0
WireConnection;72;0;71;0
WireConnection;78;0;74;0
WireConnection;78;1;77;0
WireConnection;90;0;85;0
WireConnection;90;1;89;0
WireConnection;79;0;72;0
WireConnection;79;1;78;0
WireConnection;84;0;90;0
WireConnection;25;0;17;0
WireConnection;98;0;25;0
WireConnection;98;1;97;0
WireConnection;92;0;84;0
WireConnection;22;0;17;0
WireConnection;70;1;79;0
WireConnection;27;0;98;0
WireConnection;80;0;70;0
WireConnection;100;0;23;0
WireConnection;100;1;94;0
WireConnection;95;0;100;0
WireConnection;95;1;81;0
WireConnection;95;2;28;0
WireConnection;48;2;95;0
ASEEND*/
//CHKSM=EC5DE42EDFDA525594267D489D59A8779FEFF712