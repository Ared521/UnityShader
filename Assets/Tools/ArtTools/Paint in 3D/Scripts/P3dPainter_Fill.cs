using UnityEngine;
using System.Collections.Generic;

namespace PaintIn3D
{
	public static partial class P3dPainter
	{
		public class Fill : P3dCommand
		{
			[System.NonSerialized]
			private static Material[] cachedMaterials;

			[System.NonSerialized]
			private static bool[] cachedSwaps;

			[System.NonSerialized]
			private static Material cachedMaterial;

			[System.NonSerialized]
			private static bool cachedSwap;

			[System.NonSerialized]
			private static Texture cachedTexture;

			[System.NonSerialized]
			private static Color cachedColor;

			[System.NonSerialized]
			private static float cachedOpacity;

			[System.NonSerialized]
			private Material material;

			[System.NonSerialized]
			private bool swap;

			[System.NonSerialized]
			private Texture texture;

			[System.NonSerialized]
			private Color color;

			[System.NonSerialized]
			private float opacity;

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
					return swap;
				}
			}

			public override bool RequireMesh
			{
				get
				{
					return false;
				}
			}

			static Fill()
			{
				cachedMaterials = BuildMaterialsBlendModes("Hidden/Paint in 3D/Fill");
				cachedSwaps     = BuildSwapBlendModes();
			}

			public static void SetMaterial(P3dBlendMode blendMode, Texture texture)
			{
				cachedMaterial = cachedMaterials[(int)blendMode];
				cachedSwap     = cachedSwaps[(int)blendMode];
				cachedTexture  = texture;
				cachedColor    = Color.white;
				cachedOpacity  = 1.0f;
			}

			public static void SetMaterial(P3dBlendMode blendMode, Texture texture, Color color, float opacity)
			{
				cachedMaterial = cachedMaterials[(int)blendMode];
				cachedSwap     = cachedSwaps[(int)blendMode];
				cachedTexture  = texture;
				cachedColor    = color;
				cachedOpacity  = opacity;
			}

			public static bool Blit(P3dBlendMode blendMode, ref RenderTexture renderTexture, Texture texture)
			{
				cachedMaterial = cachedMaterials[(int)blendMode];
				cachedSwap     = cachedSwaps[(int)blendMode];
				cachedMaterial.SetTexture(P3dShader._Texture, texture);
				cachedMaterial.SetColor(P3dShader._Color, Color.white);
				cachedMaterial.SetFloat(P3dShader._Opacity, 1.0f);

				return Blit(cachedMaterial, ref renderTexture);
			}

			public static bool Blit(P3dBlendMode blendMode, ref RenderTexture renderTexture, Texture texture, Color color, float opacity = 1.0f)
			{
				cachedMaterial = cachedMaterials[(int)blendMode];
				cachedSwap     = cachedSwaps[(int)blendMode];
				cachedMaterial.SetTexture(P3dShader._Texture, texture);
				cachedMaterial.SetColor(P3dShader._Color, color);
				cachedMaterial.SetFloat(P3dShader._Opacity, opacity);

				return Blit(cachedMaterial, ref renderTexture);
			}

			private static bool Blit(Material cachedMaterial, ref RenderTexture renderTexture)
			{
				if (cachedSwap == true)
				{
					var swap = P3dHelper.GetRenderTexture(renderTexture.width, renderTexture.height, renderTexture.depth, renderTexture.format);

					cachedMaterial.SetTexture(P3dShader._Buffer, renderTexture);

					P3dHelper.Blit(swap, cachedMaterial);

					P3dHelper.ReleaseRenderTexture(renderTexture);

					renderTexture = swap;

					return true;
				}

				P3dHelper.Blit(renderTexture, cachedMaterial);

				return false;
			}

			public override void Apply()
			{
				material.SetTexture(P3dShader._Texture, texture);
				material.SetColor(P3dShader._Color, color);
				material.SetFloat(P3dShader._Opacity, opacity);
			}

			public override void Pool()
			{
				pool.Add(this); poolCount++;
			}

			public static void CopyTo(Fill command)
			{
				command.material = cachedMaterial;
				command.swap     = cachedSwap;
				command.texture  = cachedTexture;
				command.color    = cachedColor;
				command.opacity  = cachedOpacity;
			}

			public static void Submit(P3dPaintableTexture paintableTexture, bool preview)
			{
				var command = paintableTexture.AddCommand(pool, ref poolCount, preview);

				CopyTo(command);
			}

			private static int poolCount;

			private static List<Fill> pool = new List<Fill>();
		}
	}
}