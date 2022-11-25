// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Effects_Unlit/6_RainDrop_Transparent"
{
	Properties
	{
		_StaticWaterSize("StaticWaterSize", Int) = 5
		_MainTex("MainTex", 2D) = "white" {}
		_BlurIntensity("BlurIntensity", Range( 0 , 0.1)) = 0.05
		_WaterVisableIntensity("WaterVisableIntensity", Range( 0 , 5)) = 5
		_TrackVisableIntensity("TrackVisableIntensity", Range( 0 , 1)) = 1

	}
	
	SubShader
	{
		GrabPass { "_GrabPassTex" }
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 UV_GrabPass : TEXCOORD2;
			};

			uniform sampler2D _MainTex;
			uniform sampler2D _GrabPassTex;
			uniform int _StaticWaterSize;
			uniform float _WaterVisableIntensity;
			uniform float _BlurIntensity;
			uniform float _TrackVisableIntensity;
			float Static_U8_g127( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V7_g127( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U47_g127( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V33_g127( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U80_g127( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V78_g127( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U8_g129( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V7_g129( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U47_g129( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V33_g129( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U80_g129( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V78_g129( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_V138( float3 UV )
			{
				float z = UV.z;
				return z;
			}
			
			float Static_V137( float3 UV )
			{
				float z = UV.z;
				return z;
			}
			
			float4 PostProcessing_Blur119( sampler2D MainTex, float2 UV, float Random, float BlurIntensity )
			{
				 fixed4 col = (0, 0, 0, 0);
				for (int i = 0; i < 32; i++) {
				    float2 offset = float2(sin(Random), cos(Random)) * BlurIntensity;
				    offset *= frac(sin(i) * 12.05);
				    col += tex2D(MainTex, UV + offset);
				    Random++;
				}
				col /= 32;
				return col;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				o.UV_GrabPass = UNITY_PROJ_COORD(ComputeScreenPos(o.vertex));
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				sampler2D MainTex119 = _MainTex;
				float2 texCoord107 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_5_0_g127 = ( ( float2( 2,1 ) * texCoord107 ) * _StaticWaterSize );
				float2 UV8_g127 = temp_output_5_0_g127;
				float localStatic_U8_g127 = Static_U8_g127( UV8_g127 );
				float2 UV7_g127 = temp_output_5_0_g127;
				float localStatic_V7_g127 = Static_V7_g127( UV7_g127 );
				float2 appendResult10_g127 = (float2(localStatic_U8_g127 , ( localStatic_V7_g127 + _Time.y )));
				float2 temp_output_30_0_g127 = ( frac( appendResult10_g127 ) + float2( -0.5,-0.5 ) );
				float2 UV47_g127 = temp_output_30_0_g127;
				float localStatic_U47_g127 = Static_U47_g127( UV47_g127 );
				float dotResult4_g128 = dot( floor( appendResult10_g127 ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g128 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g128 ) * 43758.55 ) ));
				float temp_output_12_0_g127 = lerpResult10_g128;
				float2 texCoord20_g127 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_21_0_g127 = ( texCoord20_g127.y * 8.0 );
				float X_Wiggle38_g127 = ( ( pow( sin( temp_output_21_0_g127 ) , 6.0 ) * sin( ( temp_output_21_0_g127 * 3.0 ) ) ) * 0.25 );
				float temp_output_52_0_g127 = ( localStatic_U47_g127 - ( ( ( temp_output_12_0_g127 + -0.5 ) * 0.5 ) + X_Wiggle38_g127 ) );
				float2 UV33_g127 = temp_output_30_0_g127;
				float localStatic_V33_g127 = Static_V33_g127( UV33_g127 );
				float RandomTime14_g127 = temp_output_12_0_g127;
				float temp_output_19_0_g127 = ( ( RandomTime14_g127 * 6.15 ) + _Time.y );
				float Y_Wiggle46_g127 = ( sin( ( sin( ( ( sin( temp_output_19_0_g127 ) * 0.5 ) + temp_output_19_0_g127 ) ) + temp_output_19_0_g127 ) ) * -0.3 );
				float U85_g127 = temp_output_52_0_g127;
				float temp_output_55_0_g127 = ( localStatic_V33_g127 - ( Y_Wiggle46_g127 - pow( U85_g127 , 2.0 ) ) );
				float2 appendResult56_g127 = (float2(temp_output_52_0_g127 , temp_output_55_0_g127));
				float2 temp_output_59_0_g127 = ( appendResult56_g127 / float2( 2,1 ) );
				float smoothstepResult67_g127 = smoothstep( 0.05 , 0.035 , length( temp_output_59_0_g127 ));
				float smoothstepResult63_g127 = smoothstep( 0.75 , -0.3 , localStatic_V33_g127);
				float smoothstepResult64_g127 = smoothstep( 0.0 , 0.1 , temp_output_55_0_g127);
				float2 appendResult54_g127 = (float2(temp_output_52_0_g127 , ( ( frac( ( ( localStatic_V33_g127 - _Time.y ) * 6.0 ) ) + -0.5 ) / 6.0 )));
				float2 temp_output_57_0_g127 = ( appendResult54_g127 / float2( 2,1 ) );
				float smoothstepResult65_g127 = smoothstep( 0.025 , 0.0175 , length( temp_output_57_0_g127 ));
				float temp_output_66_0_g127 = ( smoothstepResult63_g127 * smoothstepResult64_g127 * smoothstepResult65_g127 );
				float2 UV80_g127 = appendResult56_g127;
				float localStatic_U80_g127 = Static_U80_g127( UV80_g127 );
				float smoothstepResult77_g127 = smoothstep( 0.08 , 0.1 , abs( localStatic_U80_g127 ));
				float2 UV78_g127 = appendResult56_g127;
				float localStatic_V78_g127 = Static_V78_g127( UV78_g127 );
				float smoothstepResult76_g127 = smoothstep( -0.02 , 0.0 , localStatic_V78_g127);
				float temp_output_72_0_g127 = ( ( ( 1.0 - smoothstepResult77_g127 ) * smoothstepResult76_g127 ) * smoothstepResult63_g127 );
				float3 appendResult84_g127 = (float3(( ( temp_output_59_0_g127 * smoothstepResult67_g127 ) + ( temp_output_66_0_g127 * temp_output_57_0_g127 ) ) , temp_output_72_0_g127));
				float3 temp_output_287_0 = appendResult84_g127;
				float2 temp_output_5_0_g129 = ( ( float2( 2,1 ) * ( ( texCoord107 * 1.566 ) + 5.66 ) ) * _StaticWaterSize );
				float2 UV8_g129 = temp_output_5_0_g129;
				float localStatic_U8_g129 = Static_U8_g129( UV8_g129 );
				float2 UV7_g129 = temp_output_5_0_g129;
				float localStatic_V7_g129 = Static_V7_g129( UV7_g129 );
				float2 appendResult10_g129 = (float2(localStatic_U8_g129 , ( localStatic_V7_g129 + _Time.y )));
				float2 temp_output_30_0_g129 = ( frac( appendResult10_g129 ) + float2( -0.5,-0.5 ) );
				float2 UV47_g129 = temp_output_30_0_g129;
				float localStatic_U47_g129 = Static_U47_g129( UV47_g129 );
				float dotResult4_g130 = dot( floor( appendResult10_g129 ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g130 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g130 ) * 43758.55 ) ));
				float temp_output_12_0_g129 = lerpResult10_g130;
				float2 texCoord20_g129 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_21_0_g129 = ( texCoord20_g129.y * 8.0 );
				float X_Wiggle38_g129 = ( ( pow( sin( temp_output_21_0_g129 ) , 6.0 ) * sin( ( temp_output_21_0_g129 * 3.0 ) ) ) * 0.25 );
				float temp_output_52_0_g129 = ( localStatic_U47_g129 - ( ( ( temp_output_12_0_g129 + -0.5 ) * 0.5 ) + X_Wiggle38_g129 ) );
				float2 UV33_g129 = temp_output_30_0_g129;
				float localStatic_V33_g129 = Static_V33_g129( UV33_g129 );
				float RandomTime14_g129 = temp_output_12_0_g129;
				float temp_output_19_0_g129 = ( ( RandomTime14_g129 * 6.15 ) + _Time.y );
				float Y_Wiggle46_g129 = ( sin( ( sin( ( ( sin( temp_output_19_0_g129 ) * 0.5 ) + temp_output_19_0_g129 ) ) + temp_output_19_0_g129 ) ) * -0.3 );
				float U85_g129 = temp_output_52_0_g129;
				float temp_output_55_0_g129 = ( localStatic_V33_g129 - ( Y_Wiggle46_g129 - pow( U85_g129 , 2.0 ) ) );
				float2 appendResult56_g129 = (float2(temp_output_52_0_g129 , temp_output_55_0_g129));
				float2 temp_output_59_0_g129 = ( appendResult56_g129 / float2( 2,1 ) );
				float smoothstepResult67_g129 = smoothstep( 0.05 , 0.035 , length( temp_output_59_0_g129 ));
				float smoothstepResult63_g129 = smoothstep( 0.75 , -0.3 , localStatic_V33_g129);
				float smoothstepResult64_g129 = smoothstep( 0.0 , 0.1 , temp_output_55_0_g129);
				float2 appendResult54_g129 = (float2(temp_output_52_0_g129 , ( ( frac( ( ( localStatic_V33_g129 - _Time.y ) * 6.0 ) ) + -0.5 ) / 6.0 )));
				float2 temp_output_57_0_g129 = ( appendResult54_g129 / float2( 2,1 ) );
				float smoothstepResult65_g129 = smoothstep( 0.025 , 0.0175 , length( temp_output_57_0_g129 ));
				float temp_output_66_0_g129 = ( smoothstepResult63_g129 * smoothstepResult64_g129 * smoothstepResult65_g129 );
				float2 UV80_g129 = appendResult56_g129;
				float localStatic_U80_g129 = Static_U80_g129( UV80_g129 );
				float smoothstepResult77_g129 = smoothstep( 0.08 , 0.1 , abs( localStatic_U80_g129 ));
				float2 UV78_g129 = appendResult56_g129;
				float localStatic_V78_g129 = Static_V78_g129( UV78_g129 );
				float smoothstepResult76_g129 = smoothstep( -0.02 , 0.0 , localStatic_V78_g129);
				float temp_output_72_0_g129 = ( ( ( 1.0 - smoothstepResult77_g129 ) * smoothstepResult76_g129 ) * smoothstepResult63_g129 );
				float3 appendResult84_g129 = (float3(( ( temp_output_59_0_g129 * smoothstepResult67_g129 ) + ( temp_output_66_0_g129 * temp_output_57_0_g129 ) ) , temp_output_72_0_g129));
				float3 temp_output_288_0 = appendResult84_g129;
				float2 UV119 = ( float3( i.UV_GrabPass.xy / i.UV_GrabPass.w ,  0.0 ) + ( ( temp_output_287_0 + temp_output_288_0 ) * _WaterVisableIntensity ) ).xy;
				float2 texCoord125 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g131 = dot( texCoord125 , float2( 12.9898,78.233 ) );
				float lerpResult10_g131 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g131 ) * 43758.55 ) ));
				float Random119 = ( lerpResult10_g131 * 6.15 );
				float3 UV138 = temp_output_287_0;
				float localStatic_V138 = Static_V138( UV138 );
				float3 UV137 = temp_output_288_0;
				float localStatic_V137 = Static_V137( UV137 );
				float BlurIntensity119 = ( _BlurIntensity * ( 1.0 - ( ( localStatic_V138 + localStatic_V137 ) * _TrackVisableIntensity ) ) );
				float4 localPostProcessing_Blur119 = PostProcessing_Blur119( _GrabPassTex , UV119 , Random119 , BlurIntensity119 );
				
				
				finalColor = localPostProcessing_Blur119;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
0;600;1031;399;7002.552;1257.692;8.550068;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-2581.679,1976.126;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;111;-2480.319,2210.221;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;1.566;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-2258.399,2184.418;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2293.438,2307.218;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;5.66;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-2079.057,2234.738;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;287;-1946.819,2143.637;Inherit;False;RainDropUV;1;;127;60d3515a1dae5ce488115846233df0a6;0;1;82;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;288;-1944.519,2246.932;Inherit;False;RainDropUV;1;;129;60d3515a1dae5ce488115846233df0a6;0;1;82;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;138;-1551.056,2498.966;Inherit;False;float z = UV.z@$return z@;1;False;1;True;UV;FLOAT3;0,0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;137;-1551.829,2610.167;Inherit;False;float z = UV.z@$return z@;1;False;1;True;UV;FLOAT3;0,0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;-1373.332,2570.438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1565.45,2735.594;Inherit;False;Property;_TrackVisableIntensity;TrackVisableIntensity;6;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-1178.171,1978.919;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-1347.76,2180.591;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-1210.66,2647.812;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1492.451,2363.46;Inherit;False;Property;_WaterVisableIntensity;WaterVisableIntensity;5;0;Create;True;0;0;False;0;False;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1195.214,2314.885;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;122;-941.9202,1976.586;Inherit;False;Random Range;-1;;131;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;140;-1031.515,2573.135;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-936.0941,2248.531;Inherit;False;Property;_BlurIntensity;BlurIntensity;4;0;Create;True;0;0;False;0;False;0.05;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-704.7847,1990.786;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-560.9231,2248.177;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;118;-956.4832,1767.368;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;False;0;False;c62467d7c817b564888fd3fb1c9ffd2d;c62467d7c817b564888fd3fb1c9ffd2d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;130;-923.0311,2133.635;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;291;-3439.234,-642.1769;Inherit;False;1829.159;301.0598;水滴竖直方向速度随机;12;367;355;332;331;329;327;324;322;312;306;298;295;Y_Wiggle;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;290;-3063.358,-228.0132;Inherit;False;1608.964;308.9998;水滴水平方向速度随机;9;364;363;328;325;323;317;315;314;305;X_Wiggle;0,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;99;919.6351,-498.0779;Inherit;False;734.8923;473.434;多雨滴边界;4;16;14;18;79;Water_Boundary;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;289;-607.1738,398.4585;Inherit;False;473.662;304;画圆;2;348;346;画圆;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;327;-2605.565,-576.1769;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;304;-464.4338,129.6949;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;16;969.6351,-354.2339;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;False;1,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;14;1224.917,-448.0779;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.48;False;2;FLOAT4;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;1502.528,-346.0099;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ConditionalIfNode;18;1228.857,-231.644;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.48;False;2;FLOAT4;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;119;-220.8945,1945.681;Inherit;False; fixed4 col = (0, 0, 0, 0)@$for (int i = 0@ i < 32@ i++) {$    float2 offset = float2(sin(Random), cos(Random)) * BlurIntensity@$    offset *= frac(sin(i) * 12.05)@$    col += tex2D(MainTex, UV + offset)@$    Random++@$}$col /= 32@$return col@;4;False;4;True;MainTex;SAMPLER2D;;In;;Inherit;False;True;UV;FLOAT2;0,0;In;;Inherit;False;True;Random;FLOAT;0;In;;Inherit;False;True;BlurIntensity;FLOAT;0;In;;Inherit;False;PostProcessing_Blur;True;False;0;4;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;292;-1397.88,870.9816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;293;-861.3786,1059.883;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;296;-3342.677,637.6904;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-1834.07,-544.691;Inherit;False;Y_Wiggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;297;-3209.582,511.7374;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;298;-2929.568,-593.1769;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;299;-1438.881,1065.633;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;300;-3092.58,416.2218;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;301;-342.8312,715.9437;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.75;False;2;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;302;-1525.984,406.3645;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;303;-1269.377,1071.901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;294;-3780.267,301.7074;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;305;-2291.174,-178.0132;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;314;-2066.175,-129.0133;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;325;-1854.174,-54.01344;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;316;-2436.26,244.6913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;308;-1525.552,515.9689;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;309;-3050.678,546.6904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;305.0584,51.61773;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;311;-784.1035,1.267262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;312;-2477.563,-544.1769;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-1638.448,730.5374;Inherit;False;295;Y_Wiggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-2451.85,161.1074;Inherit;False;RandomTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;307;-3959.546,577.1782;Inherit;False;Property;_StaticWaterSize1;StaticWaterSize;0;0;Create;True;0;0;False;0;False;5;0;0;1;INT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;370;-1266.199,770.6965;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;306;-3419.045,-581.566;Inherit;False;326;RandomTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;318;-1758.818,1114.313;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;319;774.0605,268.3626;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;320;1019.953,345.9039;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;321;-1140.627,1069.407;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-3186.95,-580.4;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;323;-2444.173,-146.0132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;324;-2156.344,-521.412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;317;-2732.17,-62.01344;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;-2452.172,-62.01344;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;329;-3403.821,-470.8769;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;360;-971.7416,370.2633;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;334;-1146.549,498.7433;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;335;-1770.817,471.7501;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;333;-632.0036,1.267262;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.08;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;-2797.567,-592.1769;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;331;-3045.811,-513.3979;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;-3466.949,393.2625;Inherit;True;2;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;336;-3958.097,262.9285;Inherit;False;Constant;_Vector3;Vector 2;1;0;Create;True;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LengthOpNode;337;-364.3883,1028.002;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;339;-1382.386,223.3214;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;338;-2632.942,245.254;Inherit;False;Random Range;-1;;132;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-2163.924,337.9844;Inherit;False;363;X_Wiggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;342;-1044.045,654.9517;Inherit;False;Constant;_Vector4;Vector 3;1;0;Create;True;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;343;-175.1883,1025.576;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.025;False;2;FLOAT;0.0175;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;344;-721.8493,1147.108;Inherit;False;Constant;_Vector2;Vector 1;1;0;Create;True;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;345;-728.7382,1031.752;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;346;-564.2548,486.7994;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;-2305.872,244.6659;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;348;-387.5121,449.4585;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0.035;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;340;-526.6999,1030.908;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;328;-2274.174,-51.01344;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;349;-858.7006,502.3217;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;351;-969.3815,54.93743;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;352;-2931.751,446.6659;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;189.5884,375.6624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;325.3375,776.5987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;-2012.114,-529.9989;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;356;-274.5477,66.58043;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;357;-1009.15,1065.208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;358;-1933.014,244.8847;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;359;-2768.084,247.4766;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;362;-1604.88,855.9816;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;421.8654,262.6332;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;371;-2001.931,447.5292;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-1678.395,-60.68555;Inherit;False;X_Wiggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;364;-3013.358,-108.3137;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;365;-452.6037,1.267628;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;366;-680.393,816.8487;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;367;-2310.506,-520.687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;-1212.62,168.1581;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;-1775.88,851.9816;Inherit;False;368;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;50.23428,743.4869;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;270;82.0435,1946.451;Float;False;True;-1;2;ASEMaterialInspector;100;1;Effects_Unlit/6_RainDrop_Transparent;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;112;0;107;0
WireConnection;112;1;111;0
WireConnection;113;0;112;0
WireConnection;113;1;115;0
WireConnection;287;82;107;0
WireConnection;288;82;113;0
WireConnection;138;0;287;0
WireConnection;137;0;288;0
WireConnection;139;0;138;0
WireConnection;139;1;137;0
WireConnection;109;0;287;0
WireConnection;109;1;288;0
WireConnection;142;0;139;0
WireConnection;142;1;143;0
WireConnection;128;0;109;0
WireConnection;128;1;129;0
WireConnection;122;1;125;0
WireConnection;140;0;142;0
WireConnection;126;0;122;0
WireConnection;141;0;121;0
WireConnection;141;1;140;0
WireConnection;130;0;107;0
WireConnection;130;1;128;0
WireConnection;327;0;332;0
WireConnection;327;1;331;0
WireConnection;304;0;360;0
WireConnection;14;2;16;0
WireConnection;79;0;14;0
WireConnection;79;1;18;0
WireConnection;18;2;16;0
WireConnection;119;0;118;0
WireConnection;119;1;130;0
WireConnection;119;2;126;0
WireConnection;119;3;141;0
WireConnection;292;0;313;0
WireConnection;292;1;362;0
WireConnection;293;0;357;0
WireConnection;295;0;355;0
WireConnection;297;0;330;0
WireConnection;298;0;331;0
WireConnection;299;0;308;0
WireConnection;299;1;318;0
WireConnection;300;0;330;0
WireConnection;301;0;308;0
WireConnection;302;0;335;0
WireConnection;303;0;299;0
WireConnection;294;0;336;0
WireConnection;305;0;323;0
WireConnection;314;0;305;0
WireConnection;314;1;328;0
WireConnection;325;0;314;0
WireConnection;316;0;338;0
WireConnection;308;0;335;0
WireConnection;309;0;297;0
WireConnection;309;1;296;0
WireConnection;310;0;349;0
WireConnection;310;1;348;0
WireConnection;311;0;351;0
WireConnection;312;0;327;0
WireConnection;326;0;338;0
WireConnection;370;0;308;0
WireConnection;370;1;292;0
WireConnection;319;0;310;0
WireConnection;319;1;354;0
WireConnection;320;0;319;0
WireConnection;320;2;353;0
WireConnection;321;0;303;0
WireConnection;322;0;306;0
WireConnection;323;0;317;0
WireConnection;324;0;367;0
WireConnection;317;0;364;2
WireConnection;315;0;317;0
WireConnection;360;0;334;0
WireConnection;334;0;339;0
WireConnection;334;1;370;0
WireConnection;335;0;371;0
WireConnection;333;0;311;0
WireConnection;332;0;298;0
WireConnection;331;0;322;0
WireConnection;331;1;329;0
WireConnection;330;0;294;0
WireConnection;330;1;307;0
WireConnection;337;0;340;0
WireConnection;339;0;302;0
WireConnection;339;1;358;0
WireConnection;338;1;359;0
WireConnection;343;0;337;0
WireConnection;345;0;339;0
WireConnection;345;1;293;0
WireConnection;346;0;349;0
WireConnection;347;0;316;0
WireConnection;348;0;346;0
WireConnection;340;0;345;0
WireConnection;340;1;344;0
WireConnection;328;0;315;0
WireConnection;349;0;334;0
WireConnection;349;1;342;0
WireConnection;351;0;334;0
WireConnection;352;0;300;0
WireConnection;352;1;309;0
WireConnection;353;0;356;0
WireConnection;353;1;301;0
WireConnection;354;0;350;0
WireConnection;354;1;340;0
WireConnection;355;0;324;0
WireConnection;356;0;365;0
WireConnection;356;1;304;0
WireConnection;357;0;321;0
WireConnection;358;0;347;0
WireConnection;358;1;341;0
WireConnection;359;0;352;0
WireConnection;362;0;369;0
WireConnection;361;0;348;0
WireConnection;361;1;353;0
WireConnection;361;2;350;0
WireConnection;371;0;352;0
WireConnection;363;0;325;0
WireConnection;365;0;333;0
WireConnection;366;0;370;0
WireConnection;367;0;312;0
WireConnection;367;1;331;0
WireConnection;368;0;339;0
WireConnection;350;0;301;0
WireConnection;350;1;366;0
WireConnection;350;2;343;0
WireConnection;270;0;119;0
ASEEND*/
//CHKSM=671C0C8928BE429DCCC2679FA85EB86EF7C1CB1E