Shader "Hidden/Paint in 3D/Replace"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags
		{
			"Queue"           = "Transparent"
			"RenderType"      = "Transparent"
			"IgnoreProjector" = "True"
			"Paint in 3D"     = "True"
		}
		Pass
		{
			Blend One Zero
			Cull Off
			Lighting Off
			ZWrite Off

			CGPROGRAM
				#pragma vertex vert_img
				#pragma fragment Frag
				#include "UnityCG.cginc"

				sampler2D _Texture;
				float4    _Color;

				struct f2g
				{
					float4 color : COLOR;
				};

				void Frag(v2f_img i, out f2g o)
				{
					o.color = tex2D(_Texture, i.uv) * _Color;
				}
			ENDCG
		} // Pass
	} // SubShader
} // Shader