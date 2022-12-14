// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WaterBack"
{
	Properties
	{
		_HDR("HDR", 2D) = "white" {}
		_WaterNormalTex("WaterNormalTex1", 2D) = "bump" {}
		_WaterNormalTex2("WaterNormalTex2", 2D) = "bump" {}
		_NormalTilling("NormalTilling", Float) = 8
		_WaterFlowSpeed("WaterFlowSpeed", Range( 0 , 1)) = 0
		_WaterNormal_Intensity("WaterNormal_Intensity", Range( 0 , 10)) = 1
		_WaterTransparent("WaterTransparent", Float) = 0
		_WaterColor("WaterColor", Color) = (0,0,0,0)
		_WaterColorIntensity("WaterColorIntensity", Range( 0 , 5)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
		};

		uniform sampler2D _HDR;
		uniform float _WaterNormal_Intensity;
		uniform sampler2D _WaterNormalTex;
		uniform float _NormalTilling;
		uniform float _WaterFlowSpeed;
		uniform sampler2D _WaterNormalTex2;
		uniform float4 _WaterColor;
		uniform float _WaterColorIntensity;
		uniform float _WaterTransparent;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_27_0 = ( (ase_worldPos).xz / _NormalTilling );
			float temp_output_26_0 = ( _Time.y * _WaterFlowSpeed );
			float2 temp_output_44_0 = (( UnpackNormal( tex2D( _WaterNormalTex, ( temp_output_27_0 + temp_output_26_0 ) ) ) + UnpackNormal( tex2D( _WaterNormalTex2, ( ( temp_output_27_0 * 1.5 ) + ( temp_output_26_0 * -0.5 ) ) ) ) )).xy;
			float2 WaterNormal_XY56 = ( _WaterNormal_Intensity * temp_output_44_0 );
			float4 ReflexRes61 = tex2D( _HDR, ( (ase_screenPosNorm).xy + WaterNormal_XY56 ) );
			o.Emission = ( ( ReflexRes61 * _WaterColor ) * _WaterColorIntensity ).rgb;
			o.Alpha = _WaterTransparent;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
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
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
0;395;1113;604;-779.1229;1464.73;1.764389;True;False
Node;AmplifyShaderEditor.CommentaryNode;34;-2239.066,-1280.776;Inherit;False;4197.13;661.8;Comment;34;42;26;58;25;60;59;56;28;54;21;27;29;55;22;20;32;23;33;24;43;40;30;31;35;41;19;38;39;44;45;61;57;73;151;WaterNormal;0,0,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;19;-2184.975,-1032.098;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;23;-1958.743,-1037.448;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2193.288,-798.1395;Inherit;False;Property;_WaterFlowSpeed;WaterFlowSpeed;5;0;Create;True;0;0;False;0;False;0;0.075;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;20;-2120.338,-881.9687;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1984.775,-961.1319;Inherit;False;Property;_NormalTilling;NormalTilling;3;0;Create;True;0;0;False;0;False;8;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;27;-1714.775,-1032.524;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1820.313,-768.4858;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1616.037,-875.3752;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1901.974,-882.3748;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1595.462,-787.0245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1419.217,-895.0641;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1265.339,-1187.866;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-1262.925,-810.5327;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-1125.73,-839.1992;Inherit;True;Property;_WaterNormalTex2;WaterNormalTex2;2;0;Create;True;0;0;False;0;False;-1;None;8978cd25b1dfcd747b327f937eba69ee;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;-1104.279,-1216.645;Inherit;True;Property;_WaterNormalTex;WaterNormalTex1;1;0;Create;False;0;0;False;0;False;-1;None;8978cd25b1dfcd747b327f937eba69ee;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-770.6558,-1009.927;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;44;-608.9655,-929.8228;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-353.6712,-1055.971;Inherit;False;Property;_WaterNormal_Intensity;WaterNormal_Intensity;6;0;Create;True;0;0;False;0;False;1;0.12;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-27.29933,-989.7679;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;60;204.5843,-1212.764;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;189.8442,-1015.663;Inherit;False;WaterNormal_XY;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;59;404.0089,-1206.793;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;628.6575,-1059.535;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;57;835.5349,-1088.988;Inherit;True;Property;_HDR;HDR;0;0;Create;True;0;0;False;0;False;-1;d3a394b014e778546b7ac51a34d963af;d3a394b014e778546b7ac51a34d963af;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;1188.851,-1086.989;Inherit;False;ReflexRes;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;191;1803.64,-939.7085;Inherit;False;Property;_WaterColor;WaterColor;20;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;2051.031,-1082.901;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;186;2679.362,-1548.159;Inherit;False;1565.629;357.7742;Comment;12;173;174;175;176;177;181;184;182;180;183;178;179;VertexOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;193;2014.195,-859.5453;Inherit;False;Property;_WaterColorIntensity;WaterColorIntensity;21;0;Create;True;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;148;-2436.834,-469.3794;Inherit;False;1396.593;574.4787;Comment;9;136;133;132;135;142;143;134;144;146;WaterRefraction;0.01108044,0.7830189,0.7367671,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;118;-1746.159,236.0179;Inherit;False;1518.217;652.1981;Comment;11;114;116;113;109;107;110;108;117;115;119;147;UnderWaterColor;0.06988416,0.7264151,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;170;-1645.286,1069.985;Inherit;False;1411.249;505;Comment;9;154;152;153;157;156;158;155;159;168;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;173;3047.517,-1327.591;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;143;-1617.771,-380.5804;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-1287.241,-259.8131;Inherit;False;WaterRefractionUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;108;-1696.159,647.1901;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-1431.871,-251.8804;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;133;-2386.834,-199.9007;Inherit;True;Property;_RefractionNoiseTex;RefractionNoiseTex;12;0;Create;True;0;0;False;0;False;-1;f6e5be6d65444dd4e91a47db5e80b00d;f6e5be6d65444dd4e91a47db5e80b00d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;110;-1334.563,781.5297;Inherit;False;Property;_WaterDepth;WaterDepth;7;0;Create;True;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-1984.835,-221.9007;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;136;-2039.835,-417.9009;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;161;1192.079,-46.15979;Inherit;False;Property;_FoamMaskIntensity;FoamMaskIntensity;17;0;Create;True;0;0;False;0;False;1;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;115;-1143.126,468.0286;Inherit;False;Property;_UnderWaterColor;UnderWaterColor;8;0;Create;True;0;0;False;0;False;0,0.3679245,0.1007944,0;0.02398541,0.4622642,0.06916874,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;107;-1448.005,653.3443;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;114;-1104.415,284.717;Inherit;False;Global;_GrabScreen0;Grab Screen 0;7;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;142;-1829.941,-419.3794;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2369.834,-10.90071;Inherit;False;Property;_RefractionIntensity;RefractionIntensity;13;0;Create;True;0;0;False;0;False;1;0.2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-1114.286,1360.985;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.4,0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;160;1488.572,-62.61481;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-897.0886,390.2975;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1297.286,1157.985;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;129;975.4602,-80.49224;Inherit;False;Property;_Fresnel_FarInter;Fresnel_FarInter;11;0;Create;True;0;0;False;0;False;1;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;155;-933.2858,1119.985;Inherit;True;Property;_FoamNoiseTex1;FoamNoiseTex1;15;0;Create;True;0;0;False;0;False;-1;None;3c0793d91cce1fb409b245b2eafc96d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;2292.968,-968.9375;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;128;967.4602,-153.4923;Inherit;False;Property;_Fresnel_NearInter;Fresnel_NearInter;10;0;Create;True;0;0;False;0;False;0.1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;117;-682.3823,327.443;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-1349.774,286.4629;Inherit;False;146;WaterRefractionUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;113;-910.6801,586.3593;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-284.9038,-774.2914;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;-375.0199,-1181.048;Inherit;False;FoamUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-1122.286,1155.985;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.2,0.35;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-1583.286,1153.985;Inherit;False;151;FoamUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1151.386,667.5534;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;2283.044,-646.7733;Inherit;False;Property;_WaterTransparent;WaterTransparent;19;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;158;-935.2858,1344.985;Inherit;True;Property;_FoamNoiseTex2;FoamNoiseTex2;16;0;Create;True;0;0;False;0;False;-1;None;f6e5be6d65444dd4e91a47db5e80b00d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;132;-2303.381,-272.6999;Inherit;False;56;WaterNormal_XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;165;2310.069,-385.6008;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;4020.991,-1389.294;Inherit;False;PosOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;1215.215,-398.9619;Inherit;False;119;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;3868.623,-1385.087;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;38;430.8223,-830.7007;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;169;1976.085,-496.4826;Inherit;False;168;FoamColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;187;2093.048,-188.1766;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;131;1390.46,-213.4922;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;127;1234.46,-211.4922;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;3025.362,-1432.159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;1230.447,-310.9156;Inherit;False;61;ReflexRes;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;162;1921.87,-67.48053;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-583.2855,1257.985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;1535.936,31.3431;Inherit;False;Property;_FoamMaskPower;FoamMaskPower;18;0;Create;True;0;0;False;0;False;0.2;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;122;1581.642,-361.669;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;442.2141,-116.2553;Inherit;False;Property;_WaterFresnelPower;WaterFresnelPower;9;0;Create;True;0;0;False;0;False;10;2.2;0;32;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-458.0371,1252.627;Inherit;False;FoamColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;40;117.9161,-773.3782;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;180;2742.362,-1334.159;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;182;2729.362,-1498.159;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;163;1750.227,-63.31961;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;154;-1595.286,1242.985;Inherit;False;Property;_FoamUVOffset;FoamUVOffset;14;0;Create;True;0;0;False;0;False;0.1,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;174;3222.396,-1327.569;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;41;-24.85079,-773.3782;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;176;3489.62,-1325.385;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-486.4693,-754.985;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;177;3704.984,-1333.052;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;274.1621,-826.3473;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;178;2907.362,-1474.159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;179;3173.362,-1416.159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;647.7853,-836.7789;Inherit;False;WaterNormalDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;42;-143.3494,-773.3782;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;175;3370.716,-1328.717;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;2198.502,-88.48421;Inherit;False;184;PosOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;123;751.6422,-207.6691;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-504.435,321.6755;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2584.427,-847.5218;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;WaterBack;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;19;0
WireConnection;27;0;23;0
WireConnection;27;1;22;0
WireConnection;26;0;20;0
WireConnection;26;1;21;0
WireConnection;29;0;26;0
WireConnection;29;1;24;0
WireConnection;28;0;27;0
WireConnection;28;1;25;0
WireConnection;30;0;27;0
WireConnection;30;1;26;0
WireConnection;31;0;28;0
WireConnection;31;1;29;0
WireConnection;33;1;31;0
WireConnection;32;1;30;0
WireConnection;35;0;32;0
WireConnection;35;1;33;0
WireConnection;44;0;35;0
WireConnection;55;0;54;0
WireConnection;55;1;44;0
WireConnection;56;0;55;0
WireConnection;59;0;60;0
WireConnection;58;0;59;0
WireConnection;58;1;56;0
WireConnection;57;1;58;0
WireConnection;61;0;57;0
WireConnection;190;0;61;0
WireConnection;190;1;191;0
WireConnection;143;0;142;0
WireConnection;143;1;136;4
WireConnection;146;0;144;0
WireConnection;144;0;143;0
WireConnection;144;1;134;0
WireConnection;134;0;132;0
WireConnection;134;1;133;1
WireConnection;134;2;135;0
WireConnection;107;1;108;0
WireConnection;114;0;147;0
WireConnection;142;0;136;0
WireConnection;157;0;153;0
WireConnection;160;0;161;0
WireConnection;116;0;114;0
WireConnection;116;1;115;0
WireConnection;153;0;152;0
WireConnection;153;1;154;0
WireConnection;155;1;156;0
WireConnection;192;0;190;0
WireConnection;192;1;193;0
WireConnection;117;0;114;0
WireConnection;117;1;116;0
WireConnection;117;2;113;0
WireConnection;113;0;109;0
WireConnection;43;0;44;0
WireConnection;43;1;45;0
WireConnection;151;0;44;0
WireConnection;156;0;153;0
WireConnection;109;0;107;0
WireConnection;109;1;110;0
WireConnection;158;1;157;0
WireConnection;165;0;169;0
WireConnection;165;1;122;0
WireConnection;165;2;187;0
WireConnection;184;0;181;0
WireConnection;181;0;177;0
WireConnection;38;0;39;0
WireConnection;187;0;162;0
WireConnection;131;0;127;0
WireConnection;127;0;123;0
WireConnection;127;1;128;0
WireConnection;127;2;129;0
WireConnection;183;0;178;0
WireConnection;183;1;180;0
WireConnection;162;0;163;0
WireConnection;159;0;155;1
WireConnection;159;1;158;1
WireConnection;122;0;120;0
WireConnection;122;1;121;0
WireConnection;122;2;131;0
WireConnection;168;0;159;0
WireConnection;40;0;41;0
WireConnection;163;0;160;0
WireConnection;163;1;164;0
WireConnection;174;0;173;0
WireConnection;41;0;42;0
WireConnection;176;0;175;0
WireConnection;177;0;176;0
WireConnection;39;0;44;0
WireConnection;39;2;40;0
WireConnection;178;0;182;1
WireConnection;179;0;183;0
WireConnection;73;0;38;0
WireConnection;42;0;43;0
WireConnection;42;1;43;0
WireConnection;175;0;174;0
WireConnection;123;3;124;0
WireConnection;119;0;117;0
WireConnection;0;2;192;0
WireConnection;0;9;188;0
ASEEND*/
//CHKSM=66054A2934C3631E21660D144B0A80B95C19BF8C