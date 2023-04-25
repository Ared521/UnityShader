//puppet_master
//2018.4.15
//GodRay，体积阴影扩展，沿光方向挤出顶点实现
Shader "GodRay_VolumeShadow" 
{
 
	Properties 
	{
		_Color("Color", Color) = (1,1,1,0.002)
		_MainTex ("Base texture", 2D) = "white" {}
		_ExtrusionFactor("Extrusion", Range(0, 2)) = 0.1
		_Intensity("Intensity", Range(0, 10)) = 1
		_WorldLightPos("LightPos", Vector) = (0,0,0,0)
	}
 
	SubShader 
	{	
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent + 1" }
		
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off 
		ZWrite Off 
		Fog { Color (0,0,0,0) }
		
		CGINCLUDE	
		#include "UnityCG.cginc"
		
		float4 _Color;
		float4 _WorldLightPos;
		sampler2D _MainTex;
		float _ExtrusionFactor;
		float _Intensity;
 
		struct v2f {
			float4	pos		: SV_POSITION;
			float2	uv		: TEXCOORD0;
			float distance : TEXCOORD1;
		};
		
		v2f vert (appdata_base v)
		{
			v2f o;
			//转化到物体空间计算
			float3 objectLightPos = mul(unity_WorldToObject, _WorldLightPos.xyz).xyz;
			float3 objectLightDir = objectLightPos - v.vertex.xyz;
			float dotValue = dot(objectLightDir, v.normal);
			//light dot normal，*0.5+0.5转化为0,1控制变量，控制受光面挤出
			float controlValue = sign(dotValue) * 0.5 + 0.5;
			float4 vpos = v.vertex;
			//受光面沿法线反方向挤出顶点
			vpos.xyz -= objectLightDir * _ExtrusionFactor * controlValue;
							
			o.uv	= v.texcoord.xy;
			o.pos	= UnityObjectToClipPos(vpos);
			o.distance = length(objectLightDir);
							
			return o;
		}
		
		fixed4 frag (v2f i) : COLOR
		{	
			fixed4 tex = tex2D(_MainTex, i.uv);
			//顶点到光的距离与物体到光的距离控制一个衰减值
            // _WorldLightPos.w：光源到物体的距离
            // i.distance：顶点到光源的距离
			float att = i.distance / _WorldLightPos.w;
			return _Color * tex * att * _Intensity;
		}
		ENDCG
 
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest			
			ENDCG 
		}	
	}
}
 