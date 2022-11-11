using UnityEngine;
using System.Collections.Generic;

namespace PaintIn3D
{
	public static partial class P3dPainter
	{
		public class Sphere : P3dCommand
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
			private static Matrix4x4 cachedMatrix = Matrix4x4.identity;

			[System.NonSerialized]
			private static Vector3 cachedPosition;

			[System.NonSerialized]
			private static float cachedSqrRadius;

			[System.NonSerialized]
			private static Color cachedColor;

			[System.NonSerialized]
			private static float cachedOpacity;

			[System.NonSerialized]
			private static float cachedHardness;

			[System.NonSerialized]
			private Material material;

			[System.NonSerialized]
			private bool swap;

			[System.NonSerialized]
			private Matrix4x4 matrix;

			[System.NonSerialized]
			private float hardness;

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
					return true;
				}
			}

			static Sphere()
			{
				cachedMaterials = BuildMaterialsBlendModes("Hidden/Paint in 3D/Sphere");
				cachedSwaps     = BuildSwapBlendModes();
			}

			public static void SetMatrix(Vector3 position, float radius)
			{
				cachedMatrix.m00 = cachedMatrix.m11 = cachedMatrix.m22 = radius;
				cachedMatrix.m03 = position.x;
				cachedMatrix.m13 = position.y;
				cachedMatrix.m23 = position.z;

				cachedPosition  = position;
				cachedSqrRadius = radius * radius;
			}

			public static void SetMaterial(P3dBlendMode blendMode, float hardness, Color color, float opacity)
			{
				cachedMaterial = cachedMaterials[(int)blendMode];
				cachedSwap     = cachedSwaps[(int)blendMode];
				cachedHardness = hardness;
				cachedColor    = color;
				cachedOpacity  = opacity;
			}

			public static void SubmitAll(bool preview = false, int layerMask = -1, int groupMask = -1)
			{
				var paintables = P3dPaintable.FindOverlap(cachedPosition, cachedSqrRadius, layerMask);

				for (var i = paintables.Count - 1; i >= 0; i--)
				{
					var paintableTextures = P3dPaintableTexture.Filter(paintables[i], groupMask);

					for (var j = paintableTextures.Count - 1; j >= 0; j--)
					{
						Submit(paintableTextures[j], preview);
					}
				}
			}

			public override void Apply()
			{
				material.SetMatrix(P3dShader._Matrix, matrix.inverse);
				material.SetFloat(P3dShader._Hardness, hardness);
				material.SetColor(P3dShader._Color, color);
				material.SetFloat(P3dShader._Opacity, opacity);
			}

			public override void Pool()
			{
				pool.Add(this); poolCount++;
			}

			public static void CopyTo(Sphere command)
			{
				command.material = cachedMaterial;
				command.swap     = cachedSwap;
				command.matrix   = cachedMatrix;
				command.hardness = cachedHardness;
				command.color    = cachedColor;
				command.opacity  = cachedOpacity;
			}

			public static void Submit(P3dPaintableTexture paintableTexture, bool preview)
			{
				var command = paintableTexture.AddCommand(pool, ref poolCount, preview);

				CopyTo(command);
			}

			private static int poolCount;

			private static List<Sphere> pool = new List<Sphere>();
		}
	}
}