Shader "Hidden/KawaseBlur"
{
	Properties
    {
        _MainTex("", 2D) = "white" {}
    }
	SubShader
	{	
		Pass
		{
			Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment Frag
		    #include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			uniform half _Offset;
		
			half4 Frag(v2f_img i): SV_Target
			{
				half4 o = 0;
				o += tex2D(_MainTex, i.uv + float2(_Offset + 0.5, _Offset + 0.5) * _MainTex_TexelSize.xy);
				o += tex2D(_MainTex, i.uv + float2(-_Offset - 0.5, _Offset + 0.5) * _MainTex_TexelSize.xy);
				o += tex2D(_MainTex, i.uv + float2(-_Offset - 0.5, -_Offset - 0.5) * _MainTex_TexelSize.xy);
				o += tex2D(_MainTex, i.uv + float2(_Offset + 0.5, -_Offset - 0.5) * _MainTex_TexelSize.xy);
				return o * 0.25;
			}
			ENDCG
		}
	}
}


