using UnityEngine;
using System.Collections.Generic;

namespace PaintIn3D
{
	public static partial class P3dPainter
	{
		public class Replace : P3dCommand
		{
			[System.NonSerialized]
			private static Material cachedMaterial;

			[System.NonSerialized]
			private static Texture cachedTexture;

			[System.NonSerialized]
			private static Color cachedColor;

			[System.NonSerialized]
			private Material material;

			[System.NonSerialized]
			private Texture texture;

			[System.NonSerialized]
			private Color color;

			public override Material Material
			{
				get
				{
					return material;
				}
			}

			public override bool RequireSwap
			{
				get
				{
					return false;
				}
			}

			public override bool RequireMesh
			{
				get
				{
					return false;
				}
			}

			static Replace()
			{
				cachedMaterial = BuildMaterial("Hidden/Paint in 3D/Replace");
			}

			public static void SetMaterial(Texture texture)
			{
				cachedTexture = texture;
				cachedColor   = Color.white;
			}

			public static void SetMaterial(Texture texture, Color color, float opacity = 1.0f)
			{
				color.a *= opacity;

				cachedTexture = texture;
				cachedColor   = color;
			}

			public static void Blit(RenderTexture renderTexture, Texture texture)
			{
				cachedMaterial.SetTexture(P3dShader._Texture, texture);
				cachedMaterial.SetColor(P3dShader._Color, Color.white);

				P3dHelper.Blit(renderTexture, cachedMaterial);
			}

			public static void Blit(RenderTexture renderTexture, Texture texture, Color color, float opacity = 1.0f)
			{
				color.a *= opacity;

				cachedMaterial.SetTexture(P3dShader._Texture, texture);
				cachedMaterial.SetColor(P3dShader._Color, color);

				P3dHelper.Blit(renderTexture, cachedMaterial);
			}

			public override void Apply()
			{
				material.SetTexture(P3dShader._Texture, texture);
				material.SetColor(P3dShader._Color, color);
			}

			public override void Pool()
			{
				pool.Add(this); poolCount++;
			}

			public static void CopyTo(Replace command)
			{
				command.material = cachedMaterial;
				command.texture  = cachedTexture;
				command.color    = cachedColor;
			}

			public static void Submit(P3dPaintableTexture paintableTexture, bool preview)
			{
				var command = paintableTexture.AddCommand(pool, ref poolCount, preview);

				CopyTo(command);
			}

			private static int poolCount;

			private static List<Replace> pool = new List<Replace>();
		}
	}
}