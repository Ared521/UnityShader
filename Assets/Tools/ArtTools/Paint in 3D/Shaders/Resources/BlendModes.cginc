float2 ShiftCoord(float2 coord)
{
	float2 shift = float2(0.0f, 0.0f);
#if UNITY_HALF_TEXEL_OFFSET
	//shift = 0.5f / _ScreenParams.xy;
#endif
#if UNITY_UV_STARTS_AT_TOP
	//shift.y = -shift.y;
#endif
	return coord + shift;
}

float4 Blend(float4 color, float strength, sampler2D buffer, float2 coord)
{
#if P3D_D // Multiply
	color.rgb = lerp(color.rgb, float3(1, 1, 1), 1 - color.a * strength);
#elif P3D_C // Shape Lerp
	float4 old = tex2D(buffer, ShiftCoord(coord));
	color = lerp(old, color, strength);
#elif P3D_B // AlphaBlendAdvanced
	color.a *= strength;
	float4 old = tex2D(buffer, ShiftCoord(coord));
	float4 add = color;

	float add_a = add.a;
	float add_i = 1.0f - add_a;
	float old_a = old.a;
	float old_n = add_a + old_a * add_i;

	old.r = (add.r * add_a + old.r * old_a * add_i) / old_n;
	old.g = (add.g * add_a + old.g * old_a * add_i) / old_n;
	old.b = (add.b * add_a + old.b * old_a * add_i) / old_n;
	old.a = old_n;

	color = old;
#elif P3D_A // Additive/Subtractive
	color *= strength;
#else // AlphaBlend
	color.a *= strength;
#endif
	return color;
}

float4 BlendMinimum(float4 color, float strength, sampler2D buffer, float2 coord, float4 step)
{
#if P3D_D // Multiply
	color.rgb = lerp(color.rgb, float3(1, 1, 1), 1 - color.a * strength);
#elif P3D_C // Shape Lerp
	float4 old = tex2D(buffer, ShiftCoord(coord));
	old += sign(color - old) * step;
	color = lerp(old, color, strength);
#elif P3D_B // AlphaBlendAdvanced
	color.a *= strength;
	float4 old = tex2D(buffer, ShiftCoord(coord));
	float4 add = color;

	float add_a = add.a;
	float add_i = 1.0f - add_a;
	float old_a = old.a;
	float old_n = add_a + old_a * add_i;

	old.r = (add.r * add_a + old.r * old_a * add_i) / old_n;
	old.g = (add.g * add_a + old.g * old_a * add_i) / old_n;
	old.b = (add.b * add_a + old.b * old_a * add_i) / old_n;
	old.a = old_n;

	color = old;
#elif P3D_A // Additive/Subtractive
	color *= strength;
#else // AlphaBlend
	color.a *= strength;
#endif
	return color;
}