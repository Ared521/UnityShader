// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_UnderWaterTex("UnderWaterTex", 2D) = "white" {}
		_UnderWaterTexOffset("UnderWaterTexOffset", Range( 0 , 0.1)) = 0
		_WaterDepth("WaterDepth", Range( 0 , 10)) = 0
		_WaterNormalTex("WaterNormalTex", 2D) = "bump" {}
		_NormalTilling("NormalTilling", Float) = 8
		_WaterNormal_Intensity("WaterNormal_Intensity", Range( 0 , 10)) = 0
		_WaterFlowSpeed("WaterFlowSpeed", Range( 0 , 1)) = 0
		_UnderWaterTilling("UnderWaterTilling", Float) = 4
		_SpecShininess("SpecShininess", Range( 0 , 100)) = 0
		_SpecIntensity("SpecIntensity", Range( 0.01 , 5)) = 0.01
		_SpecularColor("SpecularColor", Color) = (0.6603774,0.2974091,0.1650943,0)
		_FogStart("FogStart", Range( 0 , 500)) = 0
		_FogEnd("FogEnd", Range( 0 , 1000)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		Stencil
		{
			Ref 1
		}
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float3 viewDir;
			float4 screenPos;
		};

		uniform sampler2D _WaterNormalTex;
		uniform float _NormalTilling;
		uniform float _WaterFlowSpeed;
		uniform float _SpecShininess;
		uniform float _SpecIntensity;
		uniform float4 _SpecularColor;
		uniform float _FogEnd;
		uniform float _FogStart;
		uniform sampler2D _UnderWaterTex;
		uniform float _UnderWaterTilling;
		uniform float _UnderWaterTexOffset;
		uniform float _WaterDepth;
		uniform sampler2D _ReflectionTex;
		uniform float _WaterNormal_Intensity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 temp_cast_0 = (( sin( pow( abs( sin( _Time.y ) ) , 3.0 ) ) * 0.02 )).xxx;
			v.vertex.xyz += temp_cast_0;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult107 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult109 = clamp( dotResult107 , 0.0 , 1.0 );
			float temp_output_111_0 = ( 1.0 - clampResult109 );
			float clampResult132 = clamp( ( temp_output_111_0 + 0.15 ) , 0.0 , 1.0 );
			float Water_Fresnel_Value130 = clampResult132;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult78 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float2 temp_output_16_0 = ( (ase_worldPos).xz / _NormalTilling );
			float temp_output_14_0 = ( _Time.y * _WaterFlowSpeed );
			float2 temp_output_19_0 = (( UnpackNormal( tex2D( _WaterNormalTex, ( temp_output_16_0 + temp_output_14_0 ) ) ) + UnpackNormal( tex2D( _WaterNormalTex, ( ( temp_output_16_0 * 1.5 ) + ( temp_output_14_0 * -0.5 ) ) ) ) )).xy;
			float2 temp_output_31_0 = ( temp_output_19_0 * 0.5 );
			float dotResult34 = dot( temp_output_31_0 , temp_output_31_0 );
			float3 appendResult37 = (float3(temp_output_19_0 , sqrt( ( 1.0 - dotResult34 ) )));
			float3 WaterNormal38 = (WorldNormalVector( i , appendResult37 ));
			float dotResult80 = dot( normalizeResult78 , WaterNormal38 );
			float4 SpecColor89 = ( pow( max( dotResult80 , 0.0 ) , _SpecShininess ) * _SpecIntensity * _SpecularColor );
			float clampResult74 = clamp( ( ( _FogEnd - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( _FogEnd - _FogStart ) ) , 0.0 , 1.0 );
			float Fog90 = clampResult74;
			float2 paralaxOffset121 = ParallaxOffset( 0 , -_WaterDepth , i.viewDir );
			float4 UnderWaterColor103 = tex2D( _UnderWaterTex, ( ( (ase_worldPos).xz / _UnderWaterTilling ) + ( (WaterNormal38).xz * _UnderWaterTexOffset ) + paralaxOffset121 ) );
			float2 WaterUV_Offset51 = temp_output_19_0;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos57 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 Water62 = tex2D( _ReflectionTex, ( ( ( (WaterUV_Offset51).xy / ( 1.0 + unityObjectToClipPos57.w ) ) * _WaterNormal_Intensity ) + (ase_screenPosNorm).xy ) );
			float4 lerpResult113 = lerp( UnderWaterColor103 , Water62 , temp_output_111_0);
			float4 Water_Fresnel127 = lerpResult113;
			o.Emission = ( ( Water_Fresnel_Value130 * SpecColor89 * Fog90 ) + Water_Fresnel127 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float4 screenPos : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
0;485;1033;514;2191.057;289.1755;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;42;-2924.471,-825.6017;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;12;-2859.834,-675.4727;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2932.784,-591.6431;Inherit;False;Property;_WaterFlowSpeed;WaterFlowSpeed;7;0;Create;True;0;0;False;0;False;0;0.427;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2724.271,-754.636;Inherit;False;Property;_NormalTilling;NormalTilling;5;0;Create;True;0;0;False;0;False;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;10;-2698.24,-830.9527;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-2454.271,-826.0276;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2641.471,-675.8788;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2559.81,-561.9893;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2355.533,-668.8792;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2158.713,-688.5681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2334.958,-580.5281;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-2002.422,-604.0365;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-2024.458,-826.1736;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;7;-1867.029,-855.4358;Inherit;True;Property;_WaterNormalTex;WaterNormalTex;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-1865.227,-632.7031;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;7;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1491.958,-737.9336;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;19;-1362.086,-743.0063;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1379.741,-629.0227;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1178.175,-648.329;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;34;-1036.621,-647.4159;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-918.1221,-647.4159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;36;-775.3551,-647.4159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-630.241,-739.922;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;56;-2764.387,-29.42844;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1129.136,-812.5203;Inherit;False;WaterUV_Offset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;48;-451.6492,-740.4208;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2567.25,-192.6926;Inherit;False;51;WaterUV_Offset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-236.8389,-745.1709;Inherit;False;WaterNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2515.387,-103.4285;Inherit;False;Constant;_Float3;Float 3;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;57;-2565.387,-29.42844;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-2308.387,-97.42844;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;52;-2353.318,-192.5891;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;76;-2947.522,1416.108;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;124;-2932.753,823.147;Inherit;False;Property;_WaterDepth;WaterDepth;3;0;Create;True;0;0;False;0;False;0;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;75;-2891.522,1258.108;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;116;-2709.016,644.6262;Inherit;False;38;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;98;-2725.031,491.701;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;126;-1253.604,484.6355;Inherit;False;1186.201;502.4915;Comment;3;135;114;63;Water_Fresnel;0.4587066,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;60;-2120.387,-100.4284;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;99;-2498.799,486.3501;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2653.819,725.9263;Inherit;False;Property;_UnderWaterTexOffset;UnderWaterTexOffset;2;0;Create;True;0;0;False;0;False;0;0.015;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2524.83,562.6667;Inherit;False;Property;_UnderWaterTilling;UnderWaterTilling;8;0;Create;True;0;0;False;0;False;4;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;125;-2583.05,827.0477;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;135;-1239.288,631.939;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenPosInputsNode;5;-2171.899,106.141;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;105;-1223.203,798.1271;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;21;-2260.065,8.274328;Inherit;False;Property;_WaterNormal_Intensity;WaterNormal_Intensity;6;0;Create;True;0;0;False;0;False;0;6.26;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-2722.522,1345.108;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;117;-2512.016,644.6262;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;123;-2706.549,908.947;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;81;-2655.522,1437.108;Inherit;False;38;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;78;-2585.522,1345.108;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-2337.016,649.6263;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;64;-2878.027,1866.051;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;107;-1026.903,722.7271;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;121;-2398.449,802.3467;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;3;-1980.421,107.141;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1906.901,-9.722969;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;65;-2944.578,2026.178;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;101;-2254.83,491.2752;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2983.631,-242.5891;Inherit;False;2017.226;535.5752;Comment;2;62;1;Water;0,0.620383,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1731.054,-9.813451;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-2612.578,1835.176;Inherit;False;Property;_FogEnd;FogEnd;13;0;Create;True;0;0;False;0;False;1;500;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-2042.017,491.6263;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;80;-2373.522,1345.108;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2612.578,2058.177;Inherit;False;Property;_FogStart;FogStart;12;0;Create;True;0;0;False;0;False;0;0;0;500;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;67;-2656.578,1945.177;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;109;-886.5027,722.7271;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1544.852,-94.33921;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-2294.579,1835.176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;82;-2244.522,1345.108;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;111;-749.6024,722.7269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-2294.579,2043.178;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-2412.522,1443.108;Inherit;False;Property;_SpecShininess;SpecShininess;9;0;Create;True;0;0;False;0;False;0;42.8;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;-1867.254,462.9719;Inherit;True;Property;_UnderWaterTex;UnderWaterTex;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1138.932,-48.0703;Inherit;False;Water;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-1566.254,462.9719;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1979.164,1401.396;Inherit;False;Property;_SpecIntensity;SpecIntensity;10;0;Create;True;0;0;False;0;False;0.01;1.39;0.01;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-2120.579,1926.177;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;83;-2120.522,1345.108;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-551.1272,796.9064;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;147;-543.4167,257.4678;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;86;-1914.441,1476.048;Inherit;False;Property;_SpecularColor;SpecularColor;11;0;Create;True;0;0;False;0;False;0.6603774,0.2974091,0.1650943,0;0.6603774,0.2974091,0.1650943,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;146;-368.5375,257.4894;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-844.6295,549.6356;Inherit;False;103;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;132;-426.1272,796.9064;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-800.3157,630.7375;Inherit;False;62;Water;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;74;-1973.58,1926.177;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1641.52,1344.108;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;113;-474.3027,675.7271;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-1501.164,1339.396;Inherit;False;SpecColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;152;-220.2177,256.3413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-1812.337,1920.574;Inherit;False;Fog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-284.3435,791.8058;Inherit;False;Water_Fresnel_Value;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-295.3566,670.6884;Inherit;False;Water_Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-867.203,-156.7122;Inherit;False;89;SpecColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;159;-101.3142,259.6736;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-927.4289,-241.3785;Inherit;False;130;Water_Fresnel_Value;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-863.4705,-73.13156;Inherit;False;90;Fog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-710.8002,6.506595;Inherit;False;127;Water_Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-653.2366,-152.2546;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;158;114.0503,252.0069;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;140;-848.5719,250.8994;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;143;-683.5719,110.8994;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-565.5719,152.8994;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;141;-861.5719,86.89943;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;138;-417.5719,168.8994;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;46;-2705.765,-190.135;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-451.2042,-74.38101;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;342.6885,186.9718;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;150;-346.8114,24.54718;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2933.631,-190.173;Inherit;False;38;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-108.3116,65.90018;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;627.08,-109.437;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;44;-2982.784,-905.4358;Inherit;False;2970.105;524.5023;Comment;0;WaterNormal;0,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;129;-2982.753,412.9719;Inherit;False;1654.497;683.9751;Comment;0;UnderWater;1,0,0.8926477,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;91;-2994.578,1785.177;Inherit;False;1406.244;424.0001;Comment;0;Fog;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-2997.522,1208.108;Inherit;False;1680.356;445.9403;Comment;0;SpecularColor;1,0.4200187,0,1;0;0
WireConnection;10;0;42;0
WireConnection;16;0;10;0
WireConnection;16;1;17;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;25;0;16;0
WireConnection;25;1;26;0
WireConnection;27;0;14;0
WireConnection;27;1;28;0
WireConnection;24;0;25;0
WireConnection;24;1;27;0
WireConnection;15;0;16;0
WireConnection;15;1;14;0
WireConnection;7;1;15;0
WireConnection;23;1;24;0
WireConnection;29;0;7;0
WireConnection;29;1;23;0
WireConnection;19;0;29;0
WireConnection;31;0;19;0
WireConnection;31;1;32;0
WireConnection;34;0;31;0
WireConnection;34;1;31;0
WireConnection;35;0;34;0
WireConnection;36;0;35;0
WireConnection;37;0;19;0
WireConnection;37;2;36;0
WireConnection;51;0;19;0
WireConnection;48;0;37;0
WireConnection;38;0;48;0
WireConnection;57;0;56;0
WireConnection;58;0;59;0
WireConnection;58;1;57;4
WireConnection;52;0;53;0
WireConnection;60;0;52;0
WireConnection;60;1;58;0
WireConnection;99;0;98;0
WireConnection;125;0;124;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;117;0;116;0
WireConnection;78;0;77;0
WireConnection;119;0;117;0
WireConnection;119;1;118;0
WireConnection;107;0;135;0
WireConnection;107;1;105;0
WireConnection;121;1;125;0
WireConnection;121;2;123;0
WireConnection;3;0;5;0
WireConnection;20;0;60;0
WireConnection;20;1;21;0
WireConnection;101;0;99;0
WireConnection;101;1;100;0
WireConnection;50;0;20;0
WireConnection;50;1;3;0
WireConnection;115;0;101;0
WireConnection;115;1;119;0
WireConnection;115;2;121;0
WireConnection;80;0;78;0
WireConnection;80;1;81;0
WireConnection;67;0;64;0
WireConnection;67;1;65;0
WireConnection;109;0;107;0
WireConnection;1;1;50;0
WireConnection;70;0;68;0
WireConnection;70;1;67;0
WireConnection;82;0;80;0
WireConnection;111;0;109;0
WireConnection;71;0;68;0
WireConnection;71;1;69;0
WireConnection;102;1;115;0
WireConnection;62;0;1;0
WireConnection;103;0;102;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;83;0;82;0
WireConnection;83;1;84;0
WireConnection;131;0;111;0
WireConnection;146;0;147;0
WireConnection;132;0;131;0
WireConnection;74;0;72;0
WireConnection;85;0;83;0
WireConnection;85;1;88;0
WireConnection;85;2;86;0
WireConnection;113;0;114;0
WireConnection;113;1;63;0
WireConnection;113;2;111;0
WireConnection;89;0;85;0
WireConnection;152;0;146;0
WireConnection;90;0;74;0
WireConnection;130;0;132;0
WireConnection;127;0;113;0
WireConnection;159;0;152;0
WireConnection;96;0;133;0
WireConnection;96;1;94;0
WireConnection;96;2;95;0
WireConnection;158;0;159;0
WireConnection;143;0;141;1
WireConnection;144;0;143;0
WireConnection;144;1;140;0
WireConnection;138;0;144;0
WireConnection;46;0;40;0
WireConnection;93;0;96;0
WireConnection;93;1;128;0
WireConnection;156;0;158;0
WireConnection;155;0;150;1
WireConnection;0;2;93;0
WireConnection;0;11;156;0
ASEEND*/
//CHKSM=59BC58F49FC5859626FB79FA7EEC0081D5376891