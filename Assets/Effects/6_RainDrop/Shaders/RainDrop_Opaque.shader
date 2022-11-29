// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Effects_Unlit/6_RainDrop_Opaque"
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
		
		
		Tags { "RenderType"="Opaque" }
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
			};

			uniform sampler2D _MainTex;
			uniform int _StaticWaterSize;
			uniform float _WaterVisableIntensity;
			uniform float _BlurIntensity;
			uniform float _TrackVisableIntensity;
			float Static_U8_g113( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V7_g113( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U47_g113( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V33_g113( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U80_g113( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V78_g113( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U8_g115( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V7_g115( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U47_g115( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V33_g115( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U80_g115( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V78_g115( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_Z138( float3 UV )
			{
				float z = UV.z;
				return z;
			}
			
			float Static_Z137( float3 UV )
			{
				float z = UV.z;
				return z;
			}
			
			float3 PostProcessing_Blur119( sampler2D MainTex, float2 UV, float Random, float BlurIntensity )
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
				float2 temp_output_5_0_g113 = ( ( float2( 2,1 ) * texCoord107 ) * _StaticWaterSize );
				float2 UV8_g113 = temp_output_5_0_g113;
				float localStatic_U8_g113 = Static_U8_g113( UV8_g113 );
				float2 UV7_g113 = temp_output_5_0_g113;
				float localStatic_V7_g113 = Static_V7_g113( UV7_g113 );
				float2 appendResult10_g113 = (float2(localStatic_U8_g113 , ( localStatic_V7_g113 + _Time.y )));
				float2 temp_output_30_0_g113 = ( frac( appendResult10_g113 ) + float2( -0.5,-0.5 ) );
				float2 UV47_g113 = temp_output_30_0_g113;
				float localStatic_U47_g113 = Static_U47_g113( UV47_g113 );
				float dotResult4_g114 = dot( floor( appendResult10_g113 ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g114 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g114 ) * 43758.55 ) ));
				float temp_output_12_0_g113 = lerpResult10_g114;
				float2 texCoord20_g113 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_21_0_g113 = ( texCoord20_g113.y * 8.0 );
				float X_Wiggle38_g113 = ( ( pow( sin( temp_output_21_0_g113 ) , 6.0 ) * sin( ( temp_output_21_0_g113 * 3.0 ) ) ) * 0.25 );
				float temp_output_52_0_g113 = ( localStatic_U47_g113 - ( ( ( temp_output_12_0_g113 + -0.5 ) * 0.5 ) + X_Wiggle38_g113 ) );
				float2 UV33_g113 = temp_output_30_0_g113;
				float localStatic_V33_g113 = Static_V33_g113( UV33_g113 );
				float RandomTime14_g113 = temp_output_12_0_g113;
				float temp_output_19_0_g113 = ( ( RandomTime14_g113 * 6.15 ) + _Time.y );
				float Y_Wiggle46_g113 = ( sin( ( sin( ( ( sin( temp_output_19_0_g113 ) * 0.5 ) + temp_output_19_0_g113 ) ) + temp_output_19_0_g113 ) ) * -0.3 );
				float U85_g113 = temp_output_52_0_g113;
				float temp_output_55_0_g113 = ( localStatic_V33_g113 - ( Y_Wiggle46_g113 - pow( U85_g113 , 2.0 ) ) );
				float2 appendResult56_g113 = (float2(temp_output_52_0_g113 , temp_output_55_0_g113));
				float2 temp_output_59_0_g113 = ( appendResult56_g113 / float2( 2,1 ) );
				float smoothstepResult67_g113 = smoothstep( 0.05 , 0.035 , length( temp_output_59_0_g113 ));
				float smoothstepResult63_g113 = smoothstep( 0.75 , -0.3 , localStatic_V33_g113);
				float smoothstepResult64_g113 = smoothstep( 0.0 , 0.1 , temp_output_55_0_g113);
				float2 appendResult54_g113 = (float2(temp_output_52_0_g113 , ( ( frac( ( ( localStatic_V33_g113 - _Time.y ) * 6.0 ) ) + -0.5 ) / 6.0 )));
				float2 temp_output_57_0_g113 = ( appendResult54_g113 / float2( 2,1 ) );
				float smoothstepResult65_g113 = smoothstep( 0.025 , 0.0175 , length( temp_output_57_0_g113 ));
				float temp_output_66_0_g113 = ( smoothstepResult63_g113 * smoothstepResult64_g113 * smoothstepResult65_g113 );
				float2 UV80_g113 = appendResult56_g113;
				float localStatic_U80_g113 = Static_U80_g113( UV80_g113 );
				float smoothstepResult77_g113 = smoothstep( 0.08 , 0.1 , abs( localStatic_U80_g113 ));
				float2 UV78_g113 = appendResult56_g113;
				float localStatic_V78_g113 = Static_V78_g113( UV78_g113 );
				float smoothstepResult76_g113 = smoothstep( -0.02 , 0.0 , localStatic_V78_g113);
				float temp_output_72_0_g113 = ( ( ( 1.0 - smoothstepResult77_g113 ) * smoothstepResult76_g113 ) * smoothstepResult63_g113 );
				float3 appendResult84_g113 = (float3(( ( temp_output_59_0_g113 * smoothstepResult67_g113 ) + ( temp_output_66_0_g113 * temp_output_57_0_g113 ) ) , temp_output_72_0_g113));
				float3 temp_output_428_0 = appendResult84_g113;
				float2 temp_output_5_0_g115 = ( ( float2( 2,1 ) * ( ( texCoord107 * 1.566 ) + 5.66 ) ) * _StaticWaterSize );
				float2 UV8_g115 = temp_output_5_0_g115;
				float localStatic_U8_g115 = Static_U8_g115( UV8_g115 );
				float2 UV7_g115 = temp_output_5_0_g115;
				float localStatic_V7_g115 = Static_V7_g115( UV7_g115 );
				float2 appendResult10_g115 = (float2(localStatic_U8_g115 , ( localStatic_V7_g115 + _Time.y )));
				float2 temp_output_30_0_g115 = ( frac( appendResult10_g115 ) + float2( -0.5,-0.5 ) );
				float2 UV47_g115 = temp_output_30_0_g115;
				float localStatic_U47_g115 = Static_U47_g115( UV47_g115 );
				float dotResult4_g116 = dot( floor( appendResult10_g115 ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g116 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g116 ) * 43758.55 ) ));
				float temp_output_12_0_g115 = lerpResult10_g116;
				float2 texCoord20_g115 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_21_0_g115 = ( texCoord20_g115.y * 8.0 );
				float X_Wiggle38_g115 = ( ( pow( sin( temp_output_21_0_g115 ) , 6.0 ) * sin( ( temp_output_21_0_g115 * 3.0 ) ) ) * 0.25 );
				float temp_output_52_0_g115 = ( localStatic_U47_g115 - ( ( ( temp_output_12_0_g115 + -0.5 ) * 0.5 ) + X_Wiggle38_g115 ) );
				float2 UV33_g115 = temp_output_30_0_g115;
				float localStatic_V33_g115 = Static_V33_g115( UV33_g115 );
				float RandomTime14_g115 = temp_output_12_0_g115;
				float temp_output_19_0_g115 = ( ( RandomTime14_g115 * 6.15 ) + _Time.y );
				float Y_Wiggle46_g115 = ( sin( ( sin( ( ( sin( temp_output_19_0_g115 ) * 0.5 ) + temp_output_19_0_g115 ) ) + temp_output_19_0_g115 ) ) * -0.3 );
				float U85_g115 = temp_output_52_0_g115;
				float temp_output_55_0_g115 = ( localStatic_V33_g115 - ( Y_Wiggle46_g115 - pow( U85_g115 , 2.0 ) ) );
				float2 appendResult56_g115 = (float2(temp_output_52_0_g115 , temp_output_55_0_g115));
				float2 temp_output_59_0_g115 = ( appendResult56_g115 / float2( 2,1 ) );
				float smoothstepResult67_g115 = smoothstep( 0.05 , 0.035 , length( temp_output_59_0_g115 ));
				float smoothstepResult63_g115 = smoothstep( 0.75 , -0.3 , localStatic_V33_g115);
				float smoothstepResult64_g115 = smoothstep( 0.0 , 0.1 , temp_output_55_0_g115);
				float2 appendResult54_g115 = (float2(temp_output_52_0_g115 , ( ( frac( ( ( localStatic_V33_g115 - _Time.y ) * 6.0 ) ) + -0.5 ) / 6.0 )));
				float2 temp_output_57_0_g115 = ( appendResult54_g115 / float2( 2,1 ) );
				float smoothstepResult65_g115 = smoothstep( 0.025 , 0.0175 , length( temp_output_57_0_g115 ));
				float temp_output_66_0_g115 = ( smoothstepResult63_g115 * smoothstepResult64_g115 * smoothstepResult65_g115 );
				float2 UV80_g115 = appendResult56_g115;
				float localStatic_U80_g115 = Static_U80_g115( UV80_g115 );
				float smoothstepResult77_g115 = smoothstep( 0.08 , 0.1 , abs( localStatic_U80_g115 ));
				float2 UV78_g115 = appendResult56_g115;
				float localStatic_V78_g115 = Static_V78_g115( UV78_g115 );
				float smoothstepResult76_g115 = smoothstep( -0.02 , 0.0 , localStatic_V78_g115);
				float temp_output_72_0_g115 = ( ( ( 1.0 - smoothstepResult77_g115 ) * smoothstepResult76_g115 ) * smoothstepResult63_g115 );
				float3 appendResult84_g115 = (float3(( ( temp_output_59_0_g115 * smoothstepResult67_g115 ) + ( temp_output_66_0_g115 * temp_output_57_0_g115 ) ) , temp_output_72_0_g115));
				float3 temp_output_429_0 = appendResult84_g115;
				float2 UV119 = ( float3( texCoord107 ,  0.0 ) + ( ( temp_output_428_0 + temp_output_429_0 ) * _WaterVisableIntensity ) ).xy;
				float2 texCoord125 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g93 = dot( texCoord125 , float2( 12.9898,78.233 ) );
				float lerpResult10_g93 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g93 ) * 43758.55 ) ));
				float Random119 = ( lerpResult10_g93 * 6.15 );
				float3 UV138 = temp_output_428_0;
				float localStatic_Z138 = Static_Z138( UV138 );
				float3 UV137 = temp_output_429_0;
				float localStatic_Z137 = Static_Z137( UV137 );
				float BlurIntensity119 = ( _BlurIntensity * ( 1.0 - ( ( localStatic_Z138 + localStatic_Z137 ) * _TrackVisableIntensity ) ) );
				float3 localPostProcessing_Blur119 = PostProcessing_Blur119( MainTex119 , UV119 , Random119 , BlurIntensity119 );
				
				
				finalColor = float4( localPostProcessing_Blur119 , 0.0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
0;317;1209;682;2779.954;-651.683;2.380884;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-2923.579,1257.37;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;111;-2822.219,1491.466;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;1.566;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2635.338,1588.462;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;5.66;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-2600.299,1465.663;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-2420.957,1515.982;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;428;-2170.32,1396.082;Inherit;False;RainDropUV;1;;113;60d3515a1dae5ce488115846233df0a6;0;1;82;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;429;-2164.821,1515.376;Inherit;False;RainDropUV;1;;115;60d3515a1dae5ce488115846233df0a6;0;1;82;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;138;-1708.935,1711.876;Inherit;False;float z = UV.z@$return z@;1;False;1;True;UV;FLOAT3;0,0,0;In;;Inherit;False;Static_Z;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;137;-1709.708,1823.078;Inherit;False;float z = UV.z@$return z@;1;False;1;True;UV;FLOAT3;0,0,0;In;;Inherit;False;Static_Z;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;-1531.211,1783.348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1723.329,1948.505;Inherit;False;Property;_TrackVisableIntensity;TrackVisableIntensity;9;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1650.33,1576.371;Inherit;False;Property;_WaterVisableIntensity;WaterVisableIntensity;7;0;Create;True;0;0;False;0;False;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-1505.639,1393.501;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-1368.539,1860.722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-1207.981,1160.717;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1353.093,1527.796;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1093.974,1461.441;Inherit;False;Property;_BlurIntensity;BlurIntensity;5;0;Create;True;0;0;False;0;False;0.05;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;140;-1189.395,1786.045;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;122;-971.7317,1158.384;Inherit;False;Random Range;-1;;93;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;296;-2949.791,-1256.516;Inherit;False;1829.159;301.0598;水滴竖直方向速度随机;12;372;360;337;336;334;332;329;327;317;311;303;300;Y_Wiggle;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;294;-117.7304,-215.8801;Inherit;False;473.662;304;画圆;2;353;351;画圆;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-718.8028,1461.087;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;295;-2573.915,-842.3519;Inherit;False;1608.964;308.9998;水滴水平方向速度随机;9;369;368;333;330;328;322;320;319;310;X_Wiggle;0,1,0,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;118;-715.3892,965.7111;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;False;0;False;c62467d7c817b564888fd3fb1c9ffd2d;c62467d7c817b564888fd3fb1c9ffd2d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;130;-1080.911,1346.545;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-734.5963,1172.585;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;1569.44,-1395.835;Inherit;False;734.8923;473.434;多雨滴边界;4;16;14;18;79;Water_Boundary;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;310;-1801.73,-792.3519;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-3290.824,-312.6312;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;301;-2853.234,23.35181;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;344;-892.9429,-391.0172;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;356;-479.9378,-559.401;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;-2977.506,-221.076;Inherit;True;2;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;333;-1784.73,-665.3519;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;313;-1036.108,-98.36974;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;383;1734.576,-428.1336;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;362;-519.7059,450.8696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;354;-369.2571,-112.017;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;320;-1962.728,-676.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;312;-3470.104,-37.16034;Inherit;False;Property;_StaticWaterSize;StaticWaterSize;0;0;Create;True;0;0;False;0;False;5;0;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;343;-2143.499,-369.0846;Inherit;False;Random Range;-1;;101;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;302;-2720.139,-102.6012;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;367;-1115.436,241.643;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;357;-2442.308,-167.6727;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;298;-371.9349,445.5445;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-2242.727,-676.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;376;-1512.488,-166.8094;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;328;-1954.729,-760.3519;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;363;-1443.571,-369.4539;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;366;911.3087,-351.7053;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;351;-74.81126,-127.5392;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-2697.507,-1194.739;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-2929.602,-1195.905;Inherit;False;331;RandomTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;2152.333,-1243.767;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;314;-2561.235,-67.64812;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;349;-232.4057,532.7695;Inherit;False;Constant;_Vector1;Vector 1;1;0;Create;True;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;345;-37.25632,416.5696;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;342;125.0552,413.6629;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;317;-1988.12,-1158.516;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;334;-2914.378,-1085.215;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;372;-1821.062,-1135.026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;373;-723.1763,-446.1805;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;336;-2556.367,-1127.736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;307;-1036.541,-207.9741;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-2308.124,-1206.516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;350;-239.2946,417.4131;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;365;-482.2979,-244.0753;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;360;-1522.67,-1144.338;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;305;-2603.137,-198.1168;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-1286.436,237.643;Inherit;False;373;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;340;-1281.374,-142.5885;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;297;-908.436,256.643;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;348;314.2552,411.2378;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.025;False;2;FLOAT;0.0175;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;323;-1269.375,499.975;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;316;-294.6599,-613.0712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;347;-554.6012,40.61316;Inherit;False;Constant;_Vector3;Vector 3;1;0;Create;True;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;332;-2116.122,-1190.516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;319;-1576.731,-743.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;403;3302.684,-348.6162;Inherit;False;Random Range;-1;;102;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-1149.005,116.1989;Inherit;False;300;Y_Wiggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;401;3990.926,-378.3822;Inherit;False; fixed4 col = (0, 0, 0, 0)@$for (int i = 0@ i < 32@ i++) {$    float2 offset = float2(sin(Random), cos(Random)) * BlurIntensity@$    offset *= frac(sin(i) * 12.05)@$    col += tex2D(MainTex, UV + offset)@$    Random++@$}$col /= 32@$return col@;3;False;4;True;MainTex;SAMPLER2D;;In;;Inherit;False;True;UV;FLOAT2;0,0;In;;Inherit;False;True;Random;FLOAT;0;In;;Inherit;False;True;BlurIntensity;FLOAT;0;In;;Inherit;False;PostProcessing_Blur;True;False;0;4;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-1344.627,-1159.03;Inherit;False;Y_Wiggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;386;1998.917,-49.33718;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;391;2564.708,316.0779;Inherit;False;float z = UV.z@$return z@;1;False;1;True;UV;FLOAT3;0,0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;3555.613,-45.91311;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;2551.087,441.5048;Inherit;False;Property;_TrackVisableIntensity1;TrackVisableIntensity;10;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;324;1263.504,-345.976;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;16;1619.44,-1251.991;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;False;1,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;407;3973.959,-589.3777;Inherit;False;331;RandomTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;794.5018,-562.7207;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;321;-1946.816,-369.6473;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;539.6778,129.1484;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;359;814.7808,162.2602;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;303;-2440.125,-1207.516;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;1776.997,-23.53418;Inherit;False;Constant;_Float1;Float 0;3;0;Create;True;0;0;False;0;False;1.566;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;325;1509.397,-268.4347;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;353;101.9314,-164.8801;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0.035;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;361;214.8958,-547.7581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;14;1874.722,-1345.835;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.48;False;2;FLOAT4;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;341;-3468.654,-351.41;Inherit;False;Constant;_Vector2;Vector 2;1;0;Create;True;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;385;1963.878,73.46191;Inherit;False;Constant;_Float3;Float 2;4;0;Create;True;0;0;False;0;False;5.66;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;398;3085.021,279.0449;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;387;2178.259,0.9819379;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FloorOpNode;364;-2278.641,-366.862;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;375;-776.7549,156.358;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;679.0317,-238.6761;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;400;3193.505,-160.4551;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;304;-949.4375,451.2947;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;3539.82,-334.4153;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;-1674.48,-276.3541;Inherit;False;368;X_Wiggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;390;2565.48,204.8759;Inherit;False;float z = UV.z@$return z@;1;False;1;True;UV;FLOAT3;0,0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;119;-283.4896,1128.618;Inherit;False; fixed4 col = (0, 0, 0, 0)@$for (int i = 0@ i < 32@ i++) {$    float2 offset = float2(sin(Random), cos(Random)) * BlurIntensity@$    offset *= frac(sin(i) * 12.05)@$    col += tex2D(MainTex, UV + offset)@$    Random++@$}$col /= 32@$return col@;3;False;4;True;MainTex;SAMPLER2D;;In;;Inherit;False;True;UV;FLOAT2;0,0;In;;Inherit;False;True;Random;FLOAT;0;In;;Inherit;False;True;BlurIntensity;FLOAT;0;In;;Inherit;False;PostProcessing_Blur;True;False;0;4;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;329;-1666.901,-1135.751;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;397;3066.435,-346.2832;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-779.9331,457.5626;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;-1188.952,-675.024;Inherit;False;X_Wiggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-1816.429,-369.6727;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;326;-651.1837,455.0679;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;-1962.407,-453.2311;Inherit;False;RandomTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;430;2312.797,13.1759;Inherit;False;RainDropUV;1;;117;60d3515a1dae5ce488115846233df0a6;0;1;82;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;405;3559.027,-541.289;Inherit;True;Property;_MainTex1;MainTex;4;0;Create;True;0;0;False;0;False;c62467d7c817b564888fd3fb1c9ffd2d;c62467d7c817b564888fd3fb1c9ffd2d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ConditionalIfNode;18;1878.662,-1129.401;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.48;False;2;FLOAT4;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;395;2624.086,69.37084;Inherit;False;Property;_WaterVisableIntensity1;WaterVisableIntensity;8;0;Create;True;0;0;False;0;False;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;2921.323,20.7959;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;369;-2523.914,-722.6522;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;402;3180.442,-45.5591;Inherit;False;Property;_BlurIntensity1;BlurIntensity;6;0;Create;True;0;0;False;0;False;0.05;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;396;2768.777,-113.4991;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;2905.877,353.7219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;370;36.83987,-613.0708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;392;2743.205,276.3479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;306;146.6124,101.6051;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.75;False;2;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;371;-190.9494,202.5102;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;338;-142.56,-613.0712;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.08;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;309;25.00979,-484.6437;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;-1364.731,-668.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;339;-657.1058,-115.5952;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;431;2310.497,-90.11814;Inherit;False;RainDropUV;1;;119;60d3515a1dae5ce488115846233df0a6;0;1;82;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;270;61.15003,1158.95;Float;False;True;-1;2;ASEMaterialInspector;100;1;Effects_Unlit/6_RainDrop_Opaque;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;112;0;107;0
WireConnection;112;1;111;0
WireConnection;113;0;112;0
WireConnection;113;1;115;0
WireConnection;428;82;107;0
WireConnection;429;82;113;0
WireConnection;138;0;428;0
WireConnection;137;0;429;0
WireConnection;139;0;138;0
WireConnection;139;1;137;0
WireConnection;109;0;428;0
WireConnection;109;1;429;0
WireConnection;142;0;139;0
WireConnection;142;1;143;0
WireConnection;128;0;109;0
WireConnection;128;1;129;0
WireConnection;140;0;142;0
WireConnection;122;1;125;0
WireConnection;141;0;121;0
WireConnection;141;1;140;0
WireConnection;130;0;107;0
WireConnection;130;1;128;0
WireConnection;126;0;122;0
WireConnection;310;0;328;0
WireConnection;299;0;341;0
WireConnection;344;0;307;0
WireConnection;344;1;363;0
WireConnection;356;0;339;0
WireConnection;335;0;299;0
WireConnection;335;1;312;0
WireConnection;333;0;320;0
WireConnection;313;0;340;0
WireConnection;362;0;326;0
WireConnection;354;0;339;0
WireConnection;354;1;347;0
WireConnection;320;0;322;0
WireConnection;343;1;364;0
WireConnection;302;0;335;0
WireConnection;367;0;374;0
WireConnection;357;0;305;0
WireConnection;357;1;314;0
WireConnection;298;0;362;0
WireConnection;322;0;369;2
WireConnection;376;0;357;0
WireConnection;328;0;322;0
WireConnection;363;0;352;0
WireConnection;363;1;346;0
WireConnection;366;0;353;0
WireConnection;366;1;358;0
WireConnection;366;2;355;0
WireConnection;351;0;354;0
WireConnection;327;0;311;0
WireConnection;79;0;14;0
WireConnection;79;1;18;0
WireConnection;314;0;302;0
WireConnection;314;1;301;0
WireConnection;345;0;350;0
WireConnection;345;1;349;0
WireConnection;342;0;345;0
WireConnection;317;0;332;0
WireConnection;372;0;317;0
WireConnection;372;1;336;0
WireConnection;373;0;344;0
WireConnection;336;0;327;0
WireConnection;336;1;334;0
WireConnection;307;0;340;0
WireConnection;337;0;303;0
WireConnection;350;0;344;0
WireConnection;350;1;298;0
WireConnection;365;0;339;0
WireConnection;360;0;329;0
WireConnection;305;0;335;0
WireConnection;340;0;376;0
WireConnection;297;0;318;0
WireConnection;297;1;367;0
WireConnection;348;0;342;0
WireConnection;316;0;356;0
WireConnection;332;0;337;0
WireConnection;332;1;336;0
WireConnection;319;0;310;0
WireConnection;319;1;333;0
WireConnection;403;1;397;0
WireConnection;401;0;405;0
WireConnection;401;1;400;0
WireConnection;401;2;406;0
WireConnection;401;3;404;0
WireConnection;300;0;360;0
WireConnection;386;0;325;0
WireConnection;386;1;384;0
WireConnection;391;0;430;0
WireConnection;404;0;402;0
WireConnection;404;1;398;0
WireConnection;324;0;315;0
WireConnection;324;1;359;0
WireConnection;315;0;354;0
WireConnection;315;1;353;0
WireConnection;321;0;343;0
WireConnection;355;0;306;0
WireConnection;355;1;371;0
WireConnection;355;2;348;0
WireConnection;359;0;355;0
WireConnection;359;1;345;0
WireConnection;303;0;336;0
WireConnection;325;0;324;0
WireConnection;325;2;358;0
WireConnection;353;0;351;0
WireConnection;361;0;370;0
WireConnection;361;1;309;0
WireConnection;14;2;16;0
WireConnection;398;0;394;0
WireConnection;387;0;386;0
WireConnection;387;1;385;0
WireConnection;364;0;357;0
WireConnection;375;0;313;0
WireConnection;375;1;297;0
WireConnection;358;0;361;0
WireConnection;358;1;306;0
WireConnection;400;0;325;0
WireConnection;400;1;399;0
WireConnection;304;0;313;0
WireConnection;304;1;323;0
WireConnection;406;0;403;0
WireConnection;390;0;431;0
WireConnection;119;0;118;0
WireConnection;119;1;130;0
WireConnection;119;2;126;0
WireConnection;119;3;141;0
WireConnection;329;0;372;0
WireConnection;308;0;304;0
WireConnection;368;0;330;0
WireConnection;352;0;321;0
WireConnection;326;0;308;0
WireConnection;331;0;343;0
WireConnection;430;82;387;0
WireConnection;18;2;16;0
WireConnection;399;0;396;0
WireConnection;399;1;395;0
WireConnection;396;0;431;0
WireConnection;396;1;430;0
WireConnection;394;0;392;0
WireConnection;394;1;393;0
WireConnection;370;0;338;0
WireConnection;392;0;390;0
WireConnection;392;1;391;0
WireConnection;306;0;313;0
WireConnection;371;0;375;0
WireConnection;338;0;316;0
WireConnection;309;0;365;0
WireConnection;330;0;319;0
WireConnection;339;0;344;0
WireConnection;339;1;375;0
WireConnection;431;82;325;0
WireConnection;270;0;119;0
ASEEND*/
//CHKSM=1F401B6EC8E85A9B0900204FF95F210AC704E5A8