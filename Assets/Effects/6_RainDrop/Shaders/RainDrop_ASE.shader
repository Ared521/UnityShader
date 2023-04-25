// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RainDrop_ASE"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_DropSize("DropSize", Range( 0 , 5)) = 5
		_DropSize_Addition("DropSize_Addition", Vector) = (2,1,0,0)
		_DropSpeed("DropSpeed", Range( 0 , 5)) = 1
		_HorizonDistort("HorizonDistort", Float) = 0.5
		_DaDu_Size("DaDu_Size", Range( 0 , 20)) = 3
		_TrackDropCount("TrackDropCount", Range( 0 , 20)) = 10

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

			uniform sampler2D _TextureSample0;
			uniform float2 _DropSize_Addition;
			uniform float _DropSize;
			uniform float _DropSpeed;
			uniform float _HorizonDistort;
			uniform float _DaDu_Size;
			uniform float _TrackDropCount;
			float Static_U12( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V13( float2 UV )
			{
				float v = UV.y;
				return v;
			}
			
			float Static_U47( float2 UV )
			{
				float u = UV.x;
				return u;
			}
			
			float Static_V48( float2 UV )
			{
				float v = UV.y;
				return v;
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
				float2 texCoord103 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord1 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 DropSize_Addition115 = _DropSize_Addition;
				float2 temp_output_4_0 = ( ( texCoord1 * DropSize_Addition115 ) * _DropSize );
				float2 UV12 = temp_output_4_0;
				float localStatic_U12 = Static_U12( UV12 );
				float2 UV13 = temp_output_4_0;
				float localStatic_V13 = Static_V13( UV13 );
				float2 appendResult14 = (float2(localStatic_U12 , ( localStatic_V13 + ( _Time.y * _DropSpeed ) )));
				float2 temp_output_9_0 = ( frac( appendResult14 ) + float2( -0.5,-0.5 ) );
				float2 UV47 = temp_output_9_0;
				float localStatic_U47 = Static_U47( UV47 );
				float dotResult4_g1 = dot( floor( appendResult14 ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float temp_output_44_0 = lerpResult10_g1;
				float2 texCoord40 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_28_0 = ( texCoord40.y * 8.0 );
				float X_Wiggle39 = ( ( pow( sin( temp_output_28_0 ) , 6.0 ) * sin( ( temp_output_28_0 * 3.0 ) ) ) * 0.25 );
				float temp_output_57_0 = ( localStatic_U47 - ( ( ( ( temp_output_44_0 + -0.5 ) * 0.5 ) + X_Wiggle39 ) * _HorizonDistort ) );
				float2 UV48 = temp_output_9_0;
				float localStatic_V48 = Static_V48( UV48 );
				float RandomTime45 = temp_output_44_0;
				float temp_output_35_0 = ( ( RandomTime45 * 6.15 ) + _Time.y );
				float Y_Wiggle22 = ( sin( ( sin( ( ( sin( temp_output_35_0 ) * 0.5 ) + temp_output_35_0 ) ) + temp_output_35_0 ) ) * -0.3 );
				float U108 = temp_output_57_0;
				float temp_output_49_0 = ( localStatic_V48 - ( Y_Wiggle22 - ( pow( U108 , 2.0 ) * _DaDu_Size ) ) );
				float2 appendResult51 = (float2(temp_output_57_0 , temp_output_49_0));
				float2 temp_output_17_0 = ( appendResult51 / DropSize_Addition115 );
				float smoothstepResult10 = smoothstep( 0.1 , 0.075 , length( temp_output_17_0 ));
				float smoothstepResult79 = smoothstep( 0.75 , -0.25 , localStatic_V48);
				float smoothstepResult76 = smoothstep( 0.0 , 0.01 , temp_output_49_0);
				float2 appendResult68 = (float2(appendResult51.x , ( ( frac( ( ( temp_output_49_0 - _Time.y ) * _TrackDropCount ) ) + -0.5 ) / _TrackDropCount )));
				float2 temp_output_65_0 = ( appendResult68 / DropSize_Addition115 );
				float smoothstepResult66 = smoothstep( 0.05 , 0.025 , length( temp_output_65_0 ));
				float temp_output_77_0 = ( smoothstepResult79 * smoothstepResult76 * smoothstepResult66 );
				
				
				finalColor = tex2D( _TextureSample0, ( texCoord103 + ( ( temp_output_17_0 * smoothstepResult10 ) + ( temp_output_77_0 * temp_output_65_0 ) ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
-6;267;1906;636;3444.979;814.4437;3.549201;True;False
Node;AmplifyShaderEditor.Vector2Node;3;-2315.211,-255.8875;Inherit;False;Property;_DropSize_Addition;DropSize_Addition;2;0;Create;True;0;0;False;0;False;2,1;2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-2112.9,-256.0638;Inherit;False;DropSize_Addition;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2248.37,50.75257;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;116;-2235.859,184.4961;Inherit;False;115;DropSize_Addition;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2059.371,317.8723;Inherit;False;Property;_DropSize;DropSize;1;0;Create;True;0;0;False;0;False;5;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1943.121,72.75002;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-1988.677,529.5656;Inherit;False;Property;_DropSpeed;DropSpeed;3;0;Create;True;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-1866.771,450.3723;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1764.871,158.0723;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1655.677,402.5656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;13;-1632.121,238.75;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-1463.519,301.0504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;12;-1628.121,136.75;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-1314.204,183.6564;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1783.963,-486.1217;Inherit;False;1608.964;308.9998;水滴水平方向速度随机;9;40;39;34;32;30;28;27;26;24;X_Wiggle;0,1,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-1733.963,-366.4221;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;43;-1190.331,49.98779;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;44;-1031.709,54.42662;Inherit;False;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1452.775,-320.1219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2159.84,-900.2854;Inherit;False;1829.159;301.0598;水滴竖直方向速度随机;12;41;38;37;36;35;33;31;29;25;23;22;46;Y_Wiggle;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1172.776,-320.1219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-855.8147,-76.53488;Inherit;False;RandomTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;30;-1164.777,-404.1216;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-1011.778,-436.1216;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;34;-994.7781,-309.1219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-2125.531,-846.5297;Inherit;False;45;RandomTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;25;-2124.427,-728.9854;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1907.555,-838.5084;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-786.7791,-387.1217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1766.415,-771.5063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-574.7786,-312.1219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-398.9995,-318.794;Inherit;False;X_Wiggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-808.4464,9.993272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;23;-1650.173,-851.2854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-624.3597,-92.43214;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1518.172,-850.2854;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;8;-1019.833,189.678;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-623.1098,45.98637;Inherit;False;39;X_Wiggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-1326.17,-834.2854;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-845.1321,208.878;Inherit;False;2;2;0;FLOAT2;-0.5,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-443.9788,19.07578;Inherit;False;Property;_HorizonDistort;HorizonDistort;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-463.1852,-94.12714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;37;-1198.168,-802.2854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-271.0794,-82.32425;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;47;-660.1089,166.5581;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-128.3371,-9.748901;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1031.11,-778.7954;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;31;-876.9489,-779.5204;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;30.89685,-133.3957;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-732.718,-788.1074;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-1167.029,436.9154;Inherit;False;108;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1188.518,577.8429;Inherit;False;Property;_DaDu_Size;DaDu_Size;5;0;Create;True;0;0;False;0;False;3;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-554.6745,-802.7994;Inherit;False;Y_Wiggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;107;-994.0286,440.9154;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-911.9924,357.6488;Inherit;False;22;Y_Wiggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-840.1428,503.2362;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-702.0286,404.9154;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;48;-656.5443,273.5033;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-640.5303,595.3005;Inherit;False;2149.691;670.2679;小雨滴;14;65;66;73;72;71;70;69;68;64;77;74;76;118;125;TrackDrop;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;74;-591.119,897.3043;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-432.0941,409.0365;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-372.8326,868.9368;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-552.632,1111.971;Inherit;False;Property;_TrackDropCount;TrackDropCount;6;0;Create;True;0;0;False;0;False;10;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-215.8592,906.2319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;71;-63.96959,862.1026;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;86.81208,855.7405;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;28.12355,2.388731;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;69;242.4748,904.6748;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;382.9159,960.0432;Inherit;False;115;DropSize_Addition;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;478.0404,837.2356;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;65;693.9552,854.7882;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-43.93652,145.3291;Inherit;False;115;DropSize_Addition;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;64;895.7944,881.2159;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;229.7875,22.78754;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;80;785.9462,324.9354;Inherit;False;239;209;小雨滴Mask,越靠上透明度越低(其实不是透明度，就是值越低，现象是越暗);1;79;TrackDropMask;1,0,0.6055651,1;0;0
Node;AmplifyShaderEditor.LengthOpNode;11;427.2431,23.98327;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;66;1106.048,764.9142;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0.025;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;76;642.6239,696.9501;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;79;835.9462,374.9354;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.75;False;2;FLOAT;-0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;1346.161,645.3005;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;10;605.1359,15.21015;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;1274.934,-901.0638;Inherit;False;1279.994;540.6054;轨迹;6;101;100;102;103;104;99;Track;0,0.6403694,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;1324.934,-674.9688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;1329.016,-495.4593;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;1630.673,-560.1785;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;103;1626.821,-851.0638;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;104;1956.237,-648.792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;1599.903,-60.13342;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;81;322.8383,-259.9959;Inherit;False;float u = UV.x@$return u@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_U;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;87;536.4167,-297.2748;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;86;688.5165,-297.2748;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.125;False;2;FLOAT;0.175;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;83;856.0864,-168.8471;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;1614.339,106.8756;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;1120.072,-244.9616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;1824.913,67.84886;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;82;316.9602,-135.0818;Inherit;False;float v = UV.y@$return v@;1;False;1;True;UV;FLOAT2;0,0;In;;Inherit;False;Static_V;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;99;2234.93,-669.8648;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;85;893.9163,-319.3742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;52;2748.19,-692.686;Float;False;True;-1;2;ASEMaterialInspector;100;1;RainDrop_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;115;0;3;0
WireConnection;16;0;1;0
WireConnection;16;1;116;0
WireConnection;4;0;16;0
WireConnection;4;1;2;0
WireConnection;114;0;7;0
WireConnection;114;1;113;0
WireConnection;13;0;4;0
WireConnection;15;0;13;0
WireConnection;15;1;114;0
WireConnection;12;0;4;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;43;0;14;0
WireConnection;44;1;43;0
WireConnection;28;0;40;2
WireConnection;27;0;28;0
WireConnection;45;0;44;0
WireConnection;30;0;28;0
WireConnection;24;0;30;0
WireConnection;34;0;27;0
WireConnection;29;0;46;0
WireConnection;26;0;24;0
WireConnection;26;1;34;0
WireConnection;35;0;29;0
WireConnection;35;1;25;0
WireConnection;32;0;26;0
WireConnection;39;0;32;0
WireConnection;56;0;44;0
WireConnection;23;0;35;0
WireConnection;55;0;56;0
WireConnection;36;0;23;0
WireConnection;8;0;14;0
WireConnection;33;0;36;0
WireConnection;33;1;35;0
WireConnection;9;0;8;0
WireConnection;53;0;55;0
WireConnection;53;1;54;0
WireConnection;37;0;33;0
WireConnection;119;0;53;0
WireConnection;119;1;120;0
WireConnection;47;0;9;0
WireConnection;57;0;47;0
WireConnection;57;1;119;0
WireConnection;41;0;37;0
WireConnection;41;1;35;0
WireConnection;31;0;41;0
WireConnection;108;0;57;0
WireConnection;38;0;31;0
WireConnection;22;0;38;0
WireConnection;107;0;106;0
WireConnection;122;0;107;0
WireConnection;122;1;124;0
WireConnection;105;0;50;0
WireConnection;105;1;122;0
WireConnection;48;0;9;0
WireConnection;49;0;48;0
WireConnection;49;1;105;0
WireConnection;73;0;49;0
WireConnection;73;1;74;0
WireConnection;72;0;73;0
WireConnection;72;1;125;0
WireConnection;71;0;72;0
WireConnection;70;0;71;0
WireConnection;51;0;57;0
WireConnection;51;1;49;0
WireConnection;69;0;70;0
WireConnection;69;1;125;0
WireConnection;68;0;51;0
WireConnection;68;1;69;0
WireConnection;65;0;68;0
WireConnection;65;1;118;0
WireConnection;64;0;65;0
WireConnection;17;0;51;0
WireConnection;17;1;117;0
WireConnection;11;0;17;0
WireConnection;66;0;64;0
WireConnection;76;0;49;0
WireConnection;79;0;48;0
WireConnection;77;0;79;0
WireConnection;77;1;76;0
WireConnection;77;2;66;0
WireConnection;10;0;11;0
WireConnection;100;0;17;0
WireConnection;100;1;10;0
WireConnection;101;0;77;0
WireConnection;101;1;65;0
WireConnection;102;0;100;0
WireConnection;102;1;101;0
WireConnection;104;0;103;0
WireConnection;104;1;102;0
WireConnection;88;0;84;0
WireConnection;88;1;79;0
WireConnection;81;0;51;0
WireConnection;87;0;81;0
WireConnection;86;0;87;0
WireConnection;83;0;82;0
WireConnection;75;0;10;0
WireConnection;75;1;77;0
WireConnection;84;0;85;0
WireConnection;84;1;83;0
WireConnection;89;0;88;0
WireConnection;89;1;75;0
WireConnection;82;0;51;0
WireConnection;99;1;104;0
WireConnection;85;0;86;0
WireConnection;52;0;99;0
ASEEND*/
//CHKSM=F033C99458D767F6C064408C5978DD235B97DCC3